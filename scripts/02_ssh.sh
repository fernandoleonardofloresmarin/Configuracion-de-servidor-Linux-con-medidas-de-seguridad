
#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Ejecuta como root"; exit 1; }

set -a; [[ -f ".env" ]] && source .env || true; set +a
SSH_PORT="${SSH_PORT:-22}"
ADMIN_USER="${ADMIN_USER:-deploy}"

apt-get update -y
apt-get install -y openssh-server

# Hardening via include dir
install -d -m 755 /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
# Deshabilita root login y auth por contraseña
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PermitEmptyPasswords no
X11Forwarding no
AllowAgentForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
# Limita a usuarios explícitos
# Completa AllowUsers en tiempo de ejecución
EOF

# Asegurar AllowUsers
echo "AllowUsers ${ADMIN_USER}" >> /etc/ssh/sshd_config.d/10-hardening.conf

# Puerto SSH
if ! grep -q -E "^Port\s+${SSH_PORT}$" /etc/ssh/sshd_config; then
  sed -i '/^#\?Port /d' /etc/ssh/sshd_config
  echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config
fi

systemctl enable ssh
systemctl restart ssh
echo "[OK] SSH endurecido en puerto ${SSH_PORT}. Recuerda probar acceso nuevo antes de cerrar sesión."
