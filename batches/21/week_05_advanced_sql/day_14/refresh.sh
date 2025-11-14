#!/bin/bash

PG_PATH="/c/Program Files/PostgreSQL/16/bin"
DB_NAME="mydb"
DB_USER="postgres"
MV_NAME="sales_summary"
LOG_FILE="$HOME/refresh_mv.log"

echo "----------------------------------------" >> "$LOG_FILE"
echo "Refresh Started: $(date)" >> "$LOG_FILE"

/c/Program\ Files/PostgreSQL/16/bin/psql.exe -U "$DB_USER" -d "$DB_NAME" -c "REFRESH MATERIALIZED VIEW CONCURRENTLY $MV_NAME;" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  echo "Status: SUCCESS ✅" >> "$LOG_FILE"
else
  echo "Status: FAILED ❌" >> "$LOG_FILE"
fi

echo "Completed At: $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
