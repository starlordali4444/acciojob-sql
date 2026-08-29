/**
 * ============================================================================
 * FILE: js/dashboard.js
 * PROJECT: RetailMart V3 Enterprise Analytics Platform
 * PURPOSE: Dashboard interactivity, data loading, and chart rendering
 * AUTHOR: Sayyed Siraj Ali
 * VERSION: 3.0 — 10-Tab Dashboard
 * ============================================================================
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

const CONFIG = {
  dataPath: "./data",
  refreshInterval: 300000, // 5 minutes
  chartColors: {
    primary: "#2563eb",
    success: "#10b981",
    warning: "#f59e0b",
    danger: "#ef4444",
    info: "#06b6d4",
    purple: "#8b5cf6",
    pink: "#ec4899",
    indigo: "#6366f1",
    teal: "#14b8a6",
    orange: "#f97316",
  },
  chartPalette: [
    "#2563eb", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6",
    "#ec4899", "#06b6d4", "#f97316", "#6366f1", "#14b8a6",
  ],
};

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

const state = {
  data: {},
  charts: {},
  currentTab: "executive",
  isLoading: false,
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

const Utils = {
  formatCurrency(value) {
    if (value === null || value === undefined) return "₹0";
    const num = parseFloat(value);
    if (num >= 10000000) return "₹" + (num / 10000000).toFixed(2) + " Cr";
    if (num >= 100000) return "₹" + (num / 100000).toFixed(2) + " L";
    if (num >= 1000) return "₹" + (num / 1000).toFixed(1) + "K";
    return "₹" + num.toFixed(0);
  },

  formatNumber(value) {
    if (value === null || value === undefined) return "0";
    return parseFloat(value).toLocaleString("en-IN");
  },

  formatPercent(value, decimals = 1) {
    if (value === null || value === undefined) return "0%";
    return parseFloat(value).toFixed(decimals) + "%";
  },

  getChangeIndicator(value) {
    if (value > 0) return { class: "positive", icon: "↑", text: "+" + this.formatPercent(value) };
    if (value < 0) return { class: "negative", icon: "↓", text: this.formatPercent(value) };
    return { class: "", icon: "→", text: "0%" };
  },

  truncate(text, maxLength = 30) {
    if (!text) return "";
    return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
  },

  safeArray(data) {
    return Array.isArray(data) ? data : [];
  },

  createBadge(text, type = "info") {
    return '<span class="badge badge-' + type + '">' + text + '</span>';
  },

  getBadgeType(status) {
    const map = {
      Excellent: "success", Good: "success", Healthy: "success", Star: "success",
      Growing: "success", "Strong Growth": "success",
      Warning: "warning", Degraded: "warning", Slow: "warning",
      "Needs Improvement": "warning", "Break Even": "warning", Average: "info", Stable: "info",
      Critical: "danger", "Needs Attention": "danger", Declining: "danger",
      "Losing Money": "danger", Poor: "danger", "High Reject": "danger",
    };
    return map[status] || "info";
  },

  tierClass(tier) {
    return "tier-" + (tier || "").toLowerCase();
  },
};

// ============================================================================
// DATA LOADING
// ============================================================================

const DataLoader = {
  async loadJSON(path) {
    try {
      const response = await fetch(CONFIG.dataPath + "/" + path, { cache: "no-cache" });
      if (!response.ok) throw new Error("HTTP " + response.status);
      return await response.json();
    } catch (error) {
      console.warn("Failed to load " + path + ":", error.message);
      return null;
    }
  },

  async loadAllData() {
    showLoading(true);
    try {
      const [
        executiveSummary, monthlyTrend, recentTrend, dayOfWeek, paymentModes, quarterly, orderStatus,
        topCustomers, clvTiers, rfmSegments, churnRisk, regTrends, geography, loyalty,
        topProducts, categories, brandPerf, abcAnalysis, inventoryStatus,
        topStores, regional, storeInventory, employeeDist,
        opsSummary, deliveryPerf, couriers, returns, pendingShipments, support, callCenter,
        marketingSummary, campaigns, channels, emailEng, webAnalytics,
        financeSummary, hrOverview, payrollSummary,
        auditOverview, apiPerf,
        supplyChain, manufacturing,
        alerts, schemaInventory,
      ] = await Promise.all([
        // Sales (7)
        this.loadJSON("executive_summary.json"), this.loadJSON("monthly_trend.json"),
        this.loadJSON("recent_trend.json"), this.loadJSON("dayofweek.json"),
        this.loadJSON("payment_mode.json"), this.loadJSON("quarterly_sales.json"),
        this.loadJSON("order_status.json"),
        // Customers (7)
        this.loadJSON("top_customers.json"), this.loadJSON("clv_tiers.json"),
        this.loadJSON("rfm_segments.json"), this.loadJSON("churn_risk.json"),
        this.loadJSON("registration_trends.json"), this.loadJSON("geography.json"),
        this.loadJSON("loyalty_overview.json"),
        // Products (5)
        this.loadJSON("top_products.json"), this.loadJSON("category_performance.json"),
        this.loadJSON("brand_performance.json"), this.loadJSON("abc_analysis.json"),
        this.loadJSON("inventory_status.json"),
        // Stores (4)
        this.loadJSON("top_stores.json"), this.loadJSON("regional_performance.json"),
        this.loadJSON("store_inventory.json"), this.loadJSON("employee_distribution.json"),
        // Operations (7)
        this.loadJSON("operations_summary.json"), this.loadJSON("delivery_performance.json"),
        this.loadJSON("courier_comparison.json"), this.loadJSON("return_analysis.json"),
        this.loadJSON("pending_shipments.json"), this.loadJSON("support_overview.json"),
        this.loadJSON("call_center.json"),
        // Marketing (5)
        this.loadJSON("marketing_summary.json"), this.loadJSON("campaign_performance.json"),
        this.loadJSON("channel_performance.json"), this.loadJSON("email_engagement.json"),
        this.loadJSON("web_analytics.json"),
        // Finance & HR (3)
        this.loadJSON("finance_summary.json"), this.loadJSON("hr_overview.json"),
        this.loadJSON("payroll_summary.json"),
        // Audit (2)
        this.loadJSON("audit_overview.json"), this.loadJSON("api_performance.json"),
        // Supply Chain (2)
        this.loadJSON("supply_chain.json"), this.loadJSON("manufacturing.json"),
        // Alerts (1)
        this.loadJSON("alerts.json"),
        // Schema inventory (1) — powers the Schema Explorer + per-tab chips
        this.loadJSON("schema_inventory.json"),
      ]);

      state.data = {
        executiveSummary, monthlyTrend: Utils.safeArray(monthlyTrend),
        recentTrend: Utils.safeArray(recentTrend), dayOfWeek: Utils.safeArray(dayOfWeek),
        paymentModes: Utils.safeArray(paymentModes), quarterly: Utils.safeArray(quarterly),
        orderStatus: Utils.safeArray(orderStatus),
        topCustomers: Utils.safeArray(topCustomers), clvTiers: Utils.safeArray(clvTiers),
        rfmSegments: Utils.safeArray(rfmSegments), churnRisk, regTrends: Utils.safeArray(regTrends),
        geography: Utils.safeArray(geography), loyalty,
        topProducts: Utils.safeArray(topProducts), categories: Utils.safeArray(categories),
        brandPerf: Utils.safeArray(brandPerf), abcAnalysis, inventoryStatus: Utils.safeArray(inventoryStatus),
        topStores: Utils.safeArray(topStores), regional: Utils.safeArray(regional),
        storeInventory: Utils.safeArray(storeInventory), employeeDist: Utils.safeArray(employeeDist),
        opsSummary, deliveryPerf: Utils.safeArray(deliveryPerf),
        couriers: Utils.safeArray(couriers), returns, pendingShipments: Utils.safeArray(pendingShipments),
        support, callCenter,
        marketingSummary, campaigns: Utils.safeArray(campaigns),
        channels: Utils.safeArray(channels), emailEng: Utils.safeArray(emailEng), webAnalytics,
        financeSummary, hrOverview, payrollSummary,
        auditOverview, apiPerf: Utils.safeArray(apiPerf),
        supplyChain, manufacturing,
        alerts, schemaInventory,
      };

      console.log("Data loaded successfully — 44 JSON files");
      return true;
    } catch (error) {
      console.error("Error loading data:", error);
      return false;
    } finally {
      showLoading(false);
    }
  },
};

// ============================================================================
// CHART MANAGEMENT
// ============================================================================

const ChartManager = {
  destroy(chartId) {
    if (state.charts[chartId]) { state.charts[chartId].destroy(); delete state.charts[chartId]; }
  },

  createLineChart(canvasId, labels, datasets, options = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "line", data: { labels, datasets },
      options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: "top" } }, scales: { y: { beginAtZero: false } }, ...options },
    });
    return state.charts[canvasId];
  },

  createBarChart(canvasId, labels, datasets, options = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "bar", data: { labels, datasets },
      options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: datasets.length > 1 } }, ...options },
    });
    return state.charts[canvasId];
  },

  createDoughnutChart(canvasId, labels, data, options = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "doughnut",
      data: { labels, datasets: [{ data, backgroundColor: CONFIG.chartPalette.slice(0, data.length), borderColor: cssVar("--surface"), borderWidth: 2 }] },
      options: { responsive: true, maintainAspectRatio: false, cutout: "62%",
        plugins: {
          legend: { position: "right" },
          datalabels: {
            color: "#fff", font: { weight: "600", size: 11 },
            display: (c) => { const t = c.dataset.data.reduce((a, b) => a + (+b || 0), 0); return t > 0 && c.dataset.data[c.dataIndex] / t >= 0.05; },
            formatter: (v, c) => { const t = c.dataset.data.reduce((a, b) => a + (+b || 0), 0); return t > 0 ? Math.round(v / t * 100) + "%" : ""; },
          },
        },
        ...options },
    });
    return state.charts[canvasId];
  },

  createRadarChart(canvasId, labels, datasets, options = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "radar", data: { labels, datasets },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { position: "top" }, datalabels: { display: false } },
        scales: { r: { ticks: { display: false, backdropColor: "transparent" }, grid: { color: cssVar("--grid-line") }, angleLines: { color: cssVar("--grid-line") }, pointLabels: { font: { size: 11 }, color: cssVar("--text-muted") } } },
        ...options,
      },
    });
    return state.charts[canvasId];
  },

  createHorizontalBarChart(canvasId, labels, data, options = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "bar",
      data: { labels, datasets: [{ data, backgroundColor: CONFIG.chartColors.primary, borderRadius: 4 }] },
      options: { indexAxis: "y", responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, ...options },
    });
    return state.charts[canvasId];
  },

  createBubbleChart(canvasId, points, opt = {}) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    state.charts[canvasId] = new Chart(ctx, {
      type: "bubble",
      data: { datasets: [{
        data: points.map(p => ({ x: p.x, y: p.y, r: p.r })),
        backgroundColor: points.map(p => p.color || CONFIG.chartColors.primary + "99"),
        borderColor: points.map(p => (p.color || CONFIG.chartColors.primary)),
        borderWidth: 1,
      }] },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: {
          legend: { display: false }, datalabels: { display: false },
          tooltip: { callbacks: {
            label: (c) => points[c.dataIndex].label,
            afterLabel: (c) => { const p = points[c.dataIndex];
              return (opt.xLabel || "x") + ": " + Number(p.x).toLocaleString("en-IN") + "  ·  " + (opt.yLabel || "y") + ": " + Number(p.y).toLocaleString("en-IN"); },
          } },
        },
        scales: {
          x: { title: { display: !!opt.xLabel, text: opt.xLabel }, beginAtZero: true },
          y: { title: { display: !!opt.yLabel, text: opt.yLabel }, beginAtZero: true },
        },
      },
    });
    return state.charts[canvasId];
  },

  createGaugeChart(canvasId, value, label, color) {
    this.destroy(canvasId);
    const ctx = document.getElementById(canvasId);
    if (!ctx) return null;
    const v = Math.max(0, Math.min(100, Number(value) || 0));
    state.charts[canvasId] = new Chart(ctx, {
      type: "doughnut",
      data: { datasets: [{ data: [v, 100 - v], backgroundColor: [color, cssVar("--surface-3") || "#eee"], borderWidth: 0 }] },
      options: {
        responsive: true, maintainAspectRatio: false, rotation: -90, circumference: 180, cutout: "72%",
        plugins: { legend: { display: false }, tooltip: { enabled: false }, datalabels: { display: false } },
      },
      plugins: [{
        id: "gauge_" + canvasId,
        afterDraw(chart) {
          const { ctx, chartArea } = chart; if (!chartArea) return;
          const x = (chartArea.left + chartArea.right) / 2;
          const y = chartArea.top + (chartArea.bottom - chartArea.top) * 0.82;
          ctx.save(); ctx.textAlign = "center";
          ctx.fillStyle = cssVar("--text") || "#000"; ctx.font = "700 24px Inter, sans-serif";
          ctx.fillText(v.toFixed(1) + "%", x, y);
          ctx.fillStyle = cssVar("--text-muted") || "#888"; ctx.font = "500 11px Inter, sans-serif";
          ctx.fillText(label || "", x, y + 18);
          ctx.restore();
        },
      }],
    });
    return state.charts[canvasId];
  },
};

// ============================================================================
// TAB RENDER FUNCTIONS
// ============================================================================

function renderExecutiveTab() {
  const d = state.data;
  if (d.executiveSummary) {
    const es = d.executiveSummary;
    updateKPI("kpiTotalRevenue", Utils.formatCurrency(es.total_revenue), es.revenue_growth_pct, "vs last 30d");
    updateKPI("kpiTotalOrders", Utils.formatNumber(es.total_orders), es.orders_growth_pct, "vs last 30d");
    updateKPI("kpiTotalCustomers", Utils.formatNumber(es.total_customers));
    updateKPI("kpiAvgOrderValue", Utils.formatCurrency(es.overall_aov));
    updateKPI("kpiRevenue30d", Utils.formatCurrency(es.revenue_30d));
    updateKPI("kpiAvgDailyRevenue", Utils.formatCurrency(es.avg_daily_revenue));
    if (es.reference_date) {
      document.querySelector(".freshness-text").textContent = "Data as of " + new Date(es.reference_date).toLocaleDateString("en-IN");
    }
  }
  if (d.monthlyTrend.length > 0) {
    const sorted = [...d.monthlyTrend].sort((a, b) => (a.monthKey || "").localeCompare(b.monthKey || ""));
    ChartManager.createLineChart("chartRevenueTrend", sorted.map(m => m.monthName),
      [{ label: "Net Revenue", data: sorted.map(m => m.netRevenue || m.revenue), borderColor: CONFIG.chartColors.primary, backgroundColor: "rgba(37,99,235,0.1)", fill: true, tension: 0.3 },
       { label: "3M Moving Avg", data: sorted.map(m => m.movingAvg3M), borderColor: CONFIG.chartColors.warning, borderDash: [5, 5], fill: false, tension: 0.3 }]
    );
  }
  if (d.categories.length > 0) {
    const top6 = d.categories.slice(0, 6);
    ChartManager.createDoughnutChart("chartCategoryRevenue", top6.map(c => c.category), top6.map(c => c.revenue));
  }
  if (d.orderStatus.length > 0) {
    const os = [...d.orderStatus].sort((a, b) => b.orders - a.orders);
    ChartManager.createDoughnutChart("chartOrderStatus", os.map(s => s.status), os.map(s => s.orders));
  }
  if (d.regional.length > 0) {
    const byRegion = {};
    d.regional.forEach(r => { byRegion[r.region] = (byRegion[r.region] || 0) + (r.revenue || 0); });
    const regions = Object.keys(byRegion);
    ChartManager.createBarChart("chartRevenueByRegion", regions,
      [{ label: "Revenue", data: regions.map(r => byRegion[r]), backgroundColor: CONFIG.chartColors.primary }]);
  }
  if (d.topProducts.length > 0) {
    const tbody = document.querySelector("#tableTopProducts tbody");
    if (tbody) tbody.innerHTML = d.topProducts.slice(0, 10).map((p, i) =>
      '<tr><td>' + (i + 1) + '</td><td class="truncate" title="' + p.productName + '">' + Utils.truncate(p.productName, 25) + '</td><td>' + p.category + '</td><td class="text-right">' + Utils.formatCurrency(p.revenue) + '</td></tr>'
    ).join("");
  }
  if (d.topCustomers.length > 0) {
    const tbody = document.querySelector("#tableTopCustomers tbody");
    if (tbody) tbody.innerHTML = d.topCustomers.slice(0, 10).map((c, i) =>
      '<tr><td>' + (i + 1) + '</td><td>' + (c.fullName || "") + '</td><td>' + (c.city || "") + '</td><td class="text-right">' + Utils.formatCurrency(c.totalRevenue) + '</td></tr>'
    ).join("");
  }
}

function renderSalesTab() {
  const d = state.data;
  if (d.executiveSummary) {
    const es = d.executiveSummary;
    updateKPI("kpiSalesRev30", Utils.formatCurrency(es.revenue_30d));
    updateKPI("kpiSalesOrders30", Utils.formatNumber(es.orders_30d));
    updateKPI("kpiSalesAov30", Utils.formatCurrency(es.aov_30d));
    updateKPI("kpiSalesDailyOrders", Utils.formatNumber(Math.round(es.avg_daily_orders)));
  }
  if (d.monthlyTrend.length > 0) {
    const ms = [...d.monthlyTrend].sort((a, b) => (a.monthKey || "").localeCompare(b.monthKey || ""));
    ChartManager.createBarChart("chartSalesMonthly", ms.map(m => m.monthName),
      [{ label: "Net Revenue", data: ms.map(m => m.netRevenue || m.revenue), backgroundColor: CONFIG.chartColors.primary }]);
  }
  if (d.orderStatus.length > 0) {
    const os = [...d.orderStatus].sort((a, b) => b.orders - a.orders);
    ChartManager.createBarChart("chartSalesOrderStatus", os.map(s => s.status),
      [{ label: "Orders", data: os.map(s => s.orders), backgroundColor: CONFIG.chartPalette }]);
  }
  if (d.recentTrend.length > 0) {
    const sorted = [...d.recentTrend].sort((a, b) => new Date(a.date) - new Date(b.date));
    ChartManager.createLineChart("chartDailySales",
      sorted.map(r => new Date(r.date).toLocaleDateString("en-IN", { day: "2-digit", month: "short" })),
      [{ label: "Revenue", data: sorted.map(r => r.revenue), borderColor: CONFIG.chartColors.primary, tension: 0.1 },
       { label: "7-Day Avg", data: sorted.map(r => r.movingAvg7D), borderColor: CONFIG.chartColors.warning, borderDash: [5, 5], tension: 0.1 }]
    );
  }
  if (d.dayOfWeek.length > 0) {
    const sorted = [...d.dayOfWeek].sort((a, b) => a.dayOrder - b.dayOrder);
    ChartManager.createBarChart("chartDayOfWeek", sorted.map(x => x.dayName),
      [{ label: "Revenue", data: sorted.map(x => x.revenue), backgroundColor: sorted.map(x => x.isWeekend ? CONFIG.chartColors.success : CONFIG.chartColors.primary) }]);
  }
  if (d.paymentModes.length > 0) {
    ChartManager.createDoughnutChart("chartPaymentModes", d.paymentModes.map(p => p.paymentMode), d.paymentModes.map(p => p.amount));
  }
  if (d.quarterly.length > 0) {
    const recent = d.quarterly.slice(0, 8).reverse();
    ChartManager.createBarChart("chartQuarterly", recent.map(q => q.quarterLabel),
      [{ label: "Revenue", data: recent.map(q => q.revenue), backgroundColor: CONFIG.chartColors.primary }]);
  }
}

function renderCustomersTab() {
  const d = state.data;
  if (d.executiveSummary) {
    updateKPI("kpiCustTotal", Utils.formatNumber(d.executiveSummary.total_customers));
    updateKPI("kpiCustNew", Utils.formatNumber(d.executiveSummary.customers_30d));
  }
  if (d.loyalty && d.loyalty.tierDistribution) {
    updateKPI("kpiCustLoyalty", Utils.formatNumber(d.loyalty.tierDistribution.reduce((a, t) => a + (t.members || 0), 0)));
  }
  if (d.rfmSegments.length > 0) {
    const champ = d.rfmSegments.find(s => /champion/i.test(s.segment));
    updateKPI("kpiCustChampions", Utils.formatNumber(champ ? champ.customerCount : 0));
  }
  if (d.rfmSegments.length > 0) {
    ChartManager.createHorizontalBarChart("chartRFMSegments", d.rfmSegments.map(s => s.segment), d.rfmSegments.map(s => s.customerCount));
  }
  if (d.clvTiers.length > 0) {
    ChartManager.createDoughnutChart("chartCLVTiers",
      d.clvTiers.map(t => t.tier + " (" + t.customerCount + ")"),
      d.clvTiers.map(t => t.totalRevenue));
  }
  if (d.regTrends.length > 0) {
    const sorted = d.regTrends.slice(0, 12).reverse();
    ChartManager.createLineChart("chartRegistrationTrends", sorted.map(r => r.monthName || ""),
      [{ label: "New Signups", data: sorted.map(r => r.newSignups), borderColor: CONFIG.chartColors.success, fill: true, backgroundColor: "rgba(16,185,129,0.1)", tension: 0.3 }]);
  }
  if (d.churnRisk && d.churnRisk.distribution) {
    ChartManager.createDoughnutChart("chartChurnRisk",
      d.churnRisk.distribution.map(x => x.riskLevel), d.churnRisk.distribution.map(x => x.customerCount));
  }
  // Loyalty charts
  if (d.loyalty && d.loyalty.tierDistribution) {
    ChartManager.createBarChart("chartLoyaltyTiers",
      d.loyalty.tierDistribution.map(t => t.tier),
      [{ label: "Members", data: d.loyalty.tierDistribution.map(t => t.members), backgroundColor: CONFIG.chartPalette }]);
  }
  if (d.loyalty && d.loyalty.memberVsNonMember) {
    ChartManager.createBarChart("chartLoyaltyROI",
      d.loyalty.memberVsNonMember.map(m => m.segment),
      [{ label: "Revenue", data: d.loyalty.memberVsNonMember.map(m => m.revenue), backgroundColor: [CONFIG.chartColors.primary, CONFIG.chartColors.warning] }]);
  }
  if (d.geography.length > 0) {
    const byState = {};
    d.geography.forEach(g => { byState[g.state] = (byState[g.state] || 0) + (g.totalRevenue || 0); });
    const top = Object.entries(byState).sort((a, b) => b[1] - a[1]).slice(0, 10);
    ChartManager.createHorizontalBarChart("chartTopStates", top.map(s => s[0]), top.map(s => s[1]));
  }
  if (d.rfmSegments.length > 0) {
    const maxMon = Math.max.apply(null, d.rfmSegments.map(s => s.avgMonetary || 0)) || 1;
    const pts = d.rfmSegments.map((s, i) => ({ x: s.avgRecencyDays, y: s.avgFrequency, r: 6 + (s.avgMonetary / maxMon) * 22,
      label: s.segment + " (" + Utils.formatNumber(s.customerCount) + ")", color: CONFIG.chartPalette[i % CONFIG.chartPalette.length] }));
    ChartManager.createBubbleChart("chartRfmBubble", pts, { xLabel: "Avg recency (days)", yLabel: "Avg frequency" });
  }
  // Churn risk table
  if (d.churnRisk && d.churnRisk.highPriorityCustomers) {
    const tbody = document.querySelector("#tableChurnRisk tbody");
    if (tbody) tbody.innerHTML = d.churnRisk.highPriorityCustomers.slice(0, 10).map(c =>
      '<tr><td>' + (c.fullName || "") + '</td><td><span class="' + Utils.tierClass(c.clvTier) + '">' + c.clvTier + '</span></td><td class="text-right">' + Utils.formatCurrency(c.totalSpent) + '</td><td>' + c.daysInactive + ' days</td><td class="truncate text-muted" title="' + (c.recommendedAction || "") + '">' + Utils.truncate(c.recommendedAction, 40) + '</td></tr>'
    ).join("");
  }
}

function renderProductsTab() {
  const d = state.data;
  updateKPI("kpiProdCategories", Utils.formatNumber(d.categories.length));
  updateKPI("kpiProdBrands", Utils.formatNumber(d.brandPerf.length));
  if (d.abcAnalysis && d.abcAnalysis.summary) {
    const a = d.abcAnalysis.summary.find(s => s.class === "A");
    updateKPI("kpiProdClassA", Utils.formatNumber(a ? a.productCount : 0));
  }
  if (d.inventoryStatus.length > 0) {
    const oos = d.inventoryStatus.find(s => /out of stock/i.test(s.status));
    updateKPI("kpiProdOOS", Utils.formatNumber(oos ? oos.productCount : 0));
  }
  if (d.topProducts.length > 0) {
    const top10 = d.topProducts.slice(0, 10);
    ChartManager.createHorizontalBarChart("chartTopProductsBar", top10.map(p => Utils.truncate(p.productName, 20)), top10.map(p => p.revenue));
  }
  if (d.abcAnalysis && d.abcAnalysis.summary) {
    ChartManager.createDoughnutChart("chartABCPie",
      d.abcAnalysis.summary.map(s => "Class " + s.class + " (" + s.productCount + " products)"),
      d.abcAnalysis.summary.map(s => s.totalRevenue));
  }
  if (d.categories.length > 0) {
    ChartManager.createBarChart("chartCategoryPerformance", d.categories.map(c => c.category),
      [{ label: "Revenue", data: d.categories.map(c => c.revenue), backgroundColor: CONFIG.chartColors.primary }]);
  }
  if (d.inventoryStatus.length > 0) {
    ChartManager.createDoughnutChart("chartInventoryStatus", d.inventoryStatus.map(s => s.status), d.inventoryStatus.map(s => s.productCount));
  }
  if (d.brandPerf.length > 0) {
    const top = [...d.brandPerf].sort((a, b) => b.revenue - a.revenue).slice(0, 10);
    ChartManager.createHorizontalBarChart("chartTopBrands", top.map(b => Utils.truncate(b.brand, 16)), top.map(b => b.revenue));
    const top15 = [...d.brandPerf].sort((a, b) => b.revenue - a.revenue).slice(0, 15);
    const maxU = Math.max.apply(null, top15.map(b => b.unitsSold || 0)) || 1;
    const pts = top15.map((b, i) => ({ x: b.avgRating, y: b.revenue, r: 6 + (b.unitsSold / maxU) * 20,
      label: b.brand + " · " + b.category, color: CONFIG.chartPalette[i % CONFIG.chartPalette.length] }));
    ChartManager.createBubbleChart("chartBrandScatter", pts, { xLabel: "Avg rating", yLabel: "Revenue" });
  }
  if (d.topProducts.length > 0) {
    const tbody = document.querySelector("#tableProductDetails tbody");
    if (tbody) tbody.innerHTML = d.topProducts.slice(0, 15).map(p =>
      '<tr><td>' + p.revenueRank + '</td><td class="truncate" title="' + p.productName + '">' + Utils.truncate(p.productName, 25) + '</td><td>' + p.category + '</td><td>' + p.brand + '</td><td class="text-right">' + Utils.formatCurrency(p.revenue) + '</td><td class="text-right">' + Utils.formatNumber(p.unitsSold) + '</td><td>' + (p.avgRating ? p.avgRating.toFixed(1) + " ⭐" : "-") + '</td><td class="text-right">' + Utils.formatNumber(p.currentStock) + '</td></tr>'
    ).join("");
  }
}

function renderStoresTab() {
  const d = state.data;
  if (d.topStores.length > 0) {
    updateKPI("kpiStoreTotal", Utils.formatNumber(d.topStores.length));
    updateKPI("kpiStoreRevenue", Utils.formatCurrency(d.topStores.reduce((a, s) => a + (s.revenue || 0), 0)));
    updateKPI("kpiStoreMargin", Utils.formatPercent(d.topStores.reduce((a, s) => a + (s.profitMargin || 0), 0) / d.topStores.length));
    const counts = {};
    d.topStores.forEach(s => { const t = s.performanceTier || "Unrated"; counts[t] = (counts[t] || 0) + 1; });
    const order = ["Star", "Excellent", "Good", "Average", "Needs Improvement", "Needs Attention", "Poor", "Unrated"].filter(k => counts[k]);
    ChartManager.createDoughnutChart("chartStoreTiers", order, order.map(k => counts[k]));
  }
  if (d.regional.length > 0) {
    updateKPI("kpiStoreRegions", new Set(d.regional.map(r => r.region)).size);
  }
  if (d.regional.length > 0) {
    // regional_performance is per-state — roll it up to the 6 regions
    const agg = {};
    d.regional.forEach(r => {
      const k = r.region;
      agg[k] = agg[k] || { revenue: 0, profit: 0, stores: 0, employees: 0 };
      agg[k].revenue += r.revenue || 0; agg[k].profit += r.profit || 0;
      agg[k].stores += r.storeCount || 0; agg[k].employees += r.employees || 0;
    });
    const regions = Object.keys(agg);
    ChartManager.createBarChart("chartRegionalPerformance", regions,
      [{ label: "Revenue", data: regions.map(r => agg[r].revenue), backgroundColor: CONFIG.chartColors.primary },
       { label: "Profit", data: regions.map(r => agg[r].profit), backgroundColor: CONFIG.chartColors.success }]);
    const maxOf = (key) => Math.max.apply(null, regions.map(r => agg[r][key])) || 1;
    const mR = maxOf("revenue"), mP = maxOf("profit"), mS = maxOf("stores"), mE = maxOf("employees");
    ChartManager.createRadarChart("chartRegionRadar", ["Revenue", "Profit", "Stores", "Employees"],
      regions.map((r, i) => {
        const c = CONFIG.chartPalette[i % CONFIG.chartPalette.length];
        return { label: r, borderColor: c, backgroundColor: c + "22", borderWidth: 2, pointBackgroundColor: c,
          data: [agg[r].revenue / mR * 100, agg[r].profit / mP * 100, agg[r].stores / mS * 100, agg[r].employees / mE * 100] };
      }));
  }
  if (d.topStores.length > 0) {
    const top10 = d.topStores.slice(0, 10);
    ChartManager.createHorizontalBarChart("chartStoreRankings", top10.map(s => Utils.truncate(s.storeName, 20)), top10.map(s => s.revenue));
  }
  if (d.topStores.length > 0) {
    const tbody = document.querySelector("#tableStoreScorecard tbody");
    if (tbody) tbody.innerHTML = d.topStores.slice(0, 15).map(s =>
      '<tr><td>' + s.revenueRank + '</td><td>' + Utils.truncate(s.storeName, 25) + '</td><td>' + s.city + '</td><td>' + s.region + '</td><td class="text-right">' + Utils.formatCurrency(s.revenue) + '</td><td class="text-right">' + Utils.formatCurrency(s.profit) + '</td><td class="text-right">' + (s.profitMargin || 0) + '%</td><td>' + Utils.createBadge(s.performanceTier, Utils.getBadgeType(s.performanceTier)) + '</td></tr>'
    ).join("");
  }
}

function renderOperationsTab() {
  const d = state.data;
  if (d.opsSummary) {
    const os = d.opsSummary;
    updateKPI("kpiOnTimeDelivery", Utils.formatPercent(os.delivery_sla_pct));
    updateKPI("kpiAvgDeliveryDays", (os.avg_delivery_days || 0) + " days");
    updateKPI("kpiReturnRate", Utils.formatPercent(os.return_rate_pct));
    updateKPI("kpiTotalRefunds", Utils.formatCurrency(os.total_refunds));
    updateKPI("kpiOpenTickets", Utils.formatNumber(os.open_tickets));
    updateKPI("kpiAvgSentiment", os.avg_sentiment ? parseFloat(os.avg_sentiment).toFixed(2) : "--");
  }
  if (d.deliveryPerf.length > 0) {
    const sorted = d.deliveryPerf.slice(0, 12).reverse();
    ChartManager.createLineChart("chartDeliverySLA", sorted.map(r => r.month),
      [{ label: "On-Time %", data: sorted.map(r => r.onTimePct), borderColor: CONFIG.chartColors.success, fill: false, tension: 0.3 }]);
  }
  if (d.couriers.length > 0) {
    ChartManager.createBarChart("chartCourierPerformance", d.couriers.map(c => c.courier),
      [{ label: "On-Time %", data: d.couriers.map(c => c.onTimePct), backgroundColor: CONFIG.chartColors.primary },
       { label: "Avg Days", data: d.couriers.map(c => c.avgDays), backgroundColor: CONFIG.chartColors.warning }]);
  }
  if (d.returns && d.returns.byReason) {
    ChartManager.createDoughnutChart("chartReturnReasons",
      d.returns.byReason.map(r => Utils.truncate(r.reason, 20)),
      d.returns.byReason.map(r => r.count));
  }
  if (d.callCenter && d.callCenter.sentiment) {
    const s = d.callCenter.sentiment;
    ChartManager.createBarChart("chartCallSentiment", s.map(r => Utils.truncate(r.reason, 15)),
      [{ label: "Avg Sentiment", data: s.map(r => r.avgSentiment),
         backgroundColor: s.map(r => r.avgSentiment < 0.4 ? CONFIG.chartColors.danger : r.avgSentiment < 0.7 ? CONFIG.chartColors.warning : CONFIG.chartColors.success) }]);
  }
  if (d.opsSummary) {
    ChartManager.createGaugeChart("chartSlaGauge", d.opsSummary.delivery_sla_pct, "On-time delivery", CONFIG.chartColors.success);
  }
  if (d.support && d.support.byCategory) {
    const sc = d.support.byCategory;
    ChartManager.createBarChart("chartTicketsByCategory", sc.map(s => Utils.truncate(s.category, 16)),
      [{ label: "Tickets", data: sc.map(s => s.tickets), backgroundColor: CONFIG.chartColors.primary }]);
  }
}

function renderMarketingTab() {
  const d = state.data;
  if (d.marketingSummary) {
    const m = d.marketingSummary;
    updateKPI("kpiMktCampaigns", Utils.formatNumber(m.total_campaigns));
    updateKPI("kpiMktSpend", Utils.formatCurrency(m.total_spend));
    updateKPI("kpiMktPageViews", Utils.formatNumber(m.total_page_views));
    updateKPI("kpiMktOpenRate", Utils.formatPercent(m.overall_open_rate));
  }
  if (d.campaigns.length > 0) {
    const withROI = d.campaigns.filter(c => c.roi !== null).slice(0, 10);
    ChartManager.createBarChart("chartCampaignROI", withROI.map(c => Utils.truncate(c.campaignName, 15)),
      [{ label: "ROI %", data: withROI.map(c => c.roi || 0),
         backgroundColor: withROI.map(c => (c.roi || 0) > 100 ? CONFIG.chartColors.success : (c.roi || 0) > 0 ? CONFIG.chartColors.warning : CONFIG.chartColors.danger) }]);
  }
  if (d.channels.length > 0) {
    ChartManager.createDoughnutChart("chartChannelPerformance", d.channels.map(c => c.platform || c.channel), d.channels.map(c => c.spend));
  }
  if (d.emailEng.length > 0) {
    const top = d.emailEng.slice(0, 10);
    ChartManager.createBarChart("chartEmailEngagement", top.map(e => Utils.truncate(e.campaignName, 12)),
      [{ label: "Open %", data: top.map(e => e.openRate), backgroundColor: CONFIG.chartColors.primary },
       { label: "Click %", data: top.map(e => e.clickRate), backgroundColor: CONFIG.chartColors.success }]);
  }
  if (d.webAnalytics && d.webAnalytics.dailyTraffic) {
    const sorted = d.webAnalytics.dailyTraffic.slice(0, 30).reverse();
    ChartManager.createLineChart("chartWebTraffic", sorted.map(r => (r.date || "").substring(5)),
      [{ label: "Page Views", data: sorted.map(r => r.pageViews), borderColor: CONFIG.chartColors.primary, fill: true, backgroundColor: "rgba(37,99,235,0.1)", tension: 0.3 }]);
  }
  if (d.webAnalytics && d.webAnalytics.devices) {
    ChartManager.createDoughnutChart("chartDeviceBreakdown",
      d.webAnalytics.devices.map(x => x.device + "/" + x.os), d.webAnalytics.devices.map(x => x.views));
  }
  if (d.webAnalytics && d.webAnalytics.eventFunnel) {
    ChartManager.createBarChart("chartEventFunnel", d.webAnalytics.eventFunnel.map(e => e.eventType),
      [{ label: "Events", data: d.webAnalytics.eventFunnel.map(e => e.count), backgroundColor: CONFIG.chartPalette }]);
  }
  if (d.campaigns.length > 0) {
    const withRev = d.campaigns.filter(c => c.revenue > 0).sort((a, b) => b.revenue - a.revenue).slice(0, 30);
    const maxO = Math.max.apply(null, withRev.map(c => c.orders || 0)) || 1;
    const pts = withRev.map(c => ({ x: c.spend, y: c.revenue, r: 5 + (c.orders / maxO) * 18,
      label: Utils.truncate(c.campaignName, 28), color: CONFIG.chartColors.primary + "aa" }));
    ChartManager.createBubbleChart("chartCampaignScatter", pts, { xLabel: "Spend", yLabel: "Revenue" });
  }
  if (d.webAnalytics && d.webAnalytics.topPages) {
    const top = d.webAnalytics.topPages.slice(0, 10);
    ChartManager.createHorizontalBarChart("chartTopPages", top.map(p => p.page), top.map(p => p.views));
  }
  if (d.campaigns.length > 0) {
    const tbody = document.querySelector("#tableCampaigns tbody");
    if (tbody) tbody.innerHTML = d.campaigns.slice(0, 15).map(c =>
      '<tr><td class="truncate" title="' + c.campaignName + '">' + Utils.truncate(c.campaignName, 22) + '</td><td>' + Utils.createBadge(c.status, Utils.getBadgeType(c.status)) + '</td><td class="text-right">' + Utils.formatCurrency(c.budget) + '</td><td class="text-right">' + Utils.formatCurrency(c.spend) + '</td><td>' + (c.platforms || c.platformList || "-") + '</td><td class="text-right">' + (c.orders || 0) + '</td><td class="text-right">' + Utils.formatCurrency(c.revenue) + '</td><td class="text-right ' + ((c.roi || 0) > 0 ? "text-success" : "text-danger") + '">' + (c.roi || 0) + '%</td></tr>'
    ).join("");
  }
}

function renderFinanceTab() {
  const d = state.data;
  if (d.financeSummary && d.financeSummary.pnl) {
    const p = d.financeSummary.pnl;
    const rev = p.reduce((a, r) => a + (r.revenue || 0), 0);
    const exp = p.reduce((a, r) => a + (r.expenses || 0), 0);
    const prof = p.reduce((a, r) => a + (r.profit || 0), 0);
    updateKPI("kpiFinRevenue", Utils.formatCurrency(rev));
    updateKPI("kpiFinExpenses", Utils.formatCurrency(exp));
    updateKPI("kpiFinProfit", Utils.formatCurrency(prof));
    updateKPI("kpiFinMargin", Utils.formatPercent(rev > 0 ? prof / rev * 100 : 0));
  }
  if (d.financeSummary && d.financeSummary.pnl) {
    const sorted = d.financeSummary.pnl.slice(0, 12).reverse();
    ChartManager.createBarChart("chartPnLTrend", sorted.map(r => r.month),
      [{ label: "Revenue", data: sorted.map(r => r.revenue), backgroundColor: CONFIG.chartColors.primary + "88" },
       { label: "Expenses", data: sorted.map(r => r.expenses), backgroundColor: CONFIG.chartColors.danger + "88" },
       { label: "Profit", data: sorted.map(r => r.profit), type: "line", borderColor: CONFIG.chartColors.success, fill: false }]);
  }
  if (d.financeSummary && d.financeSummary.expenseBreakdown) {
    const eb = d.financeSummary.expenseBreakdown;
    ChartManager.createDoughnutChart("chartExpenseBreakdown", eb.map(e => e.category), eb.map(e => e.spent));
  }
  if (d.hrOverview && d.hrOverview.attendance) {
    const depts = [...new Set(d.hrOverview.attendance.map(a => a.department))];
    ChartManager.createBarChart("chartAttendance", depts,
      [{ label: "Attendance %", data: depts.map(dep => { const r = d.hrOverview.attendance.find(a => a.department === dep); return r ? r.attendancePct : 0; }),
         backgroundColor: CONFIG.chartPalette }]);
  }
  if (d.payrollSummary && d.payrollSummary.byDepartment) {
    const pd = d.payrollSummary.byDepartment;
    ChartManager.createBarChart("chartPayrollDept", pd.map(r => Utils.truncate(r.department, 12)),
      [{ label: "Gross", data: pd.map(r => r.gross), backgroundColor: CONFIG.chartColors.primary + "88" },
       { label: "Net", data: pd.map(r => r.net), backgroundColor: CONFIG.chartColors.success + "88" }]);
  }
  if (d.financeSummary && d.financeSummary.pnl) {
    const sorted = d.financeSummary.pnl.slice(0, 12).reverse();
    ChartManager.createLineChart("chartProfitMargin", sorted.map(r => r.month),
      [{ label: "Profit Margin %", data: sorted.map(r => r.margin), borderColor: CONFIG.chartColors.success, backgroundColor: "rgba(16,185,129,0.12)", fill: true, tension: 0.3 }]);
  }
  if (d.payrollSummary && d.payrollSummary.monthlyTrend) {
    const mt = [...d.payrollSummary.monthlyTrend].reverse();
    ChartManager.createLineChart("chartPayrollTrend", mt.map(r => (r.month || "").substring(0, 3) + " '" + String(r.year).slice(-2)),
      [{ label: "Gross", data: mt.map(r => r.gross), borderColor: CONFIG.chartColors.primary, tension: 0.3 },
       { label: "Net", data: mt.map(r => r.net), borderColor: CONFIG.chartColors.success, tension: 0.3 }]);
  }
  if (d.hrOverview && d.hrOverview.salaryByDept) {
    const tbody = document.querySelector("#tableSalaryAnalysis tbody");
    if (tbody) tbody.innerHTML = d.hrOverview.salaryByDept.map(r =>
      '<tr><td>' + r.department + '</td><td>' + r.role + '</td><td>' + r.employees + '</td><td class="text-right">' + Utils.formatCurrency(r.avgSalary) + '</td><td class="text-right">' + Utils.formatCurrency(r.medianSalary) + '</td><td class="text-right">' + Utils.formatCurrency(r.totalPayroll) + '</td><td class="text-right">' + (r.pctOfPayroll || "-") + '%</td></tr>'
    ).join("");
  }
}

function renderAuditTab() {
  const d = state.data;
  if (d.auditOverview && d.auditOverview.dailyHealth) {
    const latest = d.auditOverview.dailyHealth[0];
    if (latest) {
      updateKPI("kpiSystemHealth", Utils.createBadge(latest.health, Utils.getBadgeType(latest.health)));
      updateKPI("kpiErrorRate", Utils.formatPercent(latest.errorRate));
      updateKPI("kpiAvgApiResponse", (latest.avgResponseMs || 0) + "ms");
      updateKPI("kpiRecordChanges", Utils.formatNumber(latest.changes));
    }
    const sorted = d.auditOverview.dailyHealth.slice(0, 30).reverse();
    ChartManager.createLineChart("chartHealthTrend", sorted.map(r => (r.date || "").substring(5)),
      [{ label: "Error Rate %", data: sorted.map(r => r.errorRate), borderColor: CONFIG.chartColors.danger, fill: false, tension: 0.3 },
       { label: "API Fail Rate %", data: sorted.map(r => r.apiFailRate), borderColor: CONFIG.chartColors.warning, fill: false, tension: 0.3 }]);
  }
  if (d.auditOverview && d.auditOverview.errorsByService) {
    const es = d.auditOverview.errorsByService.filter(s => s.errors > 0);
    ChartManager.createBarChart("chartErrorsByService", es.map(s => s.service),
      [{ label: "Errors", data: es.map(s => s.errors), backgroundColor: CONFIG.chartColors.danger + "88" }]);
  }
  if (d.apiPerf.length > 0) {
    const top = [...d.apiPerf].sort((a, b) => b.requests - a.requests).slice(0, 10);
    ChartManager.createBarChart("chartApiLatency", top.map(r => Utils.truncate(r.endpoint, 18)),
      [{ label: "Avg ms", data: top.map(r => r.avgMs), backgroundColor: CONFIG.chartColors.primary },
       { label: "P95 ms", data: top.map(r => r.p95Ms), backgroundColor: CONFIG.chartColors.warning }]);
    const maxF = Math.max.apply(null, d.apiPerf.map(r => r.failures || 0)) || 1;
    const pts = d.apiPerf.map(r => ({ x: r.requests, y: r.failureRate, r: 5 + (r.failures / maxF) * 18,
      label: r.method + " " + r.endpoint,
      color: (r.health === "Critical" ? CONFIG.chartColors.danger : (r.health === "Slow" || r.health === "Degraded") ? CONFIG.chartColors.warning : CONFIG.chartColors.success) + "cc" }));
    ChartManager.createBubbleChart("chartApiFailScatter", pts, { xLabel: "Requests", yLabel: "Failure rate %" });
  }
  if (d.apiPerf.length > 0) {
    const tbody = document.querySelector("#tableApiPerformance tbody");
    if (tbody) tbody.innerHTML = d.apiPerf.slice(0, 15).map(r =>
      '<tr><td class="truncate">' + Utils.truncate(r.endpoint, 30) + '</td><td>' + r.method + '</td><td class="text-right">' + Utils.formatNumber(r.requests) + '</td><td class="text-right">' + r.failures + '</td><td class="text-right">' + Utils.formatPercent(r.failureRate) + '</td><td class="text-right">' + r.avgMs + '</td><td class="text-right">' + r.p95Ms + '</td><td>' + Utils.createBadge(r.health, Utils.getBadgeType(r.health)) + '</td></tr>'
    ).join("");
  }
  if (d.auditOverview && d.auditOverview.suspiciousActivity) {
    const tbody = document.querySelector("#tableSuspiciousActivity tbody");
    if (tbody) tbody.innerHTML = (d.auditOverview.suspiciousActivity || []).slice(0, 10).map(r =>
      '<tr><td>' + r.type + '</td><td>' + (r.employee || "Unknown") + '</td><td class="truncate">' + Utils.truncate(r.detail, 30) + '</td><td>' + (r.time ? new Date(r.time).toLocaleDateString() : "-") + '</td><td>' + Utils.createBadge(r.flag, "danger") + '</td></tr>'
    ).join("");
  }
}

function renderSupplyChainTab() {
  const d = state.data;
  if (d.supplyChain && d.supplyChain.summary) {
    const s = d.supplyChain.summary;
    updateKPI("kpiWarehouses", s.total_warehouses);
    updateKPI("kpiActiveSuppliers", s.active_suppliers);
    updateKPI("kpiTotalProduced", Utils.formatNumber(s.total_produced));
    updateKPI("kpiRejectRate", Utils.formatPercent(s.overall_reject_rate));
  }
  if (d.supplyChain && d.supplyChain.suppliers) {
    const sup = d.supplyChain.suppliers;
    ChartManager.createBarChart("chartSupplierSLA", sup.map(s => Utils.truncate(s.name, 12)),
      [{ label: "On-Time %", data: sup.map(s => s.onTimePct),
         backgroundColor: sup.map(s => s.onTimePct >= 80 ? CONFIG.chartColors.success + "88" : s.onTimePct >= 60 ? CONFIG.chartColors.warning + "88" : CONFIG.chartColors.danger + "88") }]);
  }
  if (d.manufacturing && d.manufacturing.productionLines) {
    const pl = d.manufacturing.productionLines;
    ChartManager.createBarChart("chartProductionEfficiency", pl.map(l => l.line),
      [{ label: "Utilization %", data: pl.map(l => l.utilization), backgroundColor: CONFIG.chartColors.primary + "88" },
       { label: "Reject %", data: pl.map(l => l.rejectRate), backgroundColor: CONFIG.chartColors.danger + "88" }]);
  }
  if (d.supplyChain && d.supplyChain.warehouses) {
    const w = d.supplyChain.warehouses;
    ChartManager.createBarChart("chartWarehouseUnits", w.map(x => Utils.truncate(x.name, 14)),
      [{ label: "Units", data: w.map(x => x.units), backgroundColor: CONFIG.chartColors.primary }]);
  }
  if (d.supplyChain && d.supplyChain.suppliers) {
    const counts = {};
    d.supplyChain.suppliers.forEach(s => { const r = s.rating || "Unrated"; counts[r] = (counts[r] || 0) + 1; });
    const order = ["Excellent", "Good", "Average", "Poor", "Unrated"].filter(k => counts[k]);
    ChartManager.createDoughnutChart("chartSupplierRating", order, order.map(k => counts[k]));
  }
  if (d.supplyChain && d.supplyChain.warehouses) {
    const tbody = document.querySelector("#tableWarehouses tbody");
    if (tbody) tbody.innerHTML = d.supplyChain.warehouses.map(w =>
      '<tr><td>' + w.name + '</td><td>' + w.city + '</td><td>' + (w.region || "-") + '</td><td class="text-right">' + w.products + '</td><td class="text-right">' + Utils.formatNumber(w.units) + '</td><td class="text-right">' + (w.pendingInbound || 0) + '</td></tr>'
    ).join("");
  }
  if (d.manufacturing && d.manufacturing.qualityIssues) {
    const tbody = document.querySelector("#tableQualityIssues tbody");
    if (tbody) tbody.innerHTML = (d.manufacturing.qualityIssues || []).slice(0, 10).map(q =>
      '<tr><td>' + Utils.truncate(q.product, 20) + '</td><td>' + q.category + '</td><td class="text-right">' + Utils.formatNumber(q.produced) + '</td><td class="text-right">' + q.rejected + '</td><td class="text-right text-danger">' + Utils.formatPercent(q.rejectRate) + '</td><td>' + Utils.createBadge(q.status, Utils.getBadgeType(q.status)) + '</td></tr>'
    ).join("");
  }
}

// ============================================================================
// UI HELPERS
// ============================================================================

function updateKPI(elementId, value, change, changeLabel) {
  const element = document.getElementById(elementId);
  if (!element) return;

  const valueEl = element.querySelector(".kpi-value");
  const changeEl = element.querySelector(".kpi-change");

  if (valueEl) animateValue(valueEl, value);

  if (changeEl && change !== null && change !== undefined) {
    const indicator = Utils.getChangeIndicator(change);
    changeEl.className = "kpi-change " + indicator.class;
    changeEl.textContent = indicator.icon + " " + indicator.text + (changeLabel ? " " + changeLabel : "");
  }
}

function showLoading(show) {
  const overlay = document.getElementById("loadingOverlay");
  if (overlay) overlay.classList.toggle("active", show);
  state.isLoading = show;
}

function updateAlertBadge() {
  const badge = document.querySelector(".alert-count");
  if (badge && state.data.alerts) {
    const a = state.data.alerts;
    const count = (a.bySeverity ? (a.bySeverity.critical || 0) + (a.bySeverity.high || 0) + (a.bySeverity.medium || 0) : 0);
    badge.textContent = count > 99 ? "99+" : count;
  }
}

function showAlertModal() {
  const modal = document.getElementById("alertModal");
  const body = document.getElementById("alertModalBody");
  if (!modal || !body) return;

  if (state.data.alerts && state.data.alerts.alerts) {
    body.innerHTML = state.data.alerts.alerts.slice(0, 30).map(a =>
      '<div class="alert-item ' + (a.severity || "medium").toLowerCase() + '">' +
      '<div class="alert-severity">' + a.severity + " — " + a.type + '</div>' +
      '<div class="alert-message">' + a.message + '</div>' +
      '<div class="alert-action">→ ' + a.action + '</div></div>'
    ).join("");
  } else {
    body.innerHTML = '<p class="text-muted">No active alerts</p>';
  }
  modal.classList.add("active");
}

function hideAlertModal() {
  const modal = document.getElementById("alertModal");
  if (modal) modal.classList.remove("active");
}

// ============================================================================
// THEME (light / dark) + CHART THEMING
// ============================================================================

function cssVar(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

// Indian-style abbreviation for axis ticks — Cr / Lakh, never "millions".
function abbrIndian(v) {
  const n = Math.abs(Number(v));
  if (!isFinite(n)) return v;
  if (n >= 1e7) return (v / 1e7).toFixed(n % 1e7 === 0 ? 0 : 1) + " Cr";
  if (n >= 1e5) return (v / 1e5).toFixed(n % 1e5 === 0 ? 0 : 1) + " L";
  if (n >= 1000) return Number(v).toLocaleString("en-IN");
  return v;
}

let _dlRegistered = false;
function applyChartTheme() {
  if (!window.Chart) return;
  if (!_dlRegistered && window.ChartDataLabels) { Chart.register(window.ChartDataLabels); _dlRegistered = true; }

  Chart.defaults.color = cssVar("--text-muted") || "#646b85";
  Chart.defaults.borderColor = cssVar("--grid-line") || "rgba(20,24,48,.07)";
  Chart.defaults.font.family = "'Inter', -apple-system, sans-serif";
  Chart.defaults.font.size = 12;

  // Rounded bars + smooth lines = enterprise BI feel
  Chart.defaults.elements.bar.borderRadius = 6;
  Chart.defaults.elements.bar.borderSkipped = false;
  Chart.defaults.elements.line.tension = 0.35;
  Chart.defaults.elements.line.borderWidth = 3;
  Chart.defaults.elements.point.radius = 0;
  Chart.defaults.elements.point.hoverRadius = 6;
  Chart.defaults.elements.point.hitRadius = 12;

  Chart.defaults.plugins.legend.labels.usePointStyle = true;
  Chart.defaults.plugins.legend.labels.boxWidth = 8;
  Chart.defaults.plugins.legend.labels.padding = 14;

  // Tooltip — Indian-grouped numbers (no "millions")
  const tip = Chart.defaults.plugins.tooltip;
  tip.padding = 10; tip.cornerRadius = 8; tip.boxPadding = 5; tip.usePointStyle = true;
  tip.callbacks = tip.callbacks || {};
  tip.callbacks.label = function (ctx) {
    const p = ctx.parsed;
    let v = (p && typeof p === "object") ? (p.y != null ? p.y : (p.x != null ? p.x : p.r)) : p;
    const num = typeof v === "number" ? Number(v).toLocaleString("en-IN") : v;
    const name = ctx.dataset.label || ctx.label || "";
    return (name ? name + ": " : "") + num;
  };

  if (Chart.defaults.plugins.datalabels) Chart.defaults.plugins.datalabels.display = false;

  // Indian abbreviation on linear axes (revenue → "45 Cr", not "450,000,000")
  if (Chart.defaults.scales && Chart.defaults.scales.linear) {
    Chart.defaults.scales.linear.ticks.callback = function (value) { return abbrIndian(value); };
  }
}

// Theme has 3 modes: "auto" (follows time of day), "light", "dark".
function timeTheme() { const h = new Date().getHours(); return (h >= 7 && h < 19) ? "light" : "dark"; }
function resolveTheme(mode) { return mode === "auto" ? timeTheme() : mode; }
function currentThemeMode() { try { return localStorage.getItem("rm-theme") || "auto"; } catch (e) { return "auto"; } }

function syncThemeButton() {
  const mode = currentThemeMode();
  const resolved = document.documentElement.dataset.theme;
  const icon = document.querySelector("#themeToggle i");
  if (icon) icon.className = "ti " + (mode === "auto" ? "ti-clock" : resolved === "dark" ? "ti-sun" : "ti-moon");
  const btn = document.getElementById("themeToggle");
  if (btn) btn.title = "Theme: " + (mode === "auto" ? "Auto (by time of day)" : mode === "dark" ? "Dark" : "Light") + " — click to change";
}

function applyThemeMode(mode) {
  try { localStorage.setItem("rm-theme", mode); } catch (e) {}
  document.documentElement.dataset.theme = resolveTheme(mode);
  syncThemeButton();
  applyChartTheme();
  if (state.dataReady) switchTab(state.currentTab); // repaint charts in the new theme
}

function cycleTheme() {
  const order = ["auto", "light", "dark"];
  applyThemeMode(order[(order.indexOf(currentThemeMode()) + 1) % order.length]);
}

// Welcome splash
function runWelcomeCounters() {
  document.querySelectorAll("#welcomeOverlay [data-count]").forEach(el => {
    const target = parseFloat(el.dataset.count), pre = el.dataset.pre || "", post = el.dataset.post || "";
    const dur = 1500, t0 = performance.now();
    function frame(now) {
      const p = Math.min(1, (now - t0) / dur), e = 1 - Math.pow(1 - p, 3);
      el.textContent = pre + Math.round(target * e).toLocaleString("en-IN") + post;
      if (p < 1) requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  });
}

function dismissWelcome() {
  const w = document.getElementById("welcomeOverlay");
  if (!w || w.classList.contains("hide")) return;
  w.classList.add("hide");
  setTimeout(() => { w.style.display = "none"; }, 700);
}

// ============================================================================
// ANIMATED KPI COUNTERS
// ============================================================================

function animateValue(el, finalStr) {
  const str = String(finalStr);
  if (str.indexOf("<") !== -1) { el.innerHTML = finalStr; return; } // HTML (e.g. badge)
  const m = str.match(/-?[\d,]*\.?\d+/);
  if (!m) { el.textContent = finalStr; return; }
  const numStr = m[0];
  const target = parseFloat(numStr.replace(/,/g, ""));
  if (!isFinite(target)) { el.textContent = finalStr; return; }
  const decimals = (numStr.split(".")[1] || "").length;
  const grouped = numStr.indexOf(",") !== -1;
  const pre = str.slice(0, m.index);
  const post = str.slice(m.index + numStr.length);
  const dur = 750, t0 = performance.now();
  function frame(now) {
    const p = Math.min(1, (now - t0) / dur);
    const eased = 1 - Math.pow(1 - p, 3);
    const cur = target * eased;
    let s = decimals > 0 ? cur.toFixed(decimals) : Math.round(cur).toString();
    if (grouped) s = Number(s).toLocaleString("en-IN", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
    el.textContent = pre + s + post;
    if (p < 1) requestAnimationFrame(frame); else el.innerHTML = finalStr;
  }
  requestAnimationFrame(frame);
}

// ============================================================================
// TABLE ENHANCEMENTS (search + click-to-sort)
// ============================================================================

function parseCell(td) {
  if (!td) return "";
  const t = td.textContent.trim();
  if (!/[0-9]/.test(t)) return t.toLowerCase();
  let mult = 1;
  if (/\bcr\b/i.test(t)) mult = 1e7;
  else if (/\bl\b/i.test(t) || /lakh/i.test(t)) mult = 1e5;
  else if (/\bk\b/i.test(t)) mult = 1e3;
  const num = parseFloat(t.replace(/[^0-9.\-]/g, ""));
  return isNaN(num) ? t.toLowerCase() : num * mult;
}

function sortTable(table, idx, th) {
  const tbody = table.querySelector("tbody");
  const rows = Array.from(tbody.querySelectorAll("tr"));
  const dir = th.classList.contains("sort-asc") ? "desc" : "asc";
  table.querySelectorAll("th").forEach(h => h.classList.remove("sort-asc", "sort-desc"));
  th.classList.add(dir === "asc" ? "sort-asc" : "sort-desc");
  rows.sort((a, b) => {
    const x = parseCell(a.children[idx]), y = parseCell(b.children[idx]);
    if (typeof x === "number" && typeof y === "number") return dir === "asc" ? x - y : y - x;
    return dir === "asc" ? String(x).localeCompare(String(y)) : String(y).localeCompare(String(x));
  });
  rows.forEach(r => tbody.appendChild(r));
}

function enhanceTables(scope) {
  (scope || document).querySelectorAll(".table-card").forEach(card => {
    const table = card.querySelector("table");
    if (!table) return;
    const tbody = table.querySelector("tbody");
    if (!tbody || tbody.children.length === 0) return;
    if (!card.querySelector(".table-toolbar") && tbody.children.length > 6) {
      const tb = document.createElement("div");
      tb.className = "table-toolbar";
      const inp = document.createElement("input");
      inp.type = "search"; inp.className = "table-search"; inp.placeholder = "Filter rows…";
      inp.addEventListener("input", () => {
        const q = inp.value.toLowerCase();
        tbody.querySelectorAll("tr").forEach(tr => { tr.style.display = tr.textContent.toLowerCase().includes(q) ? "" : "none"; });
      });
      tb.appendChild(inp);
      const h3 = card.querySelector("h3");
      if (h3) h3.after(tb); else card.prepend(tb);
    }
    table.querySelectorAll("thead th").forEach((th, idx) => {
      if (th.dataset.sortable) return;
      th.dataset.sortable = "1";
      th.classList.add("sortable");
      th.addEventListener("click", () => sortTable(table, idx, th));
    });
  });
}

// ============================================================================
// SCHEMA EXPLORER + PER-TAB "TABLES USED" CHIPS
// ============================================================================

const TAB_LABELS = {
  executive: "Executive", sales: "Sales", customers: "Customers", products: "Products",
  stores: "Stores", operations: "Operations", marketing: "Marketing", finance: "Finance & HR",
  audit: "Audit", supplychain: "Supply Chain", schema: "Schema",
};
function tabLabel(t) { return TAB_LABELS[t] || t; }
function fmtRows(n) { return Number(n).toLocaleString("en-IN"); }

function renderSchemaTab() {
  const inv = state.data.schemaInventory;
  if (!inv) return;
  const hero = document.getElementById("schemaHero");
  if (hero && !hero.dataset.done) {
    const t = inv.totals;
    hero.innerHTML = [
      [t.schemas, "Schemas"],
      [t.tables, "Base tables"],
      [fmtRows(t.rows), "Total rows"],
      ["11", "Dashboard views"],
    ].map(s => '<div class="schema-stat"><div class="num">' + s[0] + '</div><div class="cap">' + s[1] + '</div></div>').join("");
    hero.dataset.done = "1";
  }
  const grid = document.getElementById("schemaGrid");
  if (grid && !grid.dataset.done) {
    grid.innerHTML = inv.schemas.map(s =>
      '<div class="schema-card"><div class="sc-head">' +
        '<div class="sc-ico"><i class="ti ' + s.icon + '"></i></div>' +
        '<div><div class="sc-name">' + s.schema + '</div><div class="sc-sub">' + s.label + '</div></div>' +
        '<div class="sc-meta">' + s.tableCount + ' tables<br>' + fmtRows(s.rows) + ' rows</div>' +
      '</div><div class="sc-table">' +
        s.tables.map(tb =>
          '<div class="sc-row"><div class="t-name">' + tb.table + '</div>' +
          '<div class="t-rows">' + fmtRows(tb.rows) + '</div>' +
          '<div class="t-purpose">' + tb.purpose + '</div>' +
          '<div class="t-tabs">' + (tb.tabs || []).map(tab => '<span class="t-tab" data-jump="' + tab + '">' + tabLabel(tab) + '</span>').join("") + '</div></div>'
        ).join("") +
      '</div></div>'
    ).join("");
    grid.querySelectorAll(".t-tab").forEach(el => el.addEventListener("click", () => switchTab(el.dataset.jump)));
    grid.dataset.done = "1";
  }
}

// ============================================================================
// TAB NAVIGATION
// ============================================================================

function switchTab(tabName) {
  state.currentTab = tabName;
  document.querySelectorAll(".tab-btn").forEach(btn => btn.classList.toggle("active", btn.dataset.tab === tabName));
  document.querySelectorAll(".tab-content").forEach(content => content.classList.toggle("active", content.id === "tab-" + tabName));

  const renderFunctions = {
    executive: renderExecutiveTab, sales: renderSalesTab, customers: renderCustomersTab,
    products: renderProductsTab, stores: renderStoresTab, operations: renderOperationsTab,
    marketing: renderMarketingTab, finance: renderFinanceTab, audit: renderAuditTab,
    supplychain: renderSupplyChainTab, schema: renderSchemaTab,
  };

  if (renderFunctions[tabName]) renderFunctions[tabName]();
  enhanceTables(document.getElementById("tab-" + tabName));
}

// ============================================================================
// INITIALIZATION
// ============================================================================

async function initDashboard() {
  console.log("Initializing RetailMart V3 Analytics Dashboard (11 tabs)...");
  applyChartTheme();
  const success = await DataLoader.loadAllData();

  if (success) {
    state.dataReady = true;
    switchTab(state.currentTab || "executive");
    updateAlertBadge();
    document.getElementById("footerTimestamp").textContent =
      "RetailMart V3 Analytics | Sayyed Siraj Ali | Last updated: " + new Date().toLocaleString("en-IN");
  } else {
    console.error("Failed to initialize dashboard");
  }
}

// ============================================================================
// EVENT LISTENERS
// ============================================================================

document.addEventListener("DOMContentLoaded", () => {
  runWelcomeCounters();
  const wStart = Date.now();
  initDashboard().finally(() => { setTimeout(dismissWelcome, Math.max(0, 2400 - (Date.now() - wStart))); });
  document.getElementById("welcomeOverlay")?.addEventListener("click", dismissWelcome);

  document.querySelectorAll(".tab-btn").forEach(btn => {
    btn.addEventListener("click", () => switchTab(btn.dataset.tab));
  });

  document.getElementById("themeToggle")?.addEventListener("click", cycleTheme);
  syncThemeButton();

  document.getElementById("btnRefresh")?.addEventListener("click", async () => { await initDashboard(); });
  document.getElementById("alertBadge")?.addEventListener("click", showAlertModal);
  document.getElementById("closeModal")?.addEventListener("click", hideAlertModal);
  document.getElementById("alertModal")?.addEventListener("click", e => { if (e.target.id === "alertModal") hideAlertModal(); });

  document.addEventListener("keydown", e => {
    if (e.key === "Escape") hideAlertModal();
    if (e.key === "r" && e.ctrlKey) { e.preventDefault(); initDashboard(); }
  });
});

// Auto-refresh (optional)
// setInterval(initDashboard, CONFIG.refreshInterval);