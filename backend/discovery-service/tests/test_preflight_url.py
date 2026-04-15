import unittest

from app.preflight_url import is_safe_preflight_url


class PreflightUrlTests(unittest.TestCase):
    def test_https_public_ok(self) -> None:
        ok, reason = is_safe_preflight_url("https://example.org/file.epub")
        self.assertTrue(ok, reason)

    def test_localhost_blocked(self) -> None:
        ok, _ = is_safe_preflight_url("https://localhost/x")
        self.assertFalse(ok)

    def test_private_ip_blocked(self) -> None:
        ok, _ = is_safe_preflight_url("https://10.0.0.1/x")
        self.assertFalse(ok)

    def test_http_blocked_by_default(self) -> None:
        ok, _ = is_safe_preflight_url("http://example.org/x")
        self.assertFalse(ok)


if __name__ == "__main__":
    unittest.main()
