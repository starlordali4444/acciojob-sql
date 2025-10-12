# 💻 Azure Data Studio (ADS) Setup for PostgreSQL

## 1️⃣ Download & Install

Download from:  
[Microsoft - Azure Data Studio](https://learn.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio)

---

## 2️⃣ Add the PostgreSQL Extension

1. Open **ADS**
2. Go to the **Extensions** tab (square icon on sidebar)
3. Search for **PostgreSQL**
4. Click **Install**

---

## 3️⃣ Connect to PostgreSQL

| Field | Value |
|-------|--------|
| **Server** | localhost |
| **Port** | 5432 |
| **User** | postgres |
| **Password** | *(your password)* |
| **Database** | retailmart |

Click **Connect** ✅  
You can now run `.sql` files such as `query.sql`.

---

## 🛠️ Troubleshooting

| Problem | Likely Cause | Solution |
|----------|---------------|-----------|
| “Connection refused” | PostgreSQL not started | mac → `brew services start postgresql@16`<br>Windows → start via **Services.msc** |
| “Authentication failed” | Wrong password | Manage Connections → Edit → re-enter credentials |
| PostgreSQL extension missing | Not installed properly | Reopen ADS → Extensions → reinstall PostgreSQL |
| Query editor missing | Layout reset | View → Panels → enable *Query Results* |

> 💡 **Tip:** Restart ADS after installing new extensions for best performance.
