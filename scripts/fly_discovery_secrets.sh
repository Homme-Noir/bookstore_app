#!/usr/bin/env bash
# Sets Fly.io secrets for the discovery service.
# Prerequisites: fly CLI installed and logged in (`fly auth login`).
#
# Usage:
#   export ANNAS_SECRET_KEY='your-donation-key'
#   ./scripts/fly_discovery_secrets.sh
#
# Optional exports: ANNAS_API_KEY, ANNAS_BASE_URL, ALLOW_HTTP_PREFLIGHT
# Override app name: FLY_DISCOVERY_APP=my-app

set -euo pipefail

APP="${FLY_DISCOVERY_APP:-bookstore-discovery}"
DIR="$(cd "$(dirname "$0")/../backend/discovery-service" && pwd)"
cd "$DIR"

if ! command -v fly >/dev/null 2>&1; then
  echo "Install Fly CLI: https://fly.io/docs/hands-on/install-flyctl/"
  exit 1
fi

PAIRS=()
[[ -n "${ANNAS_SECRET_KEY:-}" ]] && PAIRS+=("ANNAS_SECRET_KEY=${ANNAS_SECRET_KEY}")
[[ -n "${ANNAS_API_KEY:-}" ]] && PAIRS+=("ANNAS_API_KEY=${ANNAS_API_KEY}")
[[ -n "${ANNAS_BASE_URL:-}" ]] && PAIRS+=("ANNAS_BASE_URL=${ANNAS_BASE_URL}")
[[ -n "${ALLOW_HTTP_PREFLIGHT:-}" ]] && PAIRS+=("ALLOW_HTTP_PREFLIGHT=${ALLOW_HTTP_PREFLIGHT}")

if [[ ${#PAIRS[@]} -eq 0 ]]; then
  echo "No secrets to set. Export at least one of:"
  echo "  ANNAS_SECRET_KEY or ANNAS_API_KEY"
  echo ""
  echo "Example:"
  echo "  export ANNAS_SECRET_KEY='...'"
  echo "  $0"
  exit 1
fi

echo "Setting secrets on Fly app: $APP"
fly secrets set "${PAIRS[@]}" -a "$APP"
