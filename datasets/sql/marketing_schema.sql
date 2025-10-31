
CREATE SCHEMA IF NOT EXISTS marketing;

CREATE TABLE IF NOT EXISTS marketing.campaigns (
  campaign_id int PRIMARY KEY,
  campaign_name varchar(100),
  start_date date,
  end_date date,
  budget numeric(14,2)
);

CREATE TABLE IF NOT EXISTS marketing.ads_spend (
  spend_id int PRIMARY KEY,
  campaign_id int REFERENCES marketing.campaigns(campaign_id),
  channel varchar(50),
  amount numeric(12,2),
  clicks int,
  conversions int
);

CREATE TABLE IF NOT EXISTS marketing.email_clicks (
  email_id int PRIMARY KEY,
  cust_id int REFERENCES customers.customers(cust_id),
  campaign_id int REFERENCES marketing.campaigns(campaign_id),
  sent_date date,
  opened boolean,
  clicked boolean
);
