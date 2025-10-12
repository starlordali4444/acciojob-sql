# 🍏 PostgreSQL Setup for macOS (Apple Silicon or Intel)

## 🧩 Automated Installation (Recommended)

Use the installation script provided in your **Day 1** folder.

### Steps
```bash
chmod +x install_postgresql_mac.sh
bash install_postgresql_mac.sh
```

The script will:
- Install **Homebrew** (if missing)
- Install **PostgreSQL 16**
- Start PostgreSQL as a background service
- Add PostgreSQL to your PATH
- Verify with:
  ```bash
  psql --version
  ```

---

## 🧠 Manual Verification

Check if PostgreSQL is running:
```bash
brew services list
```
Ensure `postgresql@16` shows as **started**.

To connect to the default database:
```bash
psql postgres
```

---

## 🛠️ Troubleshooting

| Problem | Possible Cause | Solution |
|----------|----------------|-----------|
| `zsh: command not found: brew` | Homebrew not installed | Run:<br>`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| `psql: command not found` | PATH not updated | Restart terminal, or run:<br>`export PATH="/usr/local/opt/postgresql@16/bin:$PATH"` |
| `database "postgres" does not exist` | Default DB missing | Run:<br>`createdb postgres` |
| PostgreSQL won't start | Service not active | Run:<br>`brew services start postgresql@16` |
| Connection errors | Port conflict or old socket | Restart service:<br>`brew services restart postgresql@16` |

> 💡 **Tip:** Always restart Terminal after installation so PATH changes take effect.
