insert into groupscholar_cost_allocator.cost_centers (name, owner, notes)
values
  ('Program Delivery', 'Ops', 'Direct delivery costs and logistics'),
  ('Scholar Support', 'Student Success', 'Coaching, advising, and scholar care'),
  ('Platform Services', 'Tech', 'Shared tools and infrastructure')
on conflict (name) do nothing;

insert into groupscholar_cost_allocator.program_cohorts (cohort_code, program_name, region, start_date, end_date)
values
  ('GS-COH-2025-FALL', 'Launch Scholars', 'Midwest', '2025-08-15', '2025-12-15'),
  ('GS-COH-2025-SUM', 'Bridge Scholars', 'Southeast', '2025-06-01', '2025-09-30'),
  ('GS-COH-2025-ALUM', 'Alumni Success', 'National', '2025-01-01', null)
on conflict (cohort_code) do nothing;

insert into groupscholar_cost_allocator.cost_entries (center_id, incurred_on, vendor, category, amount_usd, description)
select cc.id, v.incurred_on, v.vendor, v.category, v.amount_usd, v.description
from (
  values
    ('Program Delivery', date '2025-08-20', 'BrightPath Logistics', 'Travel', 1840.50, 'Cohort kickoff travel support'),
    ('Program Delivery', date '2025-09-10', 'VenueWorks', 'Events', 2650.00, 'Cohort summit venue'),
    ('Scholar Support', date '2025-08-25', 'CareBridge Counseling', 'Coaching', 1320.00, 'Coaching hours for cohort'),
    ('Scholar Support', date '2025-09-18', 'Northside Wellness', 'Wellness', 980.00, 'Wellness stipends'),
    ('Platform Services', date '2025-08-05', 'CloudDock', 'Infrastructure', 2100.00, 'Platform hosting'),
    ('Platform Services', date '2025-09-05', 'SignalPulse', 'Analytics', 780.00, 'Community analytics tooling')
) as v(center_name, incurred_on, vendor, category, amount_usd, description)
join groupscholar_cost_allocator.cost_centers cc on cc.name = v.center_name
on conflict do nothing;

insert into groupscholar_cost_allocator.allocation_rules (center_id, cohort_id, percent, effective_start, effective_end, rationale)
select cc.id, pc.id, v.percent, v.effective_start, v.effective_end, v.rationale
from (
  values
    ('Program Delivery', 'GS-COH-2025-FALL', 60.00, date '2025-08-01', date '2025-12-31', 'Primary delivery focus'),
    ('Program Delivery', 'GS-COH-2025-SUM', 40.00, date '2025-08-01', date '2025-09-30', 'Summer bridge wrap-up'),
    ('Scholar Support', 'GS-COH-2025-FALL', 55.00, date '2025-08-01', date '2025-12-31', 'Main coaching allocation'),
    ('Scholar Support', 'GS-COH-2025-ALUM', 45.00, date '2025-01-01', null, 'Ongoing alumni support'),
    ('Platform Services', 'GS-COH-2025-FALL', 70.00, date '2025-08-01', date '2025-12-31', 'Platform usage share'),
    ('Platform Services', 'GS-COH-2025-ALUM', 30.00, date '2025-01-01', null, 'Alumni platform usage')
) as v(center_name, cohort_code, percent, effective_start, effective_end, rationale)
join groupscholar_cost_allocator.cost_centers cc on cc.name = v.center_name
join groupscholar_cost_allocator.program_cohorts pc on pc.cohort_code = v.cohort_code
on conflict do nothing;
