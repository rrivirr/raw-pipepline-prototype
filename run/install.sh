#!/usr/bin/env bash
# Installs the correction/calibration DAG artifacts into Snowflake via SnowSQL,
# then loads data1.csv into TIGERLAKE_TSDB_PUBLIC_METER.
#
# Requires ../install.env with SnowSQL connection parameters, e.g.:
#   SNOWSQL_ACCOUNT=myorg-myaccount
#   SNOWSQL_PWD=secret
#   SNOWSQL_DATABASE=MYDB
#   SNOWSQL_SCHEMA=MYSCHEMA

set -euo pipefail

RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$RUN_DIR")"
LOG="$RUN_DIR/install.log"

set -a
source "install.env"
set +a

: > "$LOG"


echo "== create-readings-table.sql" | tee -a "$LOG"
snowsql -o exit_on_error=true -o friendly=false -f create-readings-table.sql

cd data
tar -xvzf data1.csv.tar.gz
cd ../
echo "== data/data1.csv -> TIGERLAKE_TSDB_PUBLIC_METER" | tee -a "$LOG"
snowsql -o exit_on_error=true -o friendly=false <<SQL
PUT file://$RUN_DIR/data/data1.csv @%TIGERLAKE_TSDB_PUBLIC_METER
  OVERWRITE = TRUE AUTO_COMPRESS = TRUE;

COPY INTO TIGERLAKE_TSDB_PUBLIC_METER
  FROM @%TIGERLAKE_TSDB_PUBLIC_METER
  FILE_FORMAT = (TYPE = CSV PARSE_HEADER = TRUE)
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
  PURGE = TRUE;
SQL

echo $BASE_DIR
for dir in 1-setup-pipelines 2-correction-pipeline-steps 3-correction-calibration-pipeline-dag; do
  while IFS= read -r f; do
    echo "== ${f#"$BASE_DIR"/pipeline}" | tee -a "$LOG"
    snowsql -o exit_on_error=true -o friendly=false -f "$f" >> "$LOG" 2>&1
  done < <(find "$BASE_DIR/pipeline/$dir" -name '*.sql' ! -name '*.test.sql' | sort)
done

echo "Install complete. Log: $LOG"
