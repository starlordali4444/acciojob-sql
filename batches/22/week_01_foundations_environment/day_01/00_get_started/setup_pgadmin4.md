# 🧩 pgAdmin 4 Setup Guide

## 1️⃣ Download pgAdmin 4

- macOS → [pgAdmin 4 macOS](https://www.pgadmin.org/download/pgadmin-4-macos/)
- Windows → [pgAdmin 4 Windows](https://www.pgadmin.org/download/pgadmin-4-windows/)

---

## 2️⃣ Create a Server Connection

1. Open **pgAdmin 4**
2. Click **Create → Server**
3. Fill in:
   - **Name:** PostgreSQL  
   - **Host:** localhost  
   - **Port:** 5432  
   - **Username:** postgres  
   - **Password:** *(your password)*  
4. Click **Save**

---

## 3️⃣ Verify Connection

In the sidebar:
```
Servers → PostgreSQL → Databases
```
You should see `postgres` and any other databases (like `retailmart`).

---

## 🛠️ Troubleshooting

| Issue | Reason | Solution |
|-------|---------|-----------|
| pgAdmin won’t open | Browser cache issue | Quit pgAdmin → restart it |
| “Connection refused” | PostgreSQL not running | mac → `brew services start postgresql@16`<br>Windows → start service in **Services.msc** |
| Forgot pgAdmin password | Stored credentials outdated | File → **Reset Master Password** |
| Database missing | View filter applied | Right-click **Databases** → Refresh |

> 💡 **Tip:** Use pgAdmin mainly for visualization and schema browsing.
