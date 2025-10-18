
.PHONY: users ssh firewall fail2ban updates logs-audit check all

users:
	sudo bash scripts/01_users.sh
ssh:
	sudo bash scripts/02_ssh.sh
firewall:
	sudo bash scripts/03_firewall.sh
fail2ban:
	sudo bash scripts/04_fail2ban.sh
updates:
	sudo bash scripts/05_updates.sh
logs-audit:
	sudo bash scripts/06_logs_audit.sh
check:
	sudo bash scripts/99_check.sh
all: users ssh firewall fail2ban updates logs-audit check
