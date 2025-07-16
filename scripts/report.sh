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

echo "\n== Cohort category monthly allocation =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_cohort_category_monthly;"

echo "\n== Allocation variance by cost center =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_center_allocation_variance;"

echo "\n== Unallocated entries =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_unallocated_entries;"

echo "\n== Entry allocation status =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_entry_allocation_status;"

echo "\n== Allocation gaps =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_allocation_gaps;"

echo "\n== Rule coverage =="
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -c "select * from groupscholar_cost_allocator.v_rule_coverage;"
