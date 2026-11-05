#!/usr/bin/env bash
# Runs every test file against the plugin in this checkout. The tests stub out
# the network, so they run offline.
set -euo pipefail

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0
for test in "$plugin_dir"/test/*_test.lua; do
  echo "# ${test#"$plugin_dir"/}"
  lua "$test" "$plugin_dir" || status=1
done
exit "$status"
