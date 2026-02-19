#!/usr/bin/env bash
set -ouex pipefail 

echo '开始安装terra仓库'
dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
