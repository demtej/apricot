#!/usr/bin/env bash

set -euo pipefail

REQUESTED_DEVICE_NAME="${1:-}"

available_devices="$(xcrun simctl list devices available 2>&1)"

if [[ -n "$REQUESTED_DEVICE_NAME" ]]; then
    simulator_line="$(
        printf '%s\n' "$available_devices" \
            | grep "$REQUESTED_DEVICE_NAME" \
            | head -n 1 \
            || true
    )"

    if [[ -z "$simulator_line" ]]; then
        echo "Required iOS Simulator '$REQUESTED_DEVICE_NAME' is not available." >&2
        echo "Available simulators:" >&2
        printf '%s\n' "$available_devices" >&2
        exit 1
    fi
else
    simulator_line="$(
        printf '%s\n' "$available_devices" \
            | grep 'iPhone' \
            | head -n 1 \
            || true
    )"

    if [[ -z "$simulator_line" ]]; then
        echo "No available iPhone simulator found." >&2
        printf '%s\n' "$available_devices" >&2
        exit 1
    fi
fi

simulator_id="$(
    printf '%s\n' "$simulator_line" \
        | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' \
        | head -n 1 \
        || true
)"

if [[ -z "$simulator_id" ]]; then
    echo "Failed to extract simulator UDID from: $simulator_line" >&2
    exit 1
fi

printf 'id=%s\n' "$simulator_id"
