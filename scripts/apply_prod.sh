#!/bin/sh
set -euo pipefail

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is required." >&2
  exit 1
fi

psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/../sql/001_init.sql"
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/../sql/002_seed.sql"

echo "Schema and seed data applied."
