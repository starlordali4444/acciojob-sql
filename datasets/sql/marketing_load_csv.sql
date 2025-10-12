\c retailmart;
\copy marketing.campaigns    FROM 'datasets/csv/marketing/campaigns.csv'    CSV HEADER;
\copy marketing.ads_spend    FROM 'datasets/csv/marketing/ads_spend.csv'    CSV HEADER;
\copy marketing.email_clicks FROM 'datasets/csv/marketing/email_clicks.csv' CSV HEADER;
