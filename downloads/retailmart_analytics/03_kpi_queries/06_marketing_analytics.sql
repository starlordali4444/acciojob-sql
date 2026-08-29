-- Windows fix: force psql to read this UTF-8 file correctly (keep as first line)
\encoding UTF8

-- ============================================================================
-- FILE: 03_kpi_queries/06_marketing_analytics.sql
-- PROJECT: RetailMart V3 Enterprise Analytics Platform
-- PURPOSE: Marketing Analytics — Campaigns, Platforms, Promotions, Email + Web Events
-- AUTHOR: Sayyed Siraj Ali
-- VERSION: 3.0 (RetailMart V3)
-- DATABASE: accio_retailmart_NN (PostgreSQL 18)
--
-- V2 CHANGES:
--   - ads_spend.channel → ads_spend.platform
--   - ads_spend.clicks / ads_spend.conversions → REMOVED (don't exist in V2)
--   - Campaign ROI calculated from spend vs revenue during campaign period
--   - total_amount → net_total
--   - email_clicks: no cust_id, has emails_sent/emails_opened/emails_clicked as INT counts
--   - NEW: 4 web events views (traffic, devices, top pages, event funnel)
--
-- CREATES: 8 Views + 1 MV + 5 JSON Functions
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '        MARKETING ANALYTICS MODULE (V2) — STARTING                          '
\echo '============================================================================'
\echo ''

-- ============================================================================
-- VIEW 1: CAMPAIGN PERFORMANCE (V2: no clicks/conversions)
-- ============================================================================

\echo '[1/9] Creating view: vw_campaign_performance...'

CREATE OR REPLACE VIEW analytics.vw_campaign_performance AS
WITH campaign_spend AS (
    SELECT 
        c.campaign_id, c.campaign_name, c.start_date, c.end_date, c.budget,
        COALESCE(SUM(a.amount), 0) as actual_spend,
        COUNT(DISTINCT a.platform) as platforms_used,
        STRING_AGG(DISTINCT a.platform, ', ') as platform_list
    FROM marketing.campaigns c
    LEFT JOIN marketing.ads_spend a ON c.campaign_id = a.campaign_id
    GROUP BY c.campaign_id, c.campaign_name, c.start_date, c.end_date, c.budget
),
campaign_revenue AS (
    SELECT c.campaign_id,
        COUNT(DISTINCT o.order_id) as orders_during_campaign,
        COALESCE(SUM(o.net_total), 0) as revenue_during_campaign
    FROM marketing.campaigns c
    LEFT JOIN sales.orders o ON o.order_date BETWEEN c.start_date AND c.end_date AND o.order_status = 'Delivered'
    GROUP BY c.campaign_id
)
SELECT 
    cs.campaign_id, cs.campaign_name, cs.start_date, cs.end_date,
    cs.end_date - cs.start_date as duration_days,
    ROUND(cs.budget::NUMERIC, 2) as budget,
    ROUND(cs.actual_spend::NUMERIC, 2) as actual_spend,
    ROUND((cs.actual_spend / NULLIF(cs.budget, 0) * 100)::NUMERIC, 2) as budget_utilization_pct,
    cs.platforms_used, cs.platform_list,
    cr.orders_during_campaign,
    ROUND(cr.revenue_during_campaign::NUMERIC, 2) as attributed_revenue,
    CASE WHEN cs.actual_spend > 0 
        THEN ROUND(((cr.revenue_during_campaign - cs.actual_spend) / cs.actual_spend * 100)::NUMERIC, 2) 
        ELSE 0 
    END as roi_pct,
    CASE WHEN cr.orders_during_campaign > 0 
        THEN ROUND((cs.actual_spend / cr.orders_during_campaign)::NUMERIC, 2) 
        ELSE 0 
    END as cost_per_order,
    CASE 
        WHEN cs.actual_spend = 0 THEN 'Not Started'
        WHEN ((cr.revenue_during_campaign - cs.actual_spend) / NULLIF(cs.actual_spend, 0) * 100) >= 200 THEN 'Excellent'
        WHEN ((cr.revenue_during_campaign - cs.actual_spend) / NULLIF(cs.actual_spend, 0) * 100) >= 100 THEN 'Good'
        WHEN ((cr.revenue_during_campaign - cs.actual_spend) / NULLIF(cs.actual_spend, 0) * 100) >= 0 THEN 'Break Even'
        ELSE 'Losing Money'
    END as campaign_status
FROM campaign_spend cs
LEFT JOIN campaign_revenue cr ON cs.campaign_id = cr.campaign_id
ORDER BY cs.start_date DESC;

COMMENT ON VIEW analytics.vw_campaign_performance IS 'Campaign ROI based on spend vs revenue — V2 no click data';
\echo '      ✓ View created: vw_campaign_performance'


-- ============================================================================
-- VIEW 2: PLATFORM PERFORMANCE (V2: channel → platform, no clicks/conversions)
-- ============================================================================

\echo '[2/9] Creating view: vw_channel_performance...'

CREATE OR REPLACE VIEW analytics.vw_channel_performance AS
SELECT 
    a.platform,
    COUNT(DISTINCT a.campaign_id) as campaigns_using,
    COUNT(DISTINCT a.spend_date) as active_days,
    ROUND(SUM(a.amount)::NUMERIC, 2) as total_spend,
    ROUND(AVG(a.amount)::NUMERIC, 2) as avg_daily_spend,
    ROUND((SUM(a.amount) / SUM(SUM(a.amount)) OVER () * 100)::NUMERIC, 2) as pct_of_total_spend,
    RANK() OVER (ORDER BY SUM(a.amount) DESC) as spend_rank
FROM marketing.ads_spend a
GROUP BY a.platform
ORDER BY total_spend DESC;

COMMENT ON VIEW analytics.vw_channel_performance IS 'Ad spend by platform — V2 simplified (no click data)';
\echo '      ✓ View created: vw_channel_performance'


-- ============================================================================
-- VIEW 3: PROMOTION EFFECTIVENESS (V2: net_total)
-- ============================================================================

\echo '[3/9] Creating view: vw_promotion_effectiveness...'

CREATE OR REPLACE VIEW analytics.vw_promotion_effectiveness AS
WITH promo_sales AS (
    SELECT p.promo_id, p.promo_name, p.start_date, p.end_date, p.discount_percent,
        COUNT(DISTINCT o.order_id) as orders, SUM(o.net_total) as revenue
    FROM products.promotions p
    LEFT JOIN sales.orders o ON o.order_date BETWEEN p.start_date AND p.end_date AND o.order_status = 'Delivered'
    GROUP BY p.promo_id, p.promo_name, p.start_date, p.end_date, p.discount_percent
)
SELECT promo_id, promo_name, start_date, end_date, 
    end_date - start_date as duration_days, discount_percent,
    COALESCE(orders, 0) as orders, ROUND(COALESCE(revenue, 0)::NUMERIC, 2) as revenue,
    ROUND((COALESCE(orders, 0)::NUMERIC / NULLIF(end_date - start_date, 0)), 2) as orders_per_day
FROM promo_sales ORDER BY start_date DESC;

COMMENT ON VIEW analytics.vw_promotion_effectiveness IS 'Promotion impact on orders and revenue';
\echo '      ✓ View created: vw_promotion_effectiveness'


-- ============================================================================
-- VIEW 4: EMAIL ENGAGEMENT (V2: emails_sent/opened/clicked are INT columns)
-- ============================================================================

\echo '[4/9] Creating view: vw_email_engagement...'

CREATE OR REPLACE VIEW analytics.vw_email_engagement AS
SELECT 
    c.campaign_id, c.campaign_name,
    DATE_TRUNC('month', e.sent_date)::DATE as send_month,
    SUM(e.emails_sent) as total_sent,
    SUM(e.emails_opened) as total_opened,
    SUM(e.emails_clicked) as total_clicked,
    ROUND((SUM(e.emails_opened)::NUMERIC / NULLIF(SUM(e.emails_sent), 0) * 100), 2) as open_rate_pct,
    ROUND((SUM(e.emails_clicked)::NUMERIC / NULLIF(SUM(e.emails_sent), 0) * 100), 2) as click_rate_pct,
    ROUND((SUM(e.emails_clicked)::NUMERIC / NULLIF(SUM(e.emails_opened), 0) * 100), 2) as click_to_open_rate_pct
FROM marketing.email_clicks e
JOIN marketing.campaigns c ON e.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name, DATE_TRUNC('month', e.sent_date)
ORDER BY send_month DESC;

COMMENT ON VIEW analytics.vw_email_engagement IS 'Email campaign open/click rates — V2 aggregated counts';
\echo '      ✓ View created: vw_email_engagement'


-- ============================================================================
-- 🆕 VIEW 5: WEB TRAFFIC SUMMARY (NEW in V2)
-- ============================================================================

\echo '[5/9] Creating view: vw_web_traffic_summary...'

CREATE OR REPLACE VIEW analytics.vw_web_traffic_summary AS
SELECT 
    DATE_TRUNC('day', view_timestamp)::DATE as traffic_date,
    COUNT(*) as page_views,
    COUNT(DISTINCT session_id) as unique_sessions,
    COUNT(DISTINCT customer_id) as identified_users,
    ROUND(COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT session_id), 0), 2) as pages_per_session,
    COUNT(DISTINCT device_type) as device_types_seen
FROM web_events.page_views
GROUP BY DATE_TRUNC('day', view_timestamp)
ORDER BY traffic_date DESC;

COMMENT ON VIEW analytics.vw_web_traffic_summary IS 'Daily web traffic metrics';
\echo '      ✓ View created: vw_web_traffic_summary'


-- ============================================================================
-- 🆕 VIEW 6: WEB DEVICE & OS BREAKDOWN (NEW in V2)
-- ============================================================================

\echo '[6/9] Creating view: vw_web_device_os_breakdown...'

CREATE OR REPLACE VIEW analytics.vw_web_device_os_breakdown AS
SELECT 
    device_type,
    os,
    COUNT(*) as page_views,
    COUNT(DISTINCT session_id) as sessions,
    COUNT(DISTINCT customer_id) as unique_users,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_views,
    ROUND((COUNT(DISTINCT session_id)::NUMERIC / SUM(COUNT(DISTINCT session_id)) OVER () * 100), 2) as pct_of_sessions
FROM web_events.page_views
GROUP BY device_type, os
ORDER BY page_views DESC;

COMMENT ON VIEW analytics.vw_web_device_os_breakdown IS 'Traffic by device type and operating system';
\echo '      ✓ View created: vw_web_device_os_breakdown'


-- ============================================================================
-- 🆕 VIEW 7: WEB TOP PAGES (NEW in V2)
-- ============================================================================

\echo '[7/9] Creating view: vw_web_top_pages...'

CREATE OR REPLACE VIEW analytics.vw_web_top_pages AS
SELECT 
    page_url,
    COUNT(*) as view_count,
    COUNT(DISTINCT session_id) as unique_sessions,
    COUNT(DISTINCT customer_id) as unique_users,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_total_views,
    RANK() OVER (ORDER BY COUNT(*) DESC) as popularity_rank
FROM web_events.page_views
GROUP BY page_url
ORDER BY view_count DESC;

COMMENT ON VIEW analytics.vw_web_top_pages IS 'Most visited pages ranked by view count';
\echo '      ✓ View created: vw_web_top_pages'


-- ============================================================================
-- 🆕 VIEW 8: WEB EVENT FUNNEL (NEW in V2)
-- ============================================================================

\echo '[8/9] Creating view: vw_web_event_funnel...'

CREATE OR REPLACE VIEW analytics.vw_web_event_funnel AS
SELECT 
    e.event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT pv.session_id) as sessions_with_event,
    COUNT(DISTINCT pv.customer_id) as users_with_event,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) as pct_of_events,
    RANK() OVER (ORDER BY COUNT(*) DESC) as frequency_rank
FROM web_events.events e
JOIN web_events.page_views pv ON e.view_id = pv.view_id
GROUP BY e.event_type
ORDER BY event_count DESC;

COMMENT ON VIEW analytics.vw_web_event_funnel IS 'Event type distribution for funnel analysis';
\echo '      ✓ View created: vw_web_event_funnel'


-- ============================================================================
-- MATERIALIZED VIEW: MARKETING ROI (V2: no clicks/conversions)
-- ============================================================================

\echo '[9/9] Creating materialized view: mv_marketing_roi...'

DROP MATERIALIZED VIEW IF EXISTS analytics.mv_marketing_roi CASCADE;

CREATE MATERIALIZED VIEW analytics.mv_marketing_roi AS
WITH campaign_totals AS (
    SELECT 
        COUNT(DISTINCT c.campaign_id) as total_campaigns,
        ROUND(SUM(c.budget)::NUMERIC, 2) as total_budget,
        ROUND(COALESCE(SUM(a.amount), 0)::NUMERIC, 2) as total_spend,
        COUNT(DISTINCT a.platform) as platforms_used
    FROM marketing.campaigns c
    LEFT JOIN marketing.ads_spend a ON c.campaign_id = a.campaign_id
),
email_totals AS (
    SELECT 
        SUM(emails_sent) as total_emails_sent,
        SUM(emails_opened) as total_emails_opened,
        SUM(emails_clicked) as total_emails_clicked
    FROM marketing.email_clicks
),
web_totals AS (
    SELECT 
        COUNT(*) as total_page_views,
        COUNT(DISTINCT session_id) as total_sessions,
        COUNT(DISTINCT customer_id) as total_web_users
    FROM web_events.page_views
)
SELECT 
    (SELECT MAX(order_date) FROM sales.orders) as reference_date,
    ct.total_campaigns, ct.total_budget, ct.total_spend, ct.platforms_used,
    ROUND((ct.total_spend / NULLIF(ct.total_budget, 0) * 100)::NUMERIC, 2) as budget_utilization_pct,
    et.total_emails_sent, et.total_emails_opened, et.total_emails_clicked,
    ROUND((et.total_emails_opened::NUMERIC / NULLIF(et.total_emails_sent, 0) * 100), 2) as overall_open_rate,
    ROUND((et.total_emails_clicked::NUMERIC / NULLIF(et.total_emails_sent, 0) * 100), 2) as overall_click_rate,
    wt.total_page_views, wt.total_sessions, wt.total_web_users
FROM campaign_totals ct
CROSS JOIN email_totals et
CROSS JOIN web_totals wt;

COMMENT ON MATERIALIZED VIEW analytics.mv_marketing_roi IS 'Marketing overview with spend, email, and web metrics — V2';
\echo '      ✓ Materialized view created: mv_marketing_roi'


-- ============================================================================
-- JSON EXPORT FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Creating JSON export functions...'

CREATE OR REPLACE FUNCTION analytics.get_marketing_summary_json()
RETURNS JSON AS $$
BEGIN RETURN (SELECT row_to_json(t) FROM analytics.mv_marketing_roi t); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_campaign_performance_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'campaignName', campaign_name, 'budget', budget, 'spend', actual_spend,
        'budgetUtil', budget_utilization_pct, 'platforms', platform_list,
        'orders', orders_during_campaign, 'revenue', attributed_revenue,
        'roi', roi_pct, 'costPerOrder', cost_per_order, 'status', campaign_status
    ) ORDER BY start_date DESC)
    FROM analytics.vw_campaign_performance LIMIT 20
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_channel_performance_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'platform', platform, 'campaigns', campaigns_using, 'spend', total_spend,
        'avgDailySpend', avg_daily_spend, 'pctOfSpend', pct_of_total_spend, 'rank', spend_rank
    ) ORDER BY total_spend DESC)
    FROM analytics.vw_channel_performance
); END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION analytics.get_email_engagement_json()
RETURNS JSON AS $$
BEGIN RETURN (
    SELECT json_agg(json_build_object(
        'campaignName', campaign_name, 'sent', total_sent, 'opened', total_opened,
        'clicked', total_clicked, 'openRate', open_rate_pct, 'clickRate', click_rate_pct,
        'clickToOpen', click_to_open_rate_pct
    ) ORDER BY send_month DESC)
    FROM analytics.vw_email_engagement LIMIT 20
); END;
$$ LANGUAGE plpgsql STABLE;

-- 🆕 JSON 5: Web Analytics
CREATE OR REPLACE FUNCTION analytics.get_web_analytics_json()
RETURNS JSON AS $$
BEGIN RETURN json_build_object(
    'dailyTraffic', (
        SELECT json_agg(json_build_object('date', traffic_date, 'pageViews', page_views,
            'sessions', unique_sessions, 'pagesPerSession', pages_per_session) ORDER BY traffic_date DESC)
        FROM analytics.vw_web_traffic_summary LIMIT 30
    ),
    'devices', (
        SELECT json_agg(json_build_object('device', device_type, 'os', os,
            'views', page_views, 'pctOfViews', pct_of_views))
        FROM analytics.vw_web_device_os_breakdown
    ),
    'topPages', (
        SELECT json_agg(json_build_object('page', page_url, 'views', view_count,
            'sessions', unique_sessions, 'rank', popularity_rank))
        FROM analytics.vw_web_top_pages LIMIT 20
    ),
    'eventFunnel', (
        SELECT json_agg(json_build_object('eventType', event_type, 'count', event_count,
            'sessions', sessions_with_event, 'pct', pct_of_events))
        FROM analytics.vw_web_event_funnel
    )
); END;
$$ LANGUAGE plpgsql STABLE;

\echo '      ✓ JSON functions created (5 functions)'

REFRESH MATERIALIZED VIEW analytics.mv_marketing_roi;

\echo ''
\echo '============================================================================'
\echo '        MARKETING ANALYTICS MODULE (V2) — COMPLETE                          '
\echo '============================================================================'
\echo ''
\echo '✅ Views (8): campaigns, platform, promotions, email,'
\echo '   web traffic, web devices, web top pages, web event funnel'
\echo '✅ MVs (1): mv_marketing_roi (with email + web summary)'
\echo '✅ JSON (5): 4 existing + web_analytics'
\echo ''
\echo '➡️  Next: Run 07_finance_hr_analytics.sql'
\echo '============================================================================'
\echo ''