#!/bin/sh
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <start_date> <end_date>" >&2
  exit 1
fi

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is required." >&2
  exit 1
fi

START_DATE="$1"
END_DATE="$2"

psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 <<SQL
select groupscholar_cost_allocator.apply_allocations_for_range('${START_DATE}', '${END_DATE}') as inserted_allocations;
SQL
