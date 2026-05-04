#!/usr/bin/env bash

set -euo pipefail

PROJECT_PATH="${1:-Apricot.xcodeproj}"
SCHEME_NAME="${2:-Apricot}"
REQUESTED_DEVICE_NAME="${3:-}"

destinations_output="$(xcodebuild -showdestinations -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" 2>/dev/null || true)"

available_simulator_lines="$(
    printf '%s\n' "$destinations_output" \
        | grep 'platform:iOS Simulator' \
        | grep -v 'placeholder' || true
)"

if [[ -z "$available_simulator_lines" ]]; then
    echo "No available iOS Simulator destination found for scheme '$SCHEME_NAME'." >&2
    printf '%s\n' "$destinations_output" >&2
    exit 1
fi

if [[ -n "$REQUESTED_DEVICE_NAME" ]]; then
    simulator_line="$(
        printf '%s\n' "$available_simulator_lines" \
            | grep "name:$REQUESTED_DEVICE_NAME" \
            | head -n 1
    )"

    if [[ -z "$simulator_line" ]]; then
        echo "Required iOS Simulator '$REQUESTED_DEVICE_NAME' is not available for scheme '$SCHEME_NAME'." >&2
        echo "Available simulator destinations:" >&2
        printf '%s\n' "$available_simulator_lines" >&2
        exit 1
    fi
else
    simulator_line="$(printf '%s\n' "$available_simulator_lines" | head -n 1)"
fi

simulator_id="$(printf '%s\n' "$simulator_line" | sed -nE 's/.*id:([^,}]+).*/\1/p')"

if [[ -z "$simulator_id" ]]; then
    echo "Failed to extract simulator id from destination: $simulator_line" >&2
    exit 1
fi

printf 'id=%s\n' "$simulator_id"
