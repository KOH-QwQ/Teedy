#!/bin/bash
# Tutorial 10: allow Jenkins to use Docker (run once with sudo)
set -euo pipefail
if [[ "$(id -u)" -ne 0 ]]; then
  echo "请使用 sudo 运行: sudo bash scripts/jenkins-docker-setup.sh"
  exit 1
fi
usermod -aG docker jenkins
systemctl restart jenkins
echo "已将 jenkins 加入 docker 组并重启 Jenkins。"
echo "验证: sudo -u jenkins docker ps"
