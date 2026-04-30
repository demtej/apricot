#!/usr/bin/env bash

set -euo pipefail

PROJECT_PATH="${1:-Apricot.xcodeproj}"
SCHEME_NAME="${2:-Apricot}"

destinations_output="$(xcodebuild -showdestinations -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" 2>/dev/null || true)"

simulator_line="$(
    printf '%s\n' "$destinations_output" \
        | grep 'platform:iOS Simulator' \
        | grep -v 'placeholder' \
        | head -n 1
)"

if [[ -z "$simulator_line" ]]; then
    echo "No available iOS Simulator destination found for scheme '$SCHEME_NAME'." >&2
    printf '%s\n' "$destinations_output" >&2
    exit 1
fi

simulator_id="$(printf '%s\n' "$simulator_line" | sed -nE 's/.*id:([^,}]+).*/\1/p')"

if [[ -z "$simulator_id" ]]; then
    echo "Failed to extract simulator id from destination: $simulator_line" >&2
    exit 1
fi

printf 'id=%s\n' "$simulator_id"
