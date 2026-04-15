#!/usr/bin/env bash
set -euo pipefail

echo "Two-device validation helper"
echo "1) Ensure both devices are signed in with same account."
echo "2) Run sync on Device A, then Device B."
echo "3) Capture screenshots for import, progress, annotation delete."
echo "4) Export backup JSON on both devices."
echo "5) Record outcomes in docs/two_device_validation.md"

