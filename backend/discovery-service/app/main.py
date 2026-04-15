"""HTTP API for book discovery (Open Library + optional Anna) and download preflight.

Environment:
    ANNAS_SECRET_KEY / ANNAS_API_KEY — enable Anna search when set.
    ALLOW_HTTP_PREFLIGHT — set to ``1`` to allow http URLs in preflight (dev only).
"""

import logging
import os
import re

from fastapi import FastAPI, HTTPException
import httpx

from .adapters.anna_archive import resolve_anna_md5_links, search_anna_archive
from .preflight_url import is_safe_preflight_url
from .adapters.open_library import search_open_library
from .schemas import (
    AnnaResolveResponse,
    DownloadPreflightRequest,
    DownloadPreflightResponse,
    SearchResponse,
)

app = FastAPI(title="Library Discovery Service", version="0.1.0")

logger = logging.getLogger(__name__)


def _anna_credentials_configured() -> bool:
    """Anna HTML/API integration expects a donation API key on the server."""
    return bool(
        (os.getenv("ANNAS_SECRET_KEY") or "").strip()
        or (os.getenv("ANNAS_API_KEY") or "").strip()
    )


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/search", response_model=SearchResponse)
async def search(
    query: str | None = None,
    q: str | None = None,
    include_anna: bool = True,
) -> SearchResponse:
    query = (query or q or "").strip()
    if not query:
        raise HTTPException(status_code=400, detail="query must not be empty")

    results = await search_open_library(query)
    if include_anna and _anna_credentials_configured():
        results.extend(await search_anna_archive(query))
    elif include_anna and not _anna_credentials_configured():
        logger.debug("Anna skipped: set ANNAS_SECRET_KEY or ANNAS_API_KEY on the server")

    return SearchResponse(query=query, results=results)


@app.get("/anna/resolve", response_model=AnnaResolveResponse)
async def anna_resolve(md5: str) -> AnnaResolveResponse:
    """Best-effort parse of Anna's Archive /md5/… page for HTTP mirror or magnet links."""
    key = (md5 or "").strip().lower()
    if not re.fullmatch(r"[a-f0-9]{32}", key):
        raise HTTPException(
            status_code=400,
            detail="md5 must be exactly 32 hexadecimal characters",
        )
    if not _anna_credentials_configured():
        logger.warning(
            "Anna resolve: ANNAS_SECRET_KEY not set; page fetch may be blocked."
        )
    return await resolve_anna_md5_links(key)


@app.post("/download/preflight", response_model=DownloadPreflightResponse)
async def preflight(payload: DownloadPreflightRequest) -> DownloadPreflightResponse:
    safe, reason = is_safe_preflight_url(payload.url)
    if not safe:
        return DownloadPreflightResponse(
            allowed=False,
            reason=reason or "URL not allowed",
        )
    try:
        async with httpx.AsyncClient(timeout=12, max_redirects=8) as client:
            response = await client.head(payload.url, follow_redirects=True)
    except Exception as exc:
        return DownloadPreflightResponse(
            allowed=False,
            reason=f"HEAD request failed: {exc}",
        )

    mime_type = response.headers.get("content-type", "")
    size_header = response.headers.get("content-length")
    content_length = int(size_header) if size_header and size_header.isdigit() else None

    if "application" not in mime_type and "epub" not in mime_type and "pdf" not in mime_type:
        return DownloadPreflightResponse(
            allowed=False,
            mime_type=mime_type or None,
            content_length=content_length,
            reason="Unsupported content type",
        )

    return DownloadPreflightResponse(
        allowed=True,
        mime_type=mime_type or None,
        content_length=content_length,
    )
