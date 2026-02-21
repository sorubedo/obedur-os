#!/usr/bin/env bash

# 遇到错误时中止执行，确保构建安全
set -oue pipefail

echo 'run add-dracut-modules.sh'

# 添加 fido2 模块
mkdir -p /etc/dracut.conf.d
echo 'add_dracutmodules+=" fido2 "' > /etc/dracut.conf.d/fido2.conf

# 安装 dracut-numlock 模块
echo '开始安装 dracut-numlock...'

# 克隆仓库到临时目录
git clone https://github.com/ChrTall/dracut-numlock.git /tmp/dracut-numlock

# 复制模块文件到 dracut 目录
cp -r /tmp/dracut-numlock/51numlock /usr/lib/dracut/modules.d/

# 清理临时文件
rm -rf /tmp/dracut-numlock

echo 'dracut-numlock 安装完成！'
