// ============================================================================
// FILE: 03_dashboard/dashboard.js
// PURPOSE: RetailMart Analytics Dashboard - Complete Implementation
// AUTHOR: RetailMart Analytics Team
// CREATED: 2024
// VERSION: 1.0.0
// DESCRIPTION:
//   - Loads all 22 JSON files from organized directory structure
//   - Renders all charts and tables across 5 dashboard tabs
//   - Handles real-time data refresh and error handling
//   - Fully integrated with Chart.js for visualizations
//   - Complete error handling and data validation
//   - Production-ready with logging and debugging
// ============================================================================

/* ============================================
   GLOBAL CONFIGURATION
   ============================================ */

// Base path for JSON data files
const DATA_PATH = {
    sales: 'data/sales/',
    products: 'data/products/',
    customers: 'data/customers/',
    stores: 'data/stores/'
};

// Chart color scheme - Professional color palette
const CHART_COLORS = {
    primary: '#2563eb',      // Blue
    secondary: '#7c3aed',    // Purple
    success: '#10b981',      // Green
    danger: '#ef4444',       // Red
    warning: '#f59e0b',      // Orange
    info: '#06b6d4',         // Cyan
    purple: '#8b5cf6',       // Light Purple
    pink: '#ec4899',         // Pink
    indigo: '#6366f1',       // Indigo
    teal: '#14b8a6'          // Teal
};

// Chart color palettes for multi-series charts
const COLOR_PALETTE = [
    CHART_COLORS.primary,
    CHART_COLORS.secondary,
    CHART_COLORS.success,
    CHART_COLORS.warning,
    CHART_COLORS.info,
    CHART_COLORS.purple,
    CHART_COLORS.pink,
    CHART_COLORS.indigo,
    CHART_COLORS.teal,
    CHART_COLORS.danger
];

// Global chart instances (to destroy/recreate on refresh)
let chartInstances = {};

// Debug mode flag
const DEBUG_MODE = true;

// Data cache for faster reloads
let dataCache = {
    sales: {},
    products: {},
    customers: {},
    stores: {}
};


/* ============================================
   INITIALIZATION
   ============================================ */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 RetailMart Dashboard initializing...');
    console.log('📅 Current Date:', new Date().toLocaleString());
    
    // Initialize dashboard
    updateLastUpdated();
    
    // Load all data
    loadAllData();
    
    // Set up event listeners
    setupEventListeners();
    
    console.log('✅ Dashboard initialization complete');
});


/* ============================================
   EVENT LISTENERS
   ============================================ */

function setupEventListeners() {
    // Refresh button (if you add one to HTML)
    const refreshBtn = document.getElementById('refreshBtn');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', refreshDashboard);
    }
    
    // Window resize handler for responsive charts
    window.addEventListener('resize', debounce(handleResize, 300));
    
    console.log('✅ Event listeners configured');
}

// Handle window resize
function handleResize() {
    console.log('📐 Window resized, adjusting charts...');
    Object.keys(chartInstances).forEach(chartId => {
        if (chartInstances[chartId]) {
            chartInstances[chartId].resize();
        }
    });
}

// Debounce utility function
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}


/* ============================================
   DATA LOADING FUNCTIONS
   ============================================ */

// Load all dashboard data
async function loadAllData() {
    console.log('📊 Loading all dashboard data...');
    showLoadingState();
    
    const startTime = performance.now();
    
    try {
        // Load data for all modules in parallel
        await Promise.all([
            loadExecutiveSummary(),
            loadSalesData(),
            loadProductsData(),
            loadCustomersData(),
            loadStoresData()
        ]);
        
        const endTime = performance.now();
        const loadTime = ((endTime - startTime) / 1000).toFixed(2);
        
        console.log(`✅ All data loaded successfully in ${loadTime} seconds`);
        hideLoadingState();
        
    } catch (error) {
        console.error('❌ Error loading dashboard data:', error);
        showError('Failed to load dashboard data. Please check if JSON files exist and web server is running.');
        hideLoadingState();
    }
}

// Load Executive Summary Data
async function loadExecutiveSummary() {
    console.log('📈 Loading Executive Summary...');
    
    try {
        const [execData, monthlyData, categoryData, topProducts, topCustomers] = await Promise.all([
            fetchJSON(DATA_PATH.sales + 'executive_summary.json'),
            fetchJSON(DATA_PATH.sales + 'monthly_trend.json'),
            fetchJSON(DATA_PATH.products + 'category_performance.json'),
            fetchJSON(DATA_PATH.products + 'top_products.json'),
            fetchJSON(DATA_PATH.customers + 'top_customers.json')
        ]);
        
        // Cache data
        dataCache.sales.executive = execData;
        dataCache.sales.monthly = monthlyData;
        dataCache.products.categories = categoryData;
        dataCache.products.top = topProducts;
        dataCache.customers.top = topCustomers;
        
        // Update KPI cards
        updateElement('totalRevenue', formatCurrency(execData.totalRevenue));
        updateElement('totalOrders', formatNumber(execData.totalOrders));
        updateElement('totalCustomers', formatNumber(execData.totalCustomers));
        updateElement('avgOrderValue', formatCurrency(execData.avgOrderValue));
        
        // Create charts
        createRevenueChart(monthlyData);
        createCategoryChart(categoryData);
        
        // Load tables
        loadTopProductsTable(topProducts.slice(0, 10));
        loadTopCustomersTable(topCustomers.slice(0, 10));
        
        console.log('✅ Executive summary loaded');
        
    } catch (error) {
        console.error('❌ Error loading executive summary:', error);
        throw error;
    }
}

// Load Sales Analytics Data
async function loadSalesData() {
    console.log('💰 Loading Sales Analytics...');
    
    try {
        const [recentTrend, dayOfWeek, quarterly, paymentMode, weekendWeekday] = await Promise.all([
            fetchJSON(DATA_PATH.sales + 'recent_trend.json'),
            fetchJSON(DATA_PATH.sales + 'dayofweek.json'),
            fetchJSON(DATA_PATH.sales + 'quarterly_sales.json'),
            fetchJSON(DATA_PATH.sales + 'payment_mode.json'),
            fetchJSON(DATA_PATH.sales + 'weekend_weekday.json')
        ]);
        
        // Cache data
        dataCache.sales.recent = recentTrend;
        dataCache.sales.dayOfWeek = dayOfWeek;
        dataCache.sales.quarterly = quarterly;
        dataCache.sales.paymentMode = paymentMode;
        dataCache.sales.weekendWeekday = weekendWeekday;
        
        // Update KPIs for Sales tab
        if (recentTrend && recentTrend.length > 0) {
            const last30Days = recentTrend.reduce((sum, day) => sum + parseFloat(day.revenue || 0), 0);
            const last30Orders = recentTrend.reduce((sum, day) => sum + parseInt(day.orders || 0), 0);
            
            updateElement('salesLast30', formatCurrency(last30Days));
            updateElement('ordersLast30', formatNumber(last30Orders));
        }
        
        // Create charts
        createDailySalesChart(recentTrend);
        createDayOfWeekChart(dayOfWeek);
        createQuarterlyChart(quarterly);
        
        console.log('✅ Sales data loaded');
        
    } catch (error) {
        console.error('❌ Error loading sales data:', error);
        // Don't throw - let other modules load
    }
}

// Load Products Analytics Data
async function loadProductsData() {
    console.log('📦 Loading Products Analytics...');
    
    try {
        const [topProducts, categories, brands, abcAnalysis, inventory] = await Promise.all([
            fetchJSON(DATA_PATH.products + 'top_products.json'),
            fetchJSON(DATA_PATH.products + 'category_performance.json'),
            fetchJSON(DATA_PATH.products + 'brand_performance.json'),
            fetchJSON(DATA_PATH.products + 'abc_analysis.json'),
            fetchJSON(DATA_PATH.products + 'inventory_status.json')
        ]);
        
        // Cache data
        dataCache.products.top = topProducts;
        dataCache.products.categories = categories;
        dataCache.products.brands = brands;
        dataCache.products.abc = abcAnalysis;
        dataCache.products.inventory = inventory;
        
        // Create charts
        createTopProductsChart(topProducts.slice(0, 10));
        createABCChart(abcAnalysis.classification);
        
        // Load product details table
        loadProductDetailsTable(topProducts.slice(0, 20));
        
        console.log('✅ Products data loaded');
        
    } catch (error) {
        console.error('❌ Error loading products data:', error);
        // Don't throw - let other modules load
    }
}

// Load Customers Analytics Data
async function loadCustomersData() {
    console.log('👥 Loading Customers Analytics...');
    
    try {
        const [topCustomers, rfmSegments, clvDistribution, churnRisk, demographics, geography] = await Promise.all([
            fetchJSON(DATA_PATH.customers + 'top_customers.json'),
            fetchJSON(DATA_PATH.customers + 'rfm_segments.json'),
            fetchJSON(DATA_PATH.customers + 'clv_distribution.json'),
            fetchJSON(DATA_PATH.customers + 'churn_risk.json'),
            fetchJSON(DATA_PATH.customers + 'demographics.json'),
            fetchJSON(DATA_PATH.customers + 'geography.json')
        ]);
        
        // Cache data
        dataCache.customers.top = topCustomers;
        dataCache.customers.rfm = rfmSegments;
        dataCache.customers.clv = clvDistribution;
        dataCache.customers.churn = churnRisk;
        dataCache.customers.demographics = demographics;
        dataCache.customers.geography = geography;
        
        // Create charts
        createRFMChart(rfmSegments);
        createCLVChart(clvDistribution);
        createChurnChart(churnRisk.distribution);
        
        // Optionally create cohort heatmap
        createCohortVisualization();
        
        console.log('✅ Customers data loaded');
        
    } catch (error) {
        console.error('❌ Error loading customers data:', error);
        // Don't throw - let other modules load
    }
}

// Load Stores Analytics Data
async function loadStoresData() {
    console.log('🏪 Loading Stores Analytics...');
    
    try {
        const [topStores, regional, inventory, employees] = await Promise.all([
            fetchJSON(DATA_PATH.stores + 'top_stores.json'),
            fetchJSON(DATA_PATH.stores + 'regional_performance.json'),
            fetchJSON(DATA_PATH.stores + 'store_inventory.json'),
            fetchJSON(DATA_PATH.stores + 'employee_distribution.json')
        ]);
        
        // Cache data
        dataCache.stores.top = topStores;
        dataCache.stores.regional = regional;
        dataCache.stores.inventory = inventory;
        dataCache.stores.employees = employees;
        
        // Create charts
        createTopStoresChart(topStores.slice(0, 10));
        createRegionalChart(regional);
        
        // Load store details table
        loadStoreDetailsTable(topStores.slice(0, 15));
        
        console.log('✅ Stores data loaded');
        
    } catch (error) {
        console.error('❌ Error loading stores data:', error);
        // Don't throw - let other modules load
    }
}


/* ============================================
   CHART CREATION FUNCTIONS
   ============================================ */

// Monthly Revenue Trend Chart
function createRevenueChart(data) {
    destroyChart('revenueChart');
    
    const ctx = document.getElementById('revenueChart');
    if (!ctx) {
        console.warn('⚠️ Revenue chart canvas not found');
        return;
    }
    
    // Reverse to show oldest to newest
    const sortedData = [...data].reverse();
    
    chartInstances['revenueChart'] = new Chart(ctx, {
        type: 'line',
        data: {
            labels: sortedData.map(d => `${d.month} ${d.year}`),
            datasets: [{
                label: 'Revenue',
                data: sortedData.map(d => parseFloat(d.revenue || 0)),
                borderColor: CHART_COLORS.primary,
                backgroundColor: CHART_COLORS.primary + '20',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 5,
                pointHoverRadius: 7,
                pointBackgroundColor: CHART_COLORS.primary,
                pointBorderColor: '#fff',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: { size: 14, weight: 'bold' },
                    bodyFont: { size: 13 },
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.y)
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
    
    console.log('✅ Revenue chart created');
}

// Category Revenue Doughnut Chart
function createCategoryChart(data) {
    destroyChart('categoryChart');
    
    const ctx = document.getElementById('categoryChart');
    if (!ctx) {
        console.warn('⚠️ Category chart canvas not found');
        return;
    }
    
    // Take top 5 categories
    const top5 = data.slice(0, 5);
    
    chartInstances['categoryChart'] = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: top5.map(d => d.category),
            datasets: [{
                data: top5.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: COLOR_PALETTE.slice(0, 5),
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 15
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        padding: 15,
                        font: { size: 12 },
                        usePointStyle: true
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    callbacks: {
                        label: (context) => {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${label}: ${formatCurrency(value)} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
    
    console.log('✅ Category chart created');
}

// Daily Sales Trend Chart (Last 30 Days)
function createDailySalesChart(data) {
    destroyChart('dailySalesChart');
    
    const ctx = document.getElementById('dailySalesChart');
    if (!ctx) {
        console.warn('⚠️ Daily sales chart canvas not found');
        return;
    }
    
    // Reverse to show oldest to newest
    const sortedData = [...data].reverse();
    
    chartInstances['dailySalesChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: sortedData.map(d => new Date(d.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })),
            datasets: [{
                label: 'Daily Revenue',
                data: sortedData.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: CHART_COLORS.primary,
                borderRadius: 5,
                hoverBackgroundColor: CHART_COLORS.secondary
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.y),
                        afterLabel: (context) => {
                            const dataPoint = sortedData[context.dataIndex];
                            return `Orders: ${formatNumber(dataPoint.orders)}`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Daily sales chart created');
}

// Day of Week Chart
function createDayOfWeekChart(data) {
    destroyChart('dayOfWeekChart');
    
    const ctx = document.getElementById('dayOfWeekChart');
    if (!ctx) {
        console.warn('⚠️ Day of week chart canvas not found');
        return;
    }
    
    chartInstances['dayOfWeekChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.dayName),
            datasets: [{
                label: 'Revenue',
                data: data.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: data.map(d => d.isWeekend ? CHART_COLORS.warning : CHART_COLORS.primary),
                borderRadius: 5
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.y),
                        afterLabel: (context) => {
                            const dataPoint = data[context.dataIndex];
                            return `Orders: ${formatNumber(dataPoint.orders)}`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Day of week chart created');
}

// Quarterly Sales Chart
function createQuarterlyChart(data) {
    destroyChart('quarterlyChart');
    
    const ctx = document.getElementById('quarterlyChart');
    if (!ctx) {
        console.warn('⚠️ Quarterly chart canvas not found');
        return;
    }
    
    // Reverse to show oldest to newest
    const sortedData = [...data].reverse();
    
    chartInstances['quarterlyChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: sortedData.map(d => d.quarterLabel),
            datasets: [{
                label: 'Revenue',
                data: sortedData.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: CHART_COLORS.primary,
                borderRadius: 5
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.y),
                        afterLabel: (context) => {
                            const dataPoint = sortedData[context.dataIndex];
                            return [
                                `Orders: ${formatNumber(dataPoint.orders)}`,
                                `Customers: ${formatNumber(dataPoint.customers)}`
                            ];
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Quarterly chart created');
}

// Top Products Chart
function createTopProductsChart(data) {
    destroyChart('topProductsChart');
    
    const ctx = document.getElementById('topProductsChart');
    if (!ctx) {
        console.warn('⚠️ Top products chart canvas not found');
        return;
    }
    
    chartInstances['topProductsChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.productName.substring(0, 25)),
            datasets: [{
                label: 'Revenue',
                data: data.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: CHART_COLORS.success,
                borderRadius: 5
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.x),
                        afterLabel: (context) => {
                            const dataPoint = data[context.dataIndex];
                            return `Units Sold: ${formatNumber(dataPoint.unitsSold)}`;
                        }
                    }
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Top products chart created');
}

// ABC Analysis Chart
function createABCChart(data) {
    destroyChart('abcChart');
    
    const ctx = document.getElementById('abcChart');
    if (!ctx) {
        console.warn('⚠️ ABC chart canvas not found');
        return;
    }
    
    // Convert object to array
    const abcData = Object.entries(data).map(([key, value]) => ({
        classification: key,
        ...value
    }));
    
    chartInstances['abcChart'] = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: abcData.map(d => d.classification),
            datasets: [{
                data: abcData.map(d => parseFloat(d.totalRevenue || 0)),
                backgroundColor: [CHART_COLORS.success, CHART_COLORS.warning, CHART_COLORS.danger],
                borderWidth: 2,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { 
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        font: { size: 12 }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: (context) => {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const dataPoint = abcData[context.dataIndex];
                            return [
                                `${label}: ${formatCurrency(value)}`,
                                `Products: ${formatNumber(dataPoint.productCount)}`,
                                `Revenue %: ${dataPoint.revenuePercent}%`
                            ];
                        }
                    }
                }
            }
        }
    });
    
    console.log('✅ ABC chart created');
}

// RFM Segments Chart
function createRFMChart(data) {
    destroyChart('rfmChart');
    
    const ctx = document.getElementById('rfmChart');
    if (!ctx) {
        console.warn('⚠️ RFM chart canvas not found');
        return;
    }
    
    // Sort by customer count and take top 8
    const sortedData = [...data].sort((a, b) => b.customerCount - a.customerCount).slice(0, 8);
    
    chartInstances['rfmChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: sortedData.map(d => d.segment),
            datasets: [{
                label: 'Customer Count',
                data: sortedData.map(d => parseInt(d.customerCount || 0)),
                backgroundColor: CHART_COLORS.secondary,
                borderRadius: 5
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        afterLabel: (context) => {
                            const dataPoint = sortedData[context.dataIndex];
                            return [
                                `Revenue: ${formatCurrency(dataPoint.totalRevenue)}`,
                                `Action: ${dataPoint.recommendedAction}`
                            ];
                        }
                    }
                }
            },
            scales: {
                y: { 
                    beginAtZero: true,
                    ticks: {
                        precision: 0
                    }
                }
            }
        }
    });
    
    console.log('✅ RFM chart created');
}

// CLV Distribution Chart
function createCLVChart(data) {
    destroyChart('clvChart');
    
    const ctx = document.getElementById('clvChart');
    if (!ctx) {
        console.warn('⚠️ CLV chart canvas not found');
        return;
    }
    
    chartInstances['clvChart'] = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.map(d => d.tier),
            datasets: [{
                data: data.map(d => parseFloat(d.totalRevenue || 0)),
                backgroundColor: [
                    CHART_COLORS.success,
                    CHART_COLORS.info,
                    CHART_COLORS.warning,
                    CHART_COLORS.secondary,
                    CHART_COLORS.danger
                ],
                borderWidth: 2,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { 
                    position: 'right',
                    labels: {
                        padding: 15,
                        font: { size: 12 },
                        usePointStyle: true
                    }
                },
                tooltip: {
                    callbacks: {
                        label: (context) => {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const dataPoint = data[context.dataIndex];
                            return [
                                `${label}: ${formatCurrency(value)}`,
                                `Customers: ${formatNumber(dataPoint.customerCount)}`
                            ];
                        }
                    }
                }
            }
        }
    });
    
    console.log('✅ CLV chart created');
}

// Churn Risk Chart
function createChurnChart(data) {
    destroyChart('churnChart');
    
    const ctx = document.getElementById('churnChart');
    if (!ctx) {
        console.warn('⚠️ Churn chart canvas not found');
        return;
    }
    
    if (!data || data.length === 0) {
        console.warn('⚠️ No churn data available');
        return;
    }
    
    chartInstances['churnChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.riskLevel),
            datasets: [{
                label: 'Customer Count',
                data: data.map(d => parseInt(d.customerCount || 0)),
                backgroundColor: [
                    CHART_COLORS.danger,
                    CHART_COLORS.warning,
                    CHART_COLORS.info,
                    CHART_COLORS.success
                ],
                borderRadius: 5
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        afterLabel: (context) => {
                            const dataPoint = data[context.dataIndex];
                            return `Total Value: ${formatCurrency(dataPoint.totalValue)}`;
                        }
                    }
                }
            },
            scales: {
                y: { 
                    beginAtZero: true,
                    ticks: {
                        precision: 0
                    }
                }
            }
        }
    });
    
    console.log('✅ Churn chart created');
}

// Top Stores Chart
function createTopStoresChart(data) {
    destroyChart('topStoresChart');
    
    const ctx = document.getElementById('topStoresChart');
    if (!ctx) {
        console.warn('⚠️ Top stores chart canvas not found');
        return;
    }
    
    chartInstances['topStoresChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.storeName),
            datasets: [{
                label: 'Revenue',
                data: data.map(d => parseFloat(d.revenue || 0)),
                backgroundColor: CHART_COLORS.primary,
                borderRadius: 5
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (context) => 'Revenue: ' + formatCurrency(context.parsed.x),
                        afterLabel: (context) => {
                            const dataPoint = data[context.dataIndex];
                            return [
                                `Profit: ${formatCurrency(dataPoint.profit)}`,
                                `Margin: ${dataPoint.profitMargin}%`
                            ];
                        }
                    }
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Top stores chart created');
}

// Regional Performance Chart
function createRegionalChart(data) {
    destroyChart('regionalChart');
    
    const ctx = document.getElementById('regionalChart');
    if (!ctx) {
        console.warn('⚠️ Regional chart canvas not found');
        return;
    }
    
    chartInstances['regionalChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.region),
            datasets: [
                {
                    label: 'Revenue',
                    data: data.map(d => parseFloat(d.revenue || 0)),
                    backgroundColor: CHART_COLORS.primary,
                    borderRadius: 5
                },
                {
                    label: 'Profit',
                    data: data.map(d => parseFloat(d.profit || 0)),
                    backgroundColor: CHART_COLORS.success,
                    borderRadius: 5
                }
            ]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        afterLabel: (context) => {
                            const dataPoint = data[context.dataIndex];
                            return [
                                `Stores: ${formatNumber(dataPoint.storeCount)}`,
                                `Employees: ${formatNumber(dataPoint.employees)}`
                            ];
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: (value) => '$' + (value / 1000).toFixed(0) + 'K'
                    }
                }
            }
        }
    });
    
    console.log('✅ Regional chart created');
}

// Cohort Visualization (Bonus Feature)
async function createCohortVisualization() {
    try {
        // This would require additional implementation
        // Placeholder for future enhancement
        console.log('ℹ️ Cohort visualization - Future enhancement');
    } catch (error) {
        console.error('❌ Error creating cohort visualization:', error);
    }
}

// Cohort Retention Visualization
// async function createCohortVisualization() {
//     destroyChart('cohortChart');
    
//     const ctx = document.getElementById('cohortChart');
//     if (!ctx) {
//         console.warn('⚠️ Cohort chart canvas not found');
//         return;
//     }
    
//     try {
//         // For now, create a simple retention summary chart
//         // You can enhance this later with a full heatmap
        
//         const dummyData = {
//             cohorts: ['2024-01', '2024-02', '2024-03', '2024-04', '2024-05', '2024-06'],
//             retention: [100, 45, 38, 32, 28, 25] // Mock retention percentages
//         };
        
//         chartInstances['cohortChart'] = new Chart(ctx, {
//             type: 'line',
//             data: {
//                 labels: dummyData.cohorts,
//                 datasets: [{
//                     label: 'Retention Rate (%)',
//                     data: dummyData.retention,
//                     borderColor: CHART_COLORS.info,
//                     backgroundColor: CHART_COLORS.info + '20',
//                     borderWidth: 3,
//                     fill: true,
//                     tension: 0.4,
//                     pointRadius: 5,
//                     pointHoverRadius: 7
//                 }]
//             },
//             options: {
//                 responsive: true,
//                 plugins: {
//                     legend: { display: true },
//                     tooltip: {
//                         callbacks: {
//                             label: (context) => `Retention: ${context.parsed.y}%`
//                         }
//                     }
//                 },
//                 scales: {
//                     y: {
//                         beginAtZero: true,
//                         max: 100,
//                         ticks: {
//                             callback: (value) => value + '%'
//                         }
//                     }
//                 }
//             }
//         });
        
//         console.log('✅ Cohort chart created (placeholder)');
        
//     } catch (error) {
//         console.error('❌ Error creating cohort visualization:', error);
//     }
// }


/* ============================================
   TABLE LOADING FUNCTIONS
   ============================================ */

// Load Top Products Table
function loadTopProductsTable(products) {
    const tbody = document.querySelector('#topProductsTable tbody');
    if (!tbody) {
        console.warn('⚠️ Top products table not found');
        return;
    }
    
    tbody.innerHTML = '';
    
    if (!products || products.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No data available</td></tr>';
        return;
    }
    
    products.forEach(product => {
        const row = `
            <tr>
                <td><strong>${product.rank || ''}</strong></td>
                <td>${product.productName || ''}</td>
                <td><span class="badge badge-info">${product.category || ''}</span></td>
                <td><strong>${formatCurrency(product.revenue)}</strong></td>
                <td>${formatNumber(product.unitsSold)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
    
    console.log('✅ Top products table loaded');
}

// Load Top Customers Table
function loadTopCustomersTable(customers) {
    const tbody = document.querySelector('#topCustomersTable tbody');
    if (!tbody) {
        console.warn('⚠️ Top customers table not found');
        return;
    }
    
    tbody.innerHTML = '';
    
    if (!customers || customers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No data available</td></tr>';
        return;
    }
    
    customers.forEach((customer, index) => {
        const row = `
            <tr>
                <td><strong>${index + 1}</strong></td>
                <td>${customer.fullName || ''}</td>
                <td>${customer.city || ''}, ${customer.state || ''}</td>
                <td><strong>${formatCurrency(customer.totalRevenue)}</strong></td>
                <td>${formatNumber(customer.totalOrders)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
    
    console.log('✅ Top customers table loaded');
}

// Load Product Details Table
function loadProductDetailsTable(products) {
    const tbody = document.querySelector('#productDetailsTable tbody');
    if (!tbody) {
        console.warn('⚠️ Product details table not found');
        return;
    }
    
    tbody.innerHTML = '';
    
    if (!products || products.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No data available</td></tr>';
        return;
    }
    
    products.forEach(product => {
        const row = `
            <tr>
                <td>${product.productName || ''}</td>
                <td>${product.category || ''}</td>
                <td>${product.brand || ''}</td>
                <td><strong>${formatCurrency(product.revenue)}</strong></td>
                <td>${formatNumber(product.unitsSold)}</td>
                <td>${product.avgRating ? parseFloat(product.avgRating).toFixed(1) + ' ⭐' : 'N/A'}</td>
                <td>${formatNumber(product.currentStock)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
    
    console.log('✅ Product details table loaded');
}

// Load Store Details Table
function loadStoreDetailsTable(stores) {
    const tbody = document.querySelector('#storeDetailsTable tbody');
    if (!tbody) {
        console.warn('⚠️ Store details table not found');
        return;
    }
    
    tbody.innerHTML = '';
    
    if (!stores || stores.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No data available</td></tr>';
        return;
    }
    
    stores.forEach(store => {
        const row = `
            <tr>
                <td>${store.storeName || ''}</td>
                <td>${store.city || ''}, ${store.state || ''}</td>
                <td><strong>${formatCurrency(store.revenue)}</strong></td>
                <td>${formatCurrency(store.expenses)}</td>
                <td><strong>${formatCurrency(store.profit)}</strong></td>
                <td>${store.profitMargin ? parseFloat(store.profitMargin).toFixed(2) + '%' : 'N/A'}</td>
                <td>${formatNumber(store.employees)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
    
    console.log('✅ Store details table loaded');
}


/* ============================================
   UTILITY FUNCTIONS
   ============================================ */

// Fetch JSON data with error handling
async function fetchJSON(url) {
    try {
        console.log(`📥 Fetching: ${url}`);
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status} - ${url}`);
        }
        
        const data = await response.json();
        console.log(`✅ Fetched: ${url}`);
        return data;
        
    } catch (error) {
        console.error(`❌ Error fetching ${url}:`, error);
        throw error;
    }
}

// Update DOM element safely
function updateElement(id, value) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = value;
    } else {
        console.warn(`⚠️ Element not found: ${id}`);
    }
}

// Format currency with proper validation
function formatCurrency(value) {
    if (value === null || value === undefined || isNaN(value)) return '$0.00';
    return '$' + parseFloat(value).toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

// Format number with proper validation
function formatNumber(value) {
    if (value === null || value === undefined || isNaN(value)) return '0';
    return parseInt(value).toLocaleString('en-US');
}

// Format percentage
function formatPercentage(value) {
    if (value === null || value === undefined || isNaN(value)) return '0.00%';
    return parseFloat(value).toFixed(2) + '%';
}

// Update last updated timestamp
function updateLastUpdated() {
    const now = new Date();
    const element = document.getElementById('lastUpdated');
    if (element) {
        element.textContent = now.toLocaleString();
    }
}

// Destroy existing chart instance
function destroyChart(chartId) {
    if (chartInstances[chartId]) {
        chartInstances[chartId].destroy();
        delete chartInstances[chartId];
        console.log(`🗑️ Destroyed chart: ${chartId}`);
    }
}

// Show loading state
function showLoadingState() {
    console.log('⏳ Loading dashboard data...');
    // You can add a loading spinner overlay here if desired
    const body = document.body;
    if (body) {
        body.style.cursor = 'wait';
    }
}

// Hide loading state
function hideLoadingState() {
    console.log('✅ Dashboard loaded successfully');
    const body = document.body;
    if (body) {
        body.style.cursor = 'default';
    }
}

// Show error message to user
function showError(message) {
    console.error('❌ ERROR:', message);
    alert('⚠️ ' + message);
}


/* ============================================
   TAB NAVIGATION
   ============================================ */

function showTab(tabName) {
    console.log(`📑 Switching to tab: ${tabName}`);
    
    // Hide all tabs
    const tabs = document.querySelectorAll('.tab-content');
    tabs.forEach(tab => tab.classList.remove('active'));
    
    // Remove active class from all buttons
    const buttons = document.querySelectorAll('.nav-btn');
    buttons.forEach(btn => btn.classList.remove('active'));
    
    // Show selected tab
    const selectedTab = document.getElementById(tabName);
    if (selectedTab) {
        selectedTab.classList.add('active');
    } else {
        console.warn(`⚠️ Tab not found: ${tabName}`);
    }
    
    // Add active class to clicked button
    if (event && event.target) {
        event.target.classList.add('active');
    }
}


/* ============================================
   REFRESH FUNCTIONS
   ============================================ */

// Refresh all dashboard data
function refreshDashboard() {
    console.log('🔄 Refreshing dashboard...');
    updateLastUpdated();
    
    // Clear cache
    dataCache = {
        sales: {},
        products: {},
        customers: {},
        stores: {}
    };
    
    // Destroy all existing charts
    Object.keys(chartInstances).forEach(chartId => {
        destroyChart(chartId);
    });
    
    // Reload all data
    loadAllData();
}

// Auto-refresh functionality (optional - commented out by default)
// Uncomment to enable auto-refresh every 5 minutes
// setInterval(refreshDashboard, 300000);


/* ============================================
   EXPORT FUNCTIONS FOR HTML
   ============================================ */

// Make functions available globally
window.showTab = showTab;
window.refreshDashboard = refreshDashboard;

// Debug helper
window.getDataCache = () => dataCache;
window.getChartInstances = () => chartInstances;

console.log('✅ Dashboard.js loaded successfully - Version 1.0.0');