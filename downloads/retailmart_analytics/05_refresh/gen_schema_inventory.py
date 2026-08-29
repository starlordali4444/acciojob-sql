#!/usr/bin/env python3
# ============================================================================
# FILE: 05_refresh/gen_schema_inventory.py
# PROJECT: RetailMart V3 Enterprise Analytics Platform
# PURPOSE: Build data/schema_inventory.json for the dashboard's Schema Explorer.
#          Pairs LIVE row counts (introspected from the DB) with an authored
#          map of which dashboard tab each of the 55 tables powers.
# USAGE:   PGDATABASE=accio_retailmart_26 python3 05_refresh/gen_schema_inventory.py
#          (run from the retailmart_analytics/ project root)
# ============================================================================
import json, os, subprocess, sys, datetime

DB = os.environ.get("PGDATABASE", "accio_retailmart_NN")
OUT = os.path.join(os.path.dirname(__file__), "..", "06_dashboard", "data", "schema_inventory.json")

# Friendly label + icon per schema (16 source schemas of RetailMart V3)
SCHEMA_INFO = {
    "core":         ("Core dimensions", "ti-box-multiple"),
    "sales":        ("Sales",           "ti-shopping-cart"),
    "customers":    ("Customers",       "ti-users"),
    "products":     ("Products",        "ti-package"),
    "stores":       ("Stores",          "ti-building-store"),
    "supply_chain": ("Supply chain",    "ti-truck-delivery"),
    "manufacture":  ("Manufacturing",   "ti-settings-cog"),
    "marketing":    ("Marketing",       "ti-speakerphone"),
    "web_events":   ("Web events",      "ti-world-www"),
    "finance":      ("Finance",         "ti-cash"),
    "payroll":      ("Payroll",         "ti-receipt"),
    "hr":           ("HR",              "ti-id-badge"),
    "loyalty":      ("Loyalty",         "ti-medal"),
    "support":      ("Support",         "ti-headset"),
    "call_center":  ("Call center",     "ti-phone"),
    "audit":        ("Audit & compliance", "ti-shield-lock"),
}

# table -> (dashboard tabs it powers, one-line use case)
META = {
    "core.dim_brand":              (["products"], "Brand dimension (brand -> category)"),
    "core.dim_category":           (["products", "executive"], "Product category dimension"),
    "core.dim_date":               (["sales"], "Date dimension for time-series rollups"),
    "core.dim_department":         (["finance"], "Department dimension for HR & payroll"),
    "core.dim_expense_category":   (["finance"], "Expense category dimension for the P&L"),
    "core.dim_region":             (["stores"], "Region dimension for store geography"),

    "sales.orders":                (["sales", "executive"], "Order headers (150K) - the revenue backbone"),
    "sales.order_items":           (["sales", "products", "executive"], "Order line items (375K) - product-level revenue"),
    "sales.payments":              (["sales"], "Order-level payment records"),
    "sales.returns":               (["operations"], "Product returns & refund amounts"),
    "sales.shipments":             (["operations"], "Order shipments - courier & delivery SLA"),

    "customers.customers":         (["customers", "executive"], "Customer master - tier & registration"),
    "customers.addresses":         (["customers"], "Customer addresses - city/state/pincode"),
    "customers.reviews":           (["products"], "Product reviews & star ratings"),
    "customers.loyalty_points":    (["customers"], "Per-customer points ledger"),
    "customers.wallets":           (["customers"], "Customer wallet balances"),

    "products.products":           (["products", "executive"], "Product master - price, cost, type"),
    "products.inventory":          (["products"], "Store inventory levels (quantity_on_hand)"),
    "products.promotions":         (["products"], "Active product promotions"),
    "products.suppliers":          (["supplychain"], "Supplier master - reliability & lead time"),

    "stores.stores":               (["stores"], "Store master - 200 stores nationwide"),
    "stores.employees":            (["stores"], "Store employees + HQ staff"),
    "stores.expenses":             (["stores", "finance"], "Store-level operating expenses"),

    "supply_chain.warehouses":     (["supplychain"], "Warehouse master"),
    "supply_chain.shipments":      (["supplychain"], "Inbound supplier -> warehouse shipments"),
    "supply_chain.inventory_snapshots": (["supplychain"], "Daily warehouse inventory snapshots"),

    "manufacture.production_lines":(["supplychain"], "Production line master & utilization"),
    "manufacture.work_orders":     (["supplychain"], "Work orders - produced vs rejected units"),

    "marketing.campaigns":         (["marketing"], "Marketing campaigns - budget & ROI"),
    "marketing.ads_spend":         (["marketing"], "Ad spend by platform & campaign"),
    "marketing.email_clicks":      (["marketing"], "Email engagement - sent/opened/clicked"),

    "web_events.page_views":       (["marketing"], "Page views (500K) - traffic, device, hour"),
    "web_events.events":           (["marketing"], "Web events (200K) - the conversion funnel"),

    "finance.payments":            (["finance"], "Finance-ledger payment records"),
    "finance.expenses":            (["finance"], "Operating expenses - the P&L expense side"),
    "finance.revenue_summary":     (["finance"], "Daily revenue rollup (legacy reference)"),
    "finance.accounts":            (["finance"], "General-ledger accounts"),
    "finance.transfer_log":        (["finance"], "Inter-account transfers"),
    "finance.payment_modes":       (["sales"], "Payment-method dimension (UPI/Card/...)"),

    "payroll.pay_slips":           (["finance"], "Monthly payslips - gross/net payroll"),
    "payroll.tax_brackets":        (["finance"], "Income-tax bracket reference"),

    "hr.attendance":               (["finance"], "Daily employee attendance"),
    "hr.salary_history":           (["finance"], "Salary-change history"),

    "loyalty.members":             (["customers"], "Loyalty-program members"),
    "loyalty.redemptions":         (["customers"], "Points redemptions"),
    "loyalty.tiers":               (["customers"], "Loyalty-tier definitions"),

    "support.tickets":             (["operations"], "Support tickets - status, priority, SLA"),

    "call_center.calls":           (["operations"], "Call records - duration, reason, sentiment"),
    "call_center.transcripts":     (["operations"], "Call transcripts for sentiment analysis"),

    "audit.api_requests":          (["audit"], "API request logs - latency & status"),
    "audit.application_logs":      (["audit"], "App log stream - errors by service"),
    "audit.record_changes":        (["audit"], "Change-data-capture of row edits"),
    "audit.refund_log":            (["audit"], "Refund event log"),
    "audit.refund_failures":       (["audit"], "Failed refund attempts - risk"),
    "audit.procedure_calls":       (["audit"], "Stored-procedure call audit (JSONB params)"),
}

COUNT_SQL = """
SELECT json_agg(json_build_object('schema', schemaname, 'table', relname, 'rows', rows) ORDER BY schemaname, relname)
FROM (
  SELECT schemaname, relname,
    (xpath('/row/c/text()', query_to_xml(format('SELECT count(*) AS c FROM %I.%I', schemaname, relname), false, true, '')))[1]::text::bigint AS rows
  FROM pg_stat_user_tables
  WHERE schemaname NOT IN ('pg_catalog','information_schema','analytics')
) t;
"""


def fetch_counts():
    res = subprocess.run(["psql", "-d", DB, "-X", "-A", "-t", "-c", COUNT_SQL],
                         capture_output=True, text=True)
    if res.returncode != 0:
        sys.exit("psql failed: " + res.stderr.strip())
    return json.loads(res.stdout.strip())


def main():
    rows = fetch_counts()
    schemas = {}
    unmapped = []
    for r in rows:
        key = r["schema"] + "." + r["table"]
        tabs, purpose = META.get(key, ([], ""))
        if not tabs:
            unmapped.append(key)
        s = schemas.setdefault(r["schema"], {"schema": r["schema"], "tables": [], "rows": 0})
        s["tables"].append({"table": r["table"], "rows": r["rows"], "tabs": tabs, "purpose": purpose})
        s["rows"] += r["rows"]

    ordered = []
    for name in SCHEMA_INFO:
        if name in schemas:
            sc = schemas[name]
            label, icon = SCHEMA_INFO[name]
            ordered.append({**sc, "label": label, "icon": icon, "tableCount": len(sc["tables"])})

    doc = {
        "generatedAt": datetime.date.today().isoformat(),
        "totals": {
            "schemas": len(ordered),
            "tables": sum(s["tableCount"] for s in ordered),
            "rows": sum(s["rows"] for s in ordered),
        },
        "schemas": ordered,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as f:
        json.dump(doc, f, indent=2)
    print(f"wrote {OUT}")
    print(f"  {doc['totals']['schemas']} schemas, {doc['totals']['tables']} tables, {doc['totals']['rows']:,} rows")
    if unmapped:
        print("  WARNING unmapped tables:", unmapped)


if __name__ == "__main__":
    main()
