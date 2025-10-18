
# Linux Secure Server (Ubuntu/Debian)
Proyecto mínimo y didáctico para **configurar un servidor Linux** con medidas de seguridad básicas: **usuarios**, **SSH**, **firewall (UFW)**, **fail2ban**, **logs** y **auditoría**. Pensado para mostrar buenas prácticas y que se pueda ejecutar paso a paso.

> ⚠️ Requisitos: Ubuntu/Debian limpio (o similar), acceso sudo, y conexión SSH. ¡Primero **lee** antes de ejecutar!

## Qué incluye
- Creación de usuarios de servicio y configuración de `sudo` segura.
- Endurecimiento de SSH (sin root login, sin password auth, `AllowUsers`).
- Firewall con **UFW** (política restrictiva + puertos explícitos).
- **fail2ban** con una `jail.local` mínima para `sshd`.
- Activación de **unattended-upgrades** para parches automáticos.
- Configuración de **logrotate** dedicada y nociones de **auditd**.
- Script de **verificación** post-configuración.
- CI opcional con ShellCheck para linting de scripts (GitHub Actions).

## Estructura
```
linux-secure-server/
├─ scripts/
│  ├─ 01_users.sh
│  ├─ 02_ssh.sh
│  ├─ 03_firewall.sh
│  ├─ 04_fail2ban.sh
│  ├─ 05_updates.sh
│  ├─ 06_logs_audit.sh
│  └─ 99_check.sh
├─ config/
│  ├─ sshd_config.d/10-hardening.conf
│  ├─ fail2ban/jail.local
│  ├─ logrotate.d/app-example
│  └─ audit/rules.d/hardening.rules
├─ .github/workflows/shellcheck.yml
├─ .env.example
├─ LICENSE
└─ Makefile
```

## Uso rápido
1. **Clona y ajusta variables**:
   ```bash
   git clone https://github.com/fernandoleonardofloresmarin/linux-secure-server.git
   cd linux-secure-server
   cp .env.example .env
   # edita .env (usuarios, puertos, etc.)
   ```

2. **Ejecuta paso a paso (recomendado) o todo con Make**:
   ```bash
   sudo bash scripts/01_users.sh
   sudo bash scripts/02_ssh.sh
   sudo bash scripts/03_firewall.sh
   sudo bash scripts/04_fail2ban.sh
   sudo bash scripts/05_updates.sh
   sudo bash scripts/06_logs_audit.sh
   sudo bash scripts/99_check.sh
   # o
   sudo make all
   ```

3. **Verifica** (nuevo SSH desde otra terminal antes de cerrar tu sesión actual).

## Variables (.env)
```
ADMIN_USER=deploy
ADMIN_PUBKEY="ssh-ed25519 AAAA.... tu@equipo"
SSH_PORT=22
UFW_ALLOW_CIDRS="0.0.0.0/0"
EXTRA_TCP_PORTS="80,443"
```
- `ADMIN_USER`: usuario admin con sudo sin password para tareas (puedes ajustarlo).
- `ADMIN_PUBKEY`: tu clave pública para acceso sin contraseña.
- `SSH_PORT`: puerto para `sshd` (mantén 22 si no sabes por qué cambiarlo).
- `UFW_ALLOW_CIDRS`: rangos permitidos a SSH (reduce a tu IP si puedes).
- `EXTRA_TCP_PORTS`: puertos de apps que necesites abrir.

## Buenas prácticas
- No elimines tu sesión actual hasta validar el acceso nuevo.
- Haz **backup** de configs antes de reemplazarlas.
- Repite `99_check.sh` tras cada cambio.
- Revisa `/var/log/auth.log`, `journalctl -u ssh` y `fail2ban-client status`.

## Licencia
MIT — ver [LICENSE](LICENSE).
