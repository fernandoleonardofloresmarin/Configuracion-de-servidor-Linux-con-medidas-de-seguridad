
#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Ejecuta como root"; exit 1; }

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y unattended-upgrades

dpkg-reconfigure -f noninteractive unattended-upgrades
sed -i 's#^//\?Unattended-Upgrade::Automatic-Reboot.*#Unattended-Upgrade::Automatic-Reboot "true";#' /etc/apt/apt.conf.d/50unattended-upgrades || true

systemctl restart unattended-upgrades || true
echo "[OK] Actualizaciones automáticas habilitadas."
