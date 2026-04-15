import asyncio
from urllib.parse import quote

import httpx

from ..schemas import SearchResult


async def _resolve_archive_download(
    ia_ids: list[str],
    client: httpx.AsyncClient,
    max_attempts: int = 4,
) -> str | None:
    for ia in ia_ids[:max_attempts]:
        ia = ia.strip()
        if not ia:
            continue
        try:
            response = await client.get(
                f"https://archive.org/metadata/{quote(ia, safe='')}",
                timeout=12.0,
            )
            if response.status_code != 200:
                continue
            payload = response.json()
            files = payload.get("files") or []
            epub_name: str | None = None
            pdf_name: str | None = None
            for entry in files:
                name = (entry.get("name") or "").lower()
                if name.endswith(".epub") and epub_name is None:
                    epub_name = entry.get("name")
                elif name.endswith(".pdf") and pdf_name is None:
                    pdf_name = entry.get("name")
            pick = epub_name or pdf_name
            if not pick:
                continue
            return f"https://archive.org/download/{ia}/{quote(str(pick), safe='')}"
        except Exception:
            continue
    return None


async def search_open_library(query: str, limit: int = 15) -> list[SearchResult]:
    url = "https://openlibrary.org/search.json"
    params = {"q": query, "limit": limit}
    async with httpx.AsyncClient(timeout=12) as client:
        response = await client.get(url, params=params)
        response.raise_for_status()
        data = response.json()

    docs = data.get("docs", [])
    semaphore = asyncio.Semaphore(6)

    async with httpx.AsyncClient(timeout=12) as ia_client:

        async def build_result(doc: dict) -> SearchResult:
            cover_id = doc.get("cover_i")
            cover_url = (
                f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg"
                if cover_id
                else None
            )
            key = doc.get("key", "") or ""
            raw_ia = doc.get("ia") or []
            if isinstance(raw_ia, str):
                ia_ids = [raw_ia]
            else:
                ia_ids = [str(x) for x in raw_ia if str(x).strip()][:8]

            catalog_url = f"https://openlibrary.org{key}" if key.startswith("/") else None

            download_url: str | None = None
            if ia_ids:
                async with semaphore:
                    download_url = await _resolve_archive_download(ia_ids, ia_client)

            guessed_format = "metadata"
            if download_url:
                guessed_format = "pdf" if download_url.lower().endswith(".pdf") else "epub"

            confidence = 0.9 if download_url else 0.95

            return SearchResult(
                id=key or (doc.get("edition_key") or [""])[0],
                title=doc.get("title", "Untitled"),
                author=(doc.get("author_name") or ["Unknown Author"])[0],
                source="OpenLibrary",
                format=guessed_format,
                cover_url=cover_url,
                download_url=download_url,
                catalog_url=catalog_url,
                confidence=confidence,
            )

        return list(await asyncio.gather(*[build_result(doc) for doc in docs]))
