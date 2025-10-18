
#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Ejecuta como root"; exit 1; }

set -a; [[ -f ".env" ]] && source .env || true; set +a
SSH_PORT="${SSH_PORT:-22}"
UFW_ALLOW_CIDRS="${UFW_ALLOW_CIDRS:-0.0.0.0/0}"
EXTRA_TCP_PORTS="${EXTRA_TCP_PORTS:-}"

apt-get update -y
apt-get install -y ufw

ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Permite SSH limitado por CIDR(s)
IFS=',' read -ra CIDRS <<< "$UFW_ALLOW_CIDRS"
for cidr in "${CIDRS[@]}"; do
  cidr_trim=$(echo "$cidr" | xargs)
  [[ -n "$cidr_trim" ]] && ufw allow from "$cidr_trim" to any port "$SSH_PORT" proto tcp
done

# Puertos extra
IFS=',' read -ra PORTS <<< "$EXTRA_TCP_PORTS"
for p in "${PORTS[@]}"; do
  p_trim=$(echo "$p" | xargs)
  [[ -n "$p_trim" ]] && ufw allow "$p_trim"/tcp
done

ufw --force enable
ufw status verbose
echo "[OK] UFW habilitado con política restrictiva."
