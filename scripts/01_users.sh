
#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Debes ejecutar como root (usa sudo)"; exit 1
fi

# Carga .env si existe
if [[ -f ".env" ]]; then
  set -a; source .env; set +a
fi

ADMIN_USER="${ADMIN_USER:-deploy}"
ADMIN_PUBKEY="${ADMIN_PUBKEY:-}"
GROUP="sudo"

id -u "$ADMIN_USER" &>/dev/null || useradd -m -s /bin/bash "$ADMIN_USER"
usermod -aG "$GROUP" "$ADMIN_USER"

install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "/home/$ADMIN_USER/.ssh"
if [[ -n "$ADMIN_PUBKEY" ]]; then
  echo "$ADMIN_PUBKEY" > "/home/$ADMIN_USER/.ssh/authorized_keys"
  chown "$ADMIN_USER:$ADMIN_USER" "/home/$ADMIN_USER/.ssh/authorized_keys"
  chmod 600 "/home/$ADMIN_USER/.ssh/authorized_keys"
fi

# Sudo sin password SOLO para mantenimiento (ajústalo si quieres pedir pass)
echo "%$GROUP ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/99-${GROUP}-nopasswd
chmod 440 /etc/sudoers.d/99-${GROUP}-nopasswd

echo "[OK] Usuario $ADMIN_USER listo con sudo y clave pública configurada."
