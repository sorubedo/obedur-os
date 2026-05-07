#!/usr/bin/env bash
set -euo pipefail

EXEC=$(printf '%s' "$1" | jq -r '.exec // ""')

get_json_array ENV_VARS 'try (.env // {}) | to_entries[] | "\(.key)=\(.value)"' "$1"

ENV_LINES=$(printf 'Environment=%s\n' "${ENV_VARS[@]}")

# --- sysusers.d ---
mkdir -p /usr/lib/sysusers.d

cat > /usr/lib/sysusers.d/oobe.conf <<EOF
#Type Name   ID    GECOS           Home directory  Shell
u     oobe   -     "OOBE Setup User" /var/lib/oobe   /usr/sbin/nologin
EOF

# --- tmpfiles.d (为 oobe 用户创建主目录) ---
mkdir -p /usr/lib/tmpfiles.d
cat > /usr/lib/tmpfiles.d/oobe.conf <<EOF
d /var/lib/oobe 0750 oobe oobe - -
Z /var/lib/oobe - oobe oobe - -
EOF

# --- pam.d ---
mkdir -p /etc/pam.d
cat > /etc/pam.d/oobe <<EOF
#%PAM-1.0
auth       required     pam_permit.so
account    required     pam_permit.so
password   required     pam_permit.so
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    required     pam_selinux.so open
session    optional     pam_keyinit.so force revoke
session    required     pam_systemd.so
EOF

# --- oobe-wizard ---
cat > /usr/bin/oobe-wizard <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

while true; do
    read -r -p "用户名: " USERNAME
    if [[ "${USERNAME}" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        break
    fi
    echo "无效的用户名，必须以小写字母或下划线开头，仅包含小写字母、数字、连字符和下划线。"
done

while true; do
    read -r -s -p "密码: " PASSWORD
    echo
    read -r -s -p "确认密码: " PASSWORD_CONFIRM
    echo
    if [[ "${PASSWORD}" == "${PASSWORD_CONFIRM}" ]] && [[ -n "${PASSWORD}" ]]; then
        break
    fi
    echo "两次密码不一致或密码为空，请重试。"
done

pkexec useradd -m -G wheel -s /usr/bin/fish "${USERNAME}"
printf '%s:%s' "${USERNAME}" "${PASSWORD}" | pkexec chpasswd

echo "用户 '${USERNAME}' 创建成功。"
pkexec touch /var/.oobe-done
read -r -s -n 1 -p "按任意键继续..."
echo
EOF

chmod +x /usr/bin/oobe-wizard

# --- polkit ---
mkdir -p /usr/share/polkit-1/rules.d

cat > /usr/share/polkit-1/rules.d/50-oobe.rules <<'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        subject.isInGroup("oobe")) {
        var program = action.lookup("program");
        if (program == "/usr/sbin/useradd" || program == "/usr/bin/chpasswd" || program == "/usr/bin/touch") {
            return polkit.Result.YES;
        }
    }
});
EOF

# 生成 systemd service ---
mkdir -p /usr/lib/systemd/system

cat > /usr/lib/systemd/system/oobe.service <<SVC_EOF
[Unit]
Description=OOBE Initial Setup
After=systemd-user-sessions.service dbus.socket systemd-logind.service systemd-vconsole-setup.service plymouth-quit-wait.service
Wants=getty-pre.target dbus.socket systemd-logind.service
Before=getty-pre.target display-manager.service
Conflicts=initial-setup-text.service initial-setup-graphical.service initial-setup.service plymouth-quit-wait.service
ConditionKernelCommandLine=!rd.live.image
ConditionPathExists=!/var/.oobe-done

[Service]
Type=oneshot
TimeoutSec=0
RemainAfterExit=no
User=oobe
PAMName=oobe
ExecStartPre=-/bin/plymouth quit
ExecStartPre=+sh -c "exec chvt 7"
${ENV_LINES}
ExecStart=${EXEC}
ExecStopPost=+sh -c "exec chvt 1"
TTYPath=/dev/tty7
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
UtmpIdentifier=tty7
UtmpMode=user
StandardInput=tty-fail

[Install]
WantedBy=graphical.target
WantedBy=multi-user.target
SVC_EOF

systemctl -f enable oobe.service
