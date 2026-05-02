#!/usr/bin/env bash
set -euo pipefail

log() { printf '[paru] %s\n' "$*"; }
err() { printf '[paru] Error: %s\n' "$*" >&2; }

log "Starting paru module..."

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

USER=$(printf '%s' "$1" | jq -r '.user // "builder"')
SUDO=$(printf '%s' "$1"  | jq -r '.sudo // true')

get_json_array PACKAGES 'try .["packages"][]' "$1"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    log "No packages specified, nothing to do."
    exit 0
fi

log "User: ${USER}"
log "Packages: ${PACKAGES[*]}"

# ---------------------------------------------------------------------------
# Create user if needed
# ---------------------------------------------------------------------------

if ! id -u "${USER}" >/dev/null 2>&1; then
    log "Creating user '${USER}'."
    useradd -m -s /bin/bash "${USER}"
fi

# ---------------------------------------------------------------------------
# Configure passwordless sudo
# ---------------------------------------------------------------------------

if [ "${SUDO}" = "true" ]; then
    log "Configuring passwordless sudo for '${USER}'."
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
LocalRepo
EOF
    chown -R "${USER}:${USER}" "$(dirname "${PARU_CONF}")"
fi

# ---------------------------------------------------------------------------
# Configure local repo (required by paru's LocalRepo)
# ---------------------------------------------------------------------------

LOCAL_REPO_DIR="/var/lib/repo/aur"

if ! grep -q '^\[aur\]' /etc/pacman.conf 2>/dev/null; then
    log "Adding local aur repo to /etc/pacman.conf."
    mkdir -p "${LOCAL_REPO_DIR}"
    cat >> /etc/pacman.conf <<EOF

[aur]
SigLevel = PackageOptional DatabaseOptional
Server = file://${LOCAL_REPO_DIR}
EOF
fi

log "Initializing local repo with paru -Ly..."
runuser -u "${USER}" -- paru -Ly --noconfirm

# ---------------------------------------------------------------------------
# Install AUR packages
# ---------------------------------------------------------------------------

log "Installing AUR packages as '${USER}'..."

# paru cannot run as root - use sudo -u to run as the non-root user.
# --noconfirm to avoid interactive prompts during build.
# --needed to skip already-installed packages.
runuser -u "${USER}" -- paru -S --noconfirm --needed "${PACKAGES[@]}"

log "AUR package installation complete."

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

log "Cleaning paru cache."
rm -rf "${HOME_DIR}/.cache/paru" || true

log "paru module finished."