# 🪟 PostgreSQL & pgAdmin 4 Setup for Windows

## 1️⃣ Download the Installer

➡️ Visit: [EnterpriseDB - PostgreSQL Downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)

---

## 2️⃣ Installation Steps

Select all these components:
- ✅ PostgreSQL Server  
- ✅ pgAdmin 4  
- ✅ Command Line Tools  

Keep defaults:
- Port → `5432`  
- Username → `postgres`  
- Password → *(your choice)*

---

## 3️⃣ Verify the Installation

Open **Command Prompt** and type:
```bash
psql -U postgres
```

If you see:
```
postgres=#
```
you’re successfully connected 🎉

---

## 4️⃣ Create a Test Database

Run:
```sql
CREATE DATABASE retailmart;
\c retailmart;
```

---

## 🛠️ Troubleshooting

| Problem | Cause | Fix |
|----------|--------|-----|
| `psql is not recognized` | PATH not set | Reinstall PostgreSQL → check **Add to PATH** during install, or manually add `C:\Program Files\PostgreSQL\16\bin` |
| Forgot postgres password | Misplaced credentials | Open **pgAdmin 4** → right-click *Server* → Properties → change password |
| Connection refused | PostgreSQL service stopped | Open **Services.msc** → find *postgresql* → right-click → **Start** |
| Access denied | Not running as admin | Run Command Prompt as **Administrator** |
| pgAdmin connection error | Wrong host/port | Use `localhost` and port `5432` |

> 💡 **Tip:** Reboot after installation if `psql` isn’t recognized.
