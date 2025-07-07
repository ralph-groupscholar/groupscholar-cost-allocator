#!/bin/sh
set -euo pipefail

if [ -z "${TEST_DATABASE_URL:-}" ]; then
  echo "TEST_DATABASE_URL is required." >&2
  exit 1
fi

psql "${TEST_DATABASE_URL}" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/../sql/001_init.sql"
psql "${TEST_DATABASE_URL}" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/../sql/002_seed.sql"
psql "${TEST_DATABASE_URL}" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/../tests/smoke.sql"

psql "${TEST_DATABASE_URL}" -v ON_ERROR_STOP=1 -c "drop schema if exists groupscholar_cost_allocator cascade;"

echo "Tests completed."
