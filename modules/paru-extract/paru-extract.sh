#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

OUTPUT=$(printf '%s' "$1" | jq -r '.output // ""')

get_json_array PACKAGES 'try .["packages"][]' "$1"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    exit 0
fi

if [ -z "${OUTPUT}" ]; then
    echo '[paru-extract] Error: output is required.' >&2
    exit 1
fi

mkdir -p "${OUTPUT}"

# ---------------------------------------------------------------------------
# Extract
# ---------------------------------------------------------------------------

for pkg in "${PACKAGES[@]}"; do
    pacman -Ql "${pkg}" 2>/dev/null | while read -r line; do
        f="${line#* }"
        [ -n "${f}" ] || continue

        _rel="${f#/}"
        _dest="${OUTPUT}/${_rel}"

        if [ -L "${f}" ]; then
            mkdir -p "$(dirname "${_dest}")"
            cp -a "${f}" "${_dest}"
        elif [ -d "${f}" ]; then
            mkdir -p "${_dest}"
        elif [ -f "${f}" ]; then
            mkdir -p "$(dirname "${_dest}")"
            cp -a "${f}" "${_dest}"
        fi
    done
done
