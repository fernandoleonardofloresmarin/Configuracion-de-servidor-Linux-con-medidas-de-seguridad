
#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Ejecuta como root"; exit 1; }

apt-get update -y
apt-get install -y rsyslog logrotate auditd

# Logrotate ejemplo para una app cualquiera
install -m 644 /dev/stdin /etc/logrotate.d/app-example <<'EOF'
/var/log/app-example/*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
  create 0640 root adm
  sharedscripts
  postrotate
    systemctl reload rsyslog >/dev/null 2>&1 || true
  endscript
}
EOF

# Reglas básicas de auditd (modificaciones de passwd, sudoers, etc.)
install -d -m 755 /etc/audit/rules.d
install -m 640 /dev/stdin /etc/audit/rules.d/hardening.rules <<'EOF'
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k priv_esc
-w /etc/ssh/sshd_config -p wa -k ssh
-w /etc/ssh/sshd_config.d/ -p wa -k ssh
-w /var/log/auth.log -p r -k auth
-w /etc/fail2ban/jail.local -p wa -k f2b
EOF

augenrules --load || true
systemctl enable auditd
systemctl restart auditd
systemctl restart rsyslog

echo "[OK] Logs y auditoría configurados."
