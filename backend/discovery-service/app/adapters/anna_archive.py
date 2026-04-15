"""
Anna's Archive search: HTML scrape with domain failover, aligned with
https://crates.io/crates/annas-archive-api (search path + parse selectors).

Set ANNAS_SECRET_KEY or ANNAS_API_KEY (donation secret) so the service can POST
/account/ and reuse session cookies; without it, some networks only see a JS
challenge and parsing returns no rows.
"""

from __future__ import annotations

import logging
import os
import re
from urllib.parse import quote, urljoin, urlparse

import httpx
from bs4 import BeautifulSoup, Tag

from ..schemas import AnnaResolveResponse, SearchResult

logger = logging.getLogger(__name__)

_DEFAULT_DOMAINS = ("annas-archive.org", "annas-archive.se", "annas-archive.li")
_USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)


def _domains() -> tuple[str, ...]:
    base = (os.getenv("ANNAS_BASE_URL") or "").strip().lower()
    if base:
        host = re.sub(r"^https?://", "", base).split("/")[0]
        if host:
            return (host,)
    return _DEFAULT_DOMAINS


def _secret_key() -> str | None:
    for key in ("ANNAS_SECRET_KEY", "ANNAS_API_KEY"):
        v = (os.getenv(key) or "").strip()
        if v:
            return v
    return None


async def _authenticate(
    client: httpx.AsyncClient, api_key: str, domains: tuple[str, ...]
) -> str | None:
    """POST /account/ on the first domain that accepts the key. Returns that host so
    subsequent GET /search reuses cookies on the same origin."""
    for domain in domains:
        url = f"https://{domain}/account/"
        try:
            response = await client.post(
                url,
                data={"key": api_key},
                follow_redirects=True,
            )
        except httpx.HTTPError as exc:
            logger.debug("Anna auth HTTP error for %s: %s", domain, exc)
            continue
        if response.status_code in (401, 403):
            logger.debug("Anna auth %s for %s", response.status_code, domain)
            continue
        if response.is_success or response.is_redirect:
            logger.debug("Anna auth ok via %s", domain)
            return domain
    logger.warning("Anna auth failed for all domains")
    return None


async def _fetch_search_html(
    client: httpx.AsyncClient,
    query: str,
    page: int,
    domains: tuple[str, ...],
) -> tuple[str | None, str | None]:
    encoded = quote(query, safe="")
    path = f"/search?q={encoded}&page={page}"
    last_status: int | None = None
    for domain in domains:
        url = f"https://{domain}{path}"
        try:
            response = await client.get(url, follow_redirects=True)
        except httpx.HTTPError as exc:
            logger.debug("Anna search fetch error for %s: %s", domain, exc)
            continue
        last_status = response.status_code
        if response.status_code == 200:
            return response.text, domain
        if 400 <= response.status_code < 500:
            logger.debug("Anna search client error %s for %s", response.status_code, domain)
            continue
    if last_status is not None:
        logger.warning("Anna search: no successful response (last status %s)", last_status)
    return None, None


def _strip_scripts(tag: Tag) -> None:
    for script in tag.find_all("script"):
        script.decompose()


def _metadata_text(result_elem: Tag) -> str:
    meta = result_elem.select_one("div.text-gray-800.font-semibold.text-sm")
    if not meta:
        return ""
    _strip_scripts(meta)
    return re.sub(r"\s+", " ", meta.get_text()).strip()


_SIZE_RE = re.compile(
    r"^\s*[\d.]+\s*(?:gb|mb|kb|b)\s*$",
    re.IGNORECASE,
)


def _is_file_size(part: str) -> bool:
    p = part.strip().lower()
    return bool(_SIZE_RE.match(p))


def _parse_metadata_line(
    text: str,
) -> tuple[str | None, str | None, str | None]:
    fmt: str | None = None
    size: str | None = None
    language: str | None = None
    for part in (p.strip() for p in text.split("·")):
        if not part:
            continue
        pl = part.lower()
        if pl in (
            "pdf",
            "epub",
            "mobi",
            "azw3",
            "djvu",
            "cbr",
            "cbz",
            "fb2",
            "txt",
            "doc",
            "docx",
            "rtf",
        ):
            fmt = part.upper()
        elif _is_file_size(pl):
            size = part
        elif "[" in part and "]" in part:
            language = part
    return fmt, size, language


def _find_author(result_elem: Tag) -> str | None:
    for a in result_elem.find_all("a", href=True):
        for span in a.find_all("span"):
            classes = span.get("class") or []
            if any("mdi--user" in str(c) for c in classes):
                text = a.get_text(strip=True)
                if text:
                    return text
    return None


def parse_search_results_html(html: str) -> list[dict[str, str | None]]:
    """Parse Anna search HTML; returns dicts with md5, title, author, format."""
    soup = BeautifulSoup(html, "html.parser")
    rows = soup.select("div.flex.pt-3.pb-3.border-b")
    out: list[dict[str, str | None]] = []
    seen: set[str] = set()

    for result_elem in rows:
        link = result_elem.select_one('a[href^="/md5/"]')
        if not link or not link.get("href"):
            continue
        href = link["href"]
        md5 = href.removeprefix("/md5/").strip()
        if not md5 or md5 in seen:
            continue

        title_a = result_elem.select_one("a.js-vim-focus")
        title = title_a.get_text(strip=True) if title_a else ""
        if not title:
            continue

        seen.add(md5)
        meta = _metadata_text(result_elem)
        fmt, _size, _lang = _parse_metadata_line(meta)
        author = _find_author(result_elem)

        out.append(
            {
                "md5": md5,
                "title": title,
                "author": author,
                "format": fmt,
            }
        )
    return out


def parse_md5_download_links(html: str, page_url: str) -> tuple[str | None, str | None]:
    """Extract HTTP mirror and BitTorrent magnet links from an /md5/… HTML page."""
    parsed = urlparse(page_url)
    origin = f"{parsed.scheme}://{parsed.netloc}/"
    soup = BeautifulSoup(html, "html.parser")
    magnet: str | None = None
    http_candidates: list[str] = []

    for a in soup.find_all("a", href=True):
        href = (a.get("href") or "").strip()
        if not href or href.startswith("#"):
            continue
        if href.lower().startswith("magnet:"):
            if magnet is None and "btih" in href.lower():
                magnet = href
            continue
        full = urljoin(origin, href)
        low = full.lower()
        if low.startswith("magnet:"):
            if magnet is None and "btih" in low:
                magnet = full
            continue
        if any(seg in low for seg in ("/slow_download", "/fast_download")):
            http_candidates.append(full)
        elif low.endswith(".epub") or low.endswith(".pdf"):
            http_candidates.append(full)

    http_out: str | None = None
    for c in http_candidates:
        if "slow_download" in c.lower():
            http_out = c
            break
    if http_out is None and http_candidates:
        http_out = http_candidates[0]
    return http_out, magnet


async def _fetch_md5_html(
    client: httpx.AsyncClient,
    md5: str,
    domains: tuple[str, ...],
) -> tuple[str | None, str | None]:
    path = f"/md5/{md5}"
    last_status: int | None = None
    for domain in domains:
        url = f"https://{domain}{path}"
        try:
            response = await client.get(url, follow_redirects=True)
        except httpx.HTTPError as exc:
            logger.debug("Anna md5 fetch error for %s: %s", domain, exc)
            continue
        last_status = response.status_code
        if response.status_code == 200 and response.text:
            return response.text, domain
        if 400 <= response.status_code < 500:
            logger.debug("Anna md5 client error %s for %s", response.status_code, domain)
            continue
    if last_status is not None:
        logger.warning("Anna md5: no successful response (last status %s)", last_status)
    return None, None


async def resolve_anna_md5_links(md5_hex: str) -> AnnaResolveResponse:
    """Fetch /md5/… and extract partner HTTP or magnet links (best-effort)."""
    raw = md5_hex.strip().lower()

    domains = _domains()
    api_key = _secret_key()
    headers = {"User-Agent": _USER_AGENT, "Accept-Language": "en-US,en;q=0.9"}

    async with httpx.AsyncClient(
        timeout=httpx.Timeout(35.0),
        headers=headers,
        follow_redirects=True,
    ) as client:
        auth_domain: str | None = None
        if api_key:
            auth_domain = await _authenticate(client, api_key, domains)

        search_domains: tuple[str, ...]
        if auth_domain is not None:
            search_domains = (auth_domain,) + tuple(d for d in domains if d != auth_domain)
        else:
            search_domains = domains

        html, host = await _fetch_md5_html(client, raw, search_domains)

    catalog_fallback = f"https://{domains[0]}/md5/{raw}"
    if not html or not host:
        return AnnaResolveResponse(
            md5=raw,
            catalog_url=catalog_fallback,
            note="Could not fetch the book page (blocked, offline, or layout change). "
            "Open the catalog link in a browser.",
        )

    catalog_url = f"https://{host}/md5/{raw}"
    if _looks_like_challenge_page(html):
        return AnnaResolveResponse(
            md5=raw,
            catalog_url=catalog_url,
            note="Book page looks like a bot challenge. Use a browser session or ANNAS_SECRET_KEY.",
        )

    dl, magnet = parse_md5_download_links(html, catalog_url)
    note: str | None = None
    if dl is None and magnet is None:
        note = (
            "No direct HTTP or magnet link parsed. Many mirrors need a browser "
            "(timers, partner redirects). Use “Open catalog” or a torrent client."
        )

    return AnnaResolveResponse(
        md5=raw,
        catalog_url=catalog_url,
        download_url=dl,
        magnet_url=magnet,
        note=note,
    )


def _looks_like_challenge_page(html: str) -> bool:
    h = html[:8000].lower()
    if "div.flex.pt-3.pb-3.border-b" in html:
        return False
    return (
        "redirecting" in h
        and "<script" in h
        or "challenge" in h
        or "cf-browser-verification" in h
        or "just a moment" in h
    )


async def search_anna_archive(query: str, limit: int = 15) -> list[SearchResult]:
    q = query.strip()
    if not q:
        return []

    domains = _domains()
    api_key = _secret_key()
    headers = {"User-Agent": _USER_AGENT, "Accept-Language": "en-US,en;q=0.9"}

    async with httpx.AsyncClient(
        timeout=httpx.Timeout(25.0),
        headers=headers,
        follow_redirects=True,
    ) as client:
        auth_domain: str | None = None
        if api_key:
            auth_domain = await _authenticate(client, api_key, domains)

        search_domains: tuple[str, ...]
        if auth_domain is not None:
            search_domains = (auth_domain,) + tuple(d for d in domains if d != auth_domain)
        else:
            search_domains = domains

        html, used_domain = await _fetch_search_html(
            client, q, page=1, domains=search_domains
        )

    if not html:
        return []

    catalog_host = used_domain or domains[0]

    if _looks_like_challenge_page(html):
        logger.warning(
            "Anna search: response looks like a bot/JS challenge (no result rows). "
            "Configure ANNAS_SECRET_KEY and retry, or run from an allowed network."
        )
        return []

    parsed = parse_search_results_html(html)
    if not parsed:
        logger.warning(
            "Anna search: parsed zero results (layout change, block, or empty query)."
        )

    results: list[SearchResult] = []
    for row in parsed[:limit]:
        md5 = str(row["md5"])
        title = str(row["title"])
        author_raw = row.get("author")
        author = (author_raw or "").strip() or "Unknown Author"
        fmt_raw = row.get("format")
        fmt = (fmt_raw or "unknown").lower() if fmt_raw else "unknown"

        results.append(
            SearchResult(
                id=f"anna-md5-{md5}",
                title=title,
                author=author,
                source="AnnaArchive",
                format=fmt,
                cover_url=None,
                download_url=None,
                magnet_url=None,
                catalog_url=f"https://{catalog_host}/md5/{md5}",
                confidence=0.68,
            )
        )
    return results
