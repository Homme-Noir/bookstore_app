from pydantic import BaseModel, Field


class SearchResult(BaseModel):
    id: str
    title: str
    author: str
    source: str
    format: str = "unknown"
    cover_url: str | None = None
    download_url: str | None = None
    magnet_url: str | None = None
    catalog_url: str | None = None
    confidence: float = Field(default=0.5, ge=0, le=1)


class AnnaResolveResponse(BaseModel):
    md5: str
    catalog_url: str
    download_url: str | None = None
    magnet_url: str | None = None
    note: str | None = None


class SearchResponse(BaseModel):
    query: str
    results: list[SearchResult]


class DownloadPreflightRequest(BaseModel):
    url: str


class DownloadPreflightResponse(BaseModel):
    allowed: bool
    mime_type: str | None = None
    content_length: int | None = None
    reason: str | None = None
