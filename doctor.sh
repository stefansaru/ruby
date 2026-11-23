#!/usr/bin/env bash
# The commit gates, in order. Stops at the first failure.
# See docs/Testing.md for the reason behind each.
set -euo pipefail
cd "$(dirname "$0")"

echo "== 1/4 flutter analyze"
flutter analyze

echo "== 2/4 flutter test"
flutter test --reporter=failures-only

echo "== 3/4 packs are what the generator makes"
dart run tool/generate_cases.dart --dry-run

echo "== 4/4 every case: one answer, no guessing"
dart run tool/check_cases.dart

echo "All gates green."
