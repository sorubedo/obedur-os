#!/bin/sh
set -eu

# Enroll Obedur-OS MOK key before first boot.
# Run this AFTER rebasing to Obedur-OS and BEFORE rebooting:
#   curl -fsSL https://raw.githubusercontent.com/sorubedo/obedur-os/main/scripts/enroll-mok.sh | sudo bash

MOK_URL="https://raw.githubusercontent.com/sorubedo/obedur-os/main/MOK.der"
MOK_PASSWORD="obedur"
MOK_ENROLLED_MARKER="/var/.mok-enrolled"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" = "0" ] || die "This script must be run as root."

if command -v mokutil >/dev/null 2>&1; then
    if mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot disabled'; then
        echo "SecureBoot is disabled on this system. No MOK enrollment needed."
        echo "Creating ${MOK_ENROLLED_MARKER} to skip auto-enrollment on boot."
        touch "${MOK_ENROLLED_MARKER}"
        exit 0
    fi
else
    die "mokutil not found. Are you on a UEFI system?"
fi

if [ -f "${MOK_ENROLLED_MARKER}" ]; then
    echo "MOK already enrolled (${MOK_ENROLLED_MARKER} exists)."
    exit 0
fi

MOK_TMP=$(mktemp)
trap 'rm -f ${MOK_TMP}' EXIT

echo "Downloading MOK certificate..."
curl -fsSL --retry 3 -o "${MOK_TMP}" "${MOK_URL}" \
    || die "Failed to download MOK certificate from ${MOK_URL}"

echo "Importing MOK certificate for enrollment on next boot..."
(echo "${MOK_PASSWORD}"; echo "${MOK_PASSWORD}") \
    | mokutil --import "${MOK_TMP}" \
    || die "mokutil --import failed."

touch "${MOK_ENROLLED_MARKER}"

echo ""
echo "=============================================="
echo "  MOK certificate imported successfully."
echo "=============================================="
echo ""
echo "On next boot you will see a blue MOK Manager screen:"
echo "  1. Select 'Enroll MOK'"
echo "  2. Select 'Continue'"
echo "  3. Select 'Yes' to confirm enrollment"
echo "  4. Enter password: ${MOK_PASSWORD}"
echo "  5. Select 'Reboot'"
echo ""
echo "Now reboot to start the process:"
echo "  systemctl reboot"
