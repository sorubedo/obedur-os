#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

USER=$(printf '%s' "$1" | jq -r '.user // "builder"')
SUDO=$(printf '%s' "$1"  | jq -r '.sudo // true')

get_json_array PACKAGES 'try .["packages"][]' "$1"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Create user if needed
# ---------------------------------------------------------------------------

if ! id -u "${USER}" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "${USER}"
fi

# ---------------------------------------------------------------------------
# Configure passwordless sudo
# ---------------------------------------------------------------------------

if [ "${SUDO}" = "true" ]; then
    mkdir -p /etc/sudoers.d
    cat > "/etc/sudoers.d/99-${USER}" <<EOF
${USER} ALL=(ALL) NOPASSWD: ALL
EOF
    chmod 0440 "/etc/sudoers.d/99-${USER}"
fi

# ---------------------------------------------------------------------------
# Configure paru
# ---------------------------------------------------------------------------

HOME_DIR=$(eval echo "~${USER}")
PARU_CONF="${HOME_DIR}/.config/paru/paru.conf"

mkdir -p "$(dirname "${PARU_CONF}")"

if [ ! -f "${PARU_CONF}" ]; then
    cat > "${PARU_CONF}" <<'EOF'
[options]
BottomUp
RemoveMake
SudoLoop
CombinedUpgrade
CleanAfter
UpgradeMenu
NewsOnUpgrade
EOF
    chown -R "${USER}:${USER}" "$(dirname "${PARU_CONF}")"
fi

# ---------------------------------------------------------------------------
# Install AUR packages
# ---------------------------------------------------------------------------

runuser -u "${USER}" -- paru -S --noconfirm --needed "${PACKAGES[@]}"

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

rm -rf "${HOME_DIR}/.cache/paru" || true
