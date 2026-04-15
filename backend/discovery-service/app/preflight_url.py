"""Validate URLs for /download/preflight to reduce SSRF risk."""

from __future__ import annotations

import ipaddress
import os
import re
from urllib.parse import urlparse

_BLOCKED_HOSTNAMES = frozenset(
    {
        "localhost",
        "127.0.0.1",
        "::1",
        "0.0.0.0",
        "metadata.google.internal",
        "metadata",
    }
)


def is_safe_preflight_url(url: str) -> tuple[bool, str | None]:
    raw = (url or "").strip()
    if not raw or len(raw) > 2048:
        return False, "Invalid or too long URL"

    parsed = urlparse(raw)
    scheme = (parsed.scheme or "").lower()
    allow_http = os.getenv("ALLOW_HTTP_PREFLIGHT", "").strip() == "1"

    if scheme == "https":
        pass
    elif scheme == "http" and allow_http:
        pass
    else:
        if scheme == "http":
            return False, "http not allowed (set ALLOW_HTTP_PREFLIGHT=1 for dev only)"
        return False, "Only http(s) URLs are allowed"

    host = parsed.hostname
    if not host:
        return False, "Missing host"

    host_lower = host.lower()
    if host_lower in _BLOCKED_HOSTNAMES:
        return False, "Host not allowed"

    # *.localhost (RFC 6761)
    if host_lower.endswith(".localhost"):
        return False, "Host not allowed"

    # Numeric IP — block private / loopback / link-local / multicast
    try:
        ip = ipaddress.ip_address(host)
        if (
            ip.is_private
            or ip.is_loopback
            or ip.is_link_local
            or ip.is_multicast
            or ip.is_reserved
            or ip.is_unspecified
        ):
            return False, "IP range not allowed"
    except ValueError:
        pass

    # Block obvious internal host patterns (DNS resolution not validated here)
    if re.match(r"^169\.254\.", host_lower):
        return False, "IP range not allowed"

    return True, None
