#!/usr/bin/env bash
set -euo pipefail

log()   { printf '[paru-extract] %s\n' "$*"; }
detail(){ printf '[paru-extract]   %s\n' "$*"; }
err()   { printf '[paru-extract] Error: %s\n' "$*" >&2; }

log "Starting paru-extract module..."

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

OUTPUT=$(printf '%s' "$1" | jq -r '.output // ""')

get_json_array PACKAGES 'try .["packages"][]' "$1"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    log "No packages specified, nothing to do."
    exit 0
fi

if [ -z "${OUTPUT}" ]; then
    err "output is required."
    exit 1
fi

log "Packages: ${PACKAGES[*]}"
log "Output: ${OUTPUT}"

mkdir -p "${OUTPUT}"

# ---------------------------------------------------------------------------
# Extract
# ---------------------------------------------------------------------------

_total_entries=0

for pkg in "${PACKAGES[@]}"; do
    log "Extracting files from '${pkg}'..."

    # Read pacman -Ql into a file first — avoid pipefail from pacman|while
    _ql=$(mktemp)
    _list=$(mktemp)
    pacman -Ql "${pkg}" > "${_ql}" 2>/dev/null || true

    while read -r line; do
        f="${line#* }"
        [ -n "${f}" ] || continue

        _rel="${f#/}"
        printf '%s\n' "${_rel}" >> "${_list}"

        _dest="${OUTPUT}/${_rel}"

        if [ -d "${f}" ]; then
            mkdir -p "${_dest}"
        elif [ -f "${f}" ] || [ -L "${f}" ]; then
            mkdir -p "$(dirname "${_dest}")"
            cp -a "${f}" "${_dest}"
        fi
    done < "${_ql}"

    _count=$(wc -l < "${_list}")
    _total_entries=$((_total_entries + _count))

    log "  ${_count} entries (files + dirs + symlinks)"

    if [ "${_count}" -gt 0 ]; then
        log "  ── file tree ─────────────────────"
        (cd "${OUTPUT}" && find . | sort | sed 's|[^/]*/|  |g; s|^  ||') > "${_list}"
        while read -r _line; do
            detail "${_line}"
        done < "${_list}"
        log "  ──────────────────────────────────"
    fi

    rm -f "${_ql}" "${_list}"
done

log "Extraction complete. Total entries across all packages: ${_total_entries}"