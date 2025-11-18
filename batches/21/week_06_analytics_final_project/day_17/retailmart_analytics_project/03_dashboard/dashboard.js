// File: 05_dashboard/dashboard.js

/* ============================================
   RETAILMART ANALYTICS DASHBOARD JAVASCRIPT
   ============================================ */

// Sample data - Replace with actual API/database calls
const dashboardData = {
    executive: {
        kpis: {
            totalRevenue: 5284392.50,
            totalOrders: 12547,
            totalCustomers: 8432,
            avgOrderValue: 421.15
        },
        monthlyRevenue: [
            { month: 'Jan', revenue: 385000 },
            { month: 'Feb', revenue: 412000 },
            { month: 'Mar', revenue: 445000 },
            { month: 'Apr', revenue: 425000 },
            { month: 'May', revenue: 468000 },
            { month: 'Jun', revenue: 492000 },
            { month: 'Jul', revenue: 515000 },
            { month: 'Aug', revenue: 485000 },
            { month: 'Sep', revenue: 502000 },
            { month: 'Oct', revenue: 535000 },
            { month: 'Nov', revenue: 562000 },
            { month: 'Dec', revenue: 598000 }
        ],
        categoryRevenue: [
            { category: 'Electronics', revenue: 1250000 },
            { category: 'Clothing', revenue: 980000 },
            { category: 'Home & Garden', revenue: 850000 },
            { category: 'Sports', revenue: 720000 },
            { category: 'Books', revenue: 485000 }
        ],
        topProducts: [
            { rank: 1, name: 'Wireless Headphones Pro', category: 'Electronics', revenue: 125000, units: 2500 },
            { rank: 2, name: 'Smart Watch Ultra', category: 'Electronics', revenue: 118000, units: 1180 },
            { rank: 3, name: 'Gaming Laptop X1', category: 'Electronics', revenue: 95000, units: 190 },
            { rank: 4, name: 'Designer Jeans Premium', category: 'Clothing', revenue: 78000, units: 1560 },
            { rank: 5, name: 'Running Shoes Elite', category: 'Sports', revenue: 72000, units: 720 },
            { rank: 6, name: '4K Smart TV 55"', category: 'Electronics', revenue: 68000, units: 136 },
            { rank: 7, name: 'Coffee Maker Deluxe', category: 'Home & Garden', revenue: 54000, units: 540 },
            { rank: 8, name: 'Yoga Mat Premium', category: 'Sports', revenue: 48000, units: 1600 },
            { rank: 9, name: 'Office Chair Ergonomic', category: 'Home & Garden', revenue: 45000, units: 450 },
            { rank: 10, name: 'Cookbook Collection', category: 'Books', revenue: 42000, units: 2100 }
        ],
        topCustomers: [
            { rank: 1, name: 'John Anderson', location: 'New York, NY', spent: 25480, orders: 45 },
            { rank: 2, name: 'Sarah Williams', location: 'Los Angeles, CA', spent: 23250, orders: 38 },
            { rank: 3, name: 'Michael Chen', location: 'San Francisco, CA', spent: 21890, orders: 42 },
            { rank: 4, name: 'Emily Rodriguez', location: 'Chicago, IL', spent: 19650, orders: 35 },
            { rank: 5, name: 'David Kumar', location: 'Houston, TX', spent: 18420, orders: 31 },
            { rank: 6, name: 'Lisa Thompson', location: 'Phoenix, AZ', spent: 17280, orders: 29 },
            { rank: 7, name: 'James Wilson', location: 'Philadelphia, PA', spent: 16850, orders: 27 },
            { rank: 8, name: 'Maria Garcia', location: 'San Diego, CA', spent: 15920, orders: 25 },
            { rank: 9, name: 'Robert Brown', location: 'Dallas, TX', spent: 14750, orders: 23 },
            { rank: 10, name: 'Jennifer Lee', location: 'Austin, TX', spent: 13680, orders: 21 }
        ]
    }
};

// Chart configurations
const chartColors = {
    primary: '#2563eb',
    secondary: '#7c3aed',
    success: '#10b981',
    danger: '#ef4444',
    warning: '#f59e0b',
    info: '#06b6d4'
};

// Initialize Dashboard
document.addEventListener('DOMContentLoaded', function() {
    updateLastUpdated();
    loadExecutiveSummary();
    initializeCharts();
});

// Update timestamp
function updateLastUpdated() {
    const now = new Date();
    document.getElementById('lastUpdated').textContent = now.toLocaleString();
}

// Tab Navigation
function showTab(tabName) {
    // Hide all tabs
    const tabs = document.querySelectorAll('.tab-content');
    tabs.forEach(tab => tab.classList.remove('active'));
    
    // Remove active class from all buttons
    const buttons = document.querySelectorAll('.nav-btn');
    buttons.forEach(btn => btn.classList.remove('active'));
    
    // Show selected tab
    document.getElementById(tabName).classList.add('active');
    
    // Add active class to clicked button
    event.target.classList.add('active');
}

// Load Executive Summary Data
function loadExecutiveSummary() {
    const data = dashboardData.executive;
    
    // Update KPI cards
    document.getElementById('totalRevenue').textContent = formatCurrency(data.kpis.totalRevenue);
    document.getElementById('totalOrders').textContent = formatNumber(data.kpis.totalOrders);
    document.getElementById('totalCustomers').textContent = formatNumber(data.kpis.totalCustomers);
    document.getElementById('avgOrderValue').textContent = formatCurrency(data.kpis.avgOrderValue);
    
    // Load Top Products Table
    loadTopProductsTable(data.topProducts);
    
    // Load Top Customers Table
    loadTopCustomersTable(data.topCustomers);
}

// Load Top Products Table
function loadTopProductsTable(products) {
    const tbody = document.querySelector('#topProductsTable tbody');
    tbody.innerHTML = '';
    
    products.forEach(product => {
        const row = `
            <tr>
                <td><strong>${product.rank}</strong></td>
                <td>${product.name}</td>
                <td><span class="badge badge-info">${product.category}</span></td>
                <td><strong>${formatCurrency(product.revenue)}</strong></td>
                <td>${formatNumber(product.units)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Load Top Customers Table
function loadTopCustomersTable(customers) {
    const tbody = document.querySelector('#topCustomersTable tbody');
    tbody.innerHTML = '';
    
    customers.forEach(customer => {
        const row = `
            <tr>
                <td><strong>${customer.rank}</strong></td>
                <td>${customer.name}</td>
                <td>${customer.location}</td>
                <td><strong>${formatCurrency(customer.spent)}</strong></td>
                <td>${customer.orders}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Initialize All Charts
function initializeCharts() {
    createRevenueChart();
    createCategoryChart();
}

// Monthly Revenue Chart
function createRevenueChart() {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    const data = dashboardData.executive.monthlyRevenue;
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.map(d => d.month),
            datasets: [{
                label: 'Revenue',
                data: data.map(d => d.revenue),
                borderColor: chartColors.primary,
                backgroundColor: chartColors.primary + '20',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 5,
                pointHoverRadius: 7,
                pointBackgroundColor: chartColors.primary,
                pointBorderColor: '#fff',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: { size: 14, weight: 'bold' },
                    bodyFont: { size: 13 },
                    callbacks: {
                        label: function(context) {
                            return 'Revenue: $' + context.parsed.y.toLocaleString();
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '$' + (value / 1000) + 'K';
                        }
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
}

// Category Revenue Chart
function createCategoryChart() {
    const ctx = document.getElementById('categoryChart').getContext('2d');
    const data = dashboardData.executive.categoryRevenue;
    
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.map(d => d.category),
            datasets: [{
                data: data.map(d => d.revenue),
                backgroundColor: [
                    chartColors.primary,
                    chartColors.secondary,
                    chartColors.success,
                    chartColors.warning,
                    chartColors.info
                ],
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
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return label + ': $' + value.toLocaleString() + ' (' + percentage + '%)';
                        }
                    }
                }
            }
        }
    });
}

// Utility Functions
function formatCurrency(value) {
    return '$' + value.toLocaleString('en-US', { 
        minimumFractionDigits: 2, 
        maximumFractionDigits: 2 
    });
}

function formatNumber(value) {
    return value.toLocaleString('en-US');
}

function formatPercentage(value) {
    return value.toFixed(2) + '%';
}

// Export function for data refresh (can be called via button or timer)
function refreshDashboard() {
    updateLastUpdated();
    loadExecutiveSummary();
    // Add calls to refresh charts and other data
    console.log('Dashboard refreshed');
}

// Auto-refresh every 5 minutes (optional)
// setInterval(refreshDashboard, 300000);