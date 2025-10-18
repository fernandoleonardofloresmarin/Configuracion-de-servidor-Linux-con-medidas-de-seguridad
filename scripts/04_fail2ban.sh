
#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Ejecuta como root"; exit 1; }

apt-get update -y
apt-get install -y fail2ban

install -d -m 755 /etc/fail2ban
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
findtime = 10m
bantime = 1h
maxretry = 5
destemail = root@localhost
sender = fail2ban@$(hostname -f)
banaction = ufw

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
backend = systemd
EOF

systemctl enable fail2ban
systemctl restart fail2ban
fail2ban-client status
echo "[OK] fail2ban activo con jail sshd."
