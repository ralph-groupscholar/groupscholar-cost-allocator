select count(*) as cost_centers from groupscholar_cost_allocator.cost_centers;
select count(*) as cohorts from groupscholar_cost_allocator.program_cohorts;
select groupscholar_cost_allocator.apply_allocations_for_range('2025-08-01', '2025-10-31') as inserted_allocations;
select count(*) as allocations from groupscholar_cost_allocator.allocations;
