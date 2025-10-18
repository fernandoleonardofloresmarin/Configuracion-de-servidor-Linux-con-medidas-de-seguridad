
#!/usr/bin/env bash
set -euo pipefail

echo "== Verificaciones básicas =="
echo "[SSH] Puerto configurado:"
grep -E '^Port\s+' /etc/ssh/sshd_config || echo "Port 22 (por defecto)"
echo

echo "[SSH] Hardening includes:"
ls -l /etc/ssh/sshd_config.d || true
echo

echo "[UFW] Estado:"
ufw status verbose || true
echo

echo "[fail2ban] Estado:"
systemctl is-active --quiet fail2ban && fail2ban-client status || echo "fail2ban no activo"
echo

echo "[auditd] Reglas cargadas:"
auditctl -l | head -n 20 || true
echo

echo "[logrotate] Archivos en /etc/logrotate.d:"
ls -1 /etc/logrotate.d | sed 's/^/ - /' || true
echo

echo "[OK] Revisión completada."
