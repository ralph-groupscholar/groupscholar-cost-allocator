# Group Scholar Cost Allocator

Group Scholar Cost Allocator is a SQL-first cost allocation toolkit for mapping program expenses to cohorts. It defines a schema, allocation rules, and reporting views so finance and ops teams can track shared costs, apply allocation rules, and report monthly cohort spend.

## Features
- Dedicated schema with cost centers, cohorts, cost entries, allocation rules, and allocations.
- Allocation function that applies percentage rules across a date range.
- Reporting views for cohort monthly totals, cost center rollups, and unallocated items.
- Seed data for immediate reporting and demo usage.

## Tech
- SQL (PostgreSQL)
- Shell scripts for operations

## Getting started
1. Set a `DATABASE_URL` environment variable for your production database.
2. Apply schema and seed data:
   ```sh
   ./scripts/apply_prod.sh
   ```
3. Apply allocations for the seed window:
   ```sh
   ./scripts/apply_allocations.sh 2025-08-01 2025-10-31
   ```
4. View summary reports:
   ```sh
   ./scripts/report.sh
   ```

## Reports
- `groupscholar_cost_allocator.v_cohort_monthly`
- `groupscholar_cost_allocator.v_center_monthly`
- `groupscholar_cost_allocator.v_unallocated_entries`

## Testing
Run SQL checks against a non-production database you control:
```sh
./scripts/run-tests.sh
```

## Notes
- This project expects the database URL to be provided via environment variables.
- Allocation rules can overlap; the allocation function will apply all matching rules.

## License
MIT
