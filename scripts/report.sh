#!/bin/sh
set -euo pipefail

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is required." >&2
  exit 1
fi

echo "== Cohort monthly allocation =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_cohort_monthly;"

echo "\n== Cost center monthly spend =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_center_monthly;"

echo "\n== Unallocated entries =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_unallocated_entries;"
