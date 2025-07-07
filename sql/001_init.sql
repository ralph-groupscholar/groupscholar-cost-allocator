create schema if not exists groupscholar_cost_allocator;

create table if not exists groupscholar_cost_allocator.cost_centers (
  id bigserial primary key,
  name text not null unique,
  owner text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists groupscholar_cost_allocator.program_cohorts (
  id bigserial primary key,
  cohort_code text not null unique,
  program_name text not null,
  region text not null,
  start_date date not null,
  end_date date,
  created_at timestamptz not null default now()
);

create table if not exists groupscholar_cost_allocator.cost_entries (
  id bigserial primary key,
  center_id bigint not null references groupscholar_cost_allocator.cost_centers(id),
  incurred_on date not null,
  vendor text not null,
  category text not null,
  amount_usd numeric(12, 2) not null check (amount_usd >= 0),
  description text,
  created_at timestamptz not null default now()
);

create table if not exists groupscholar_cost_allocator.allocation_rules (
  id bigserial primary key,
  center_id bigint not null references groupscholar_cost_allocator.cost_centers(id),
  cohort_id bigint not null references groupscholar_cost_allocator.program_cohorts(id),
  percent numeric(5, 2) not null check (percent > 0 and percent <= 100),
  effective_start date not null,
  effective_end date,
  rationale text,
  created_at timestamptz not null default now(),
  unique (center_id, cohort_id, effective_start)
);

create table if not exists groupscholar_cost_allocator.allocations (
  id bigserial primary key,
  cost_entry_id bigint not null references groupscholar_cost_allocator.cost_entries(id),
  cohort_id bigint not null references groupscholar_cost_allocator.program_cohorts(id),
  allocated_amount numeric(12, 2) not null check (allocated_amount >= 0),
  method text not null,
  created_at timestamptz not null default now(),
  unique (cost_entry_id, cohort_id)
);

create or replace view groupscholar_cost_allocator.v_entry_allocations as
select
  ce.id as cost_entry_id,
  ce.incurred_on,
  ce.vendor,
  ce.category,
  ce.amount_usd,
  cc.name as cost_center,
  pc.cohort_code,
  pc.program_name,
  a.allocated_amount,
  a.method
from groupscholar_cost_allocator.cost_entries ce
join groupscholar_cost_allocator.cost_centers cc on cc.id = ce.center_id
left join groupscholar_cost_allocator.allocations a on a.cost_entry_id = ce.id
left join groupscholar_cost_allocator.program_cohorts pc on pc.id = a.cohort_id;

create or replace view groupscholar_cost_allocator.v_unallocated_entries as
select
  ce.id as cost_entry_id,
  ce.incurred_on,
  ce.vendor,
  ce.category,
  ce.amount_usd,
  cc.name as cost_center,
  ce.description
from groupscholar_cost_allocator.cost_entries ce
join groupscholar_cost_allocator.cost_centers cc on cc.id = ce.center_id
left join groupscholar_cost_allocator.allocations a on a.cost_entry_id = ce.id
where a.id is null;

create or replace view groupscholar_cost_allocator.v_cohort_monthly as
select
  pc.cohort_code,
  pc.program_name,
  date_trunc('month', ce.incurred_on) as month,
  sum(a.allocated_amount) as allocated_total
from groupscholar_cost_allocator.allocations a
join groupscholar_cost_allocator.cost_entries ce on ce.id = a.cost_entry_id
join groupscholar_cost_allocator.program_cohorts pc on pc.id = a.cohort_id
group by pc.cohort_code, pc.program_name, date_trunc('month', ce.incurred_on)
order by month desc, pc.cohort_code;

create or replace view groupscholar_cost_allocator.v_center_monthly as
select
  cc.name as cost_center,
  date_trunc('month', ce.incurred_on) as month,
  sum(ce.amount_usd) as total_spend
from groupscholar_cost_allocator.cost_entries ce
join groupscholar_cost_allocator.cost_centers cc on cc.id = ce.center_id
group by cc.name, date_trunc('month', ce.incurred_on)
order by month desc, cc.name;

create or replace function groupscholar_cost_allocator.apply_allocations_for_range(
  p_start date,
  p_end date
) returns integer
language plpgsql
as $$
declare
  inserted_count integer := 0;
begin
  insert into groupscholar_cost_allocator.allocations (
    cost_entry_id,
    cohort_id,
    allocated_amount,
    method
  )
  select
    ce.id,
    ar.cohort_id,
    round(ce.amount_usd * ar.percent / 100.0, 2),
    'rule'
  from groupscholar_cost_allocator.cost_entries ce
  join groupscholar_cost_allocator.allocation_rules ar
    on ar.center_id = ce.center_id
   and ce.incurred_on >= ar.effective_start
   and (ar.effective_end is null or ce.incurred_on <= ar.effective_end)
  where ce.incurred_on between p_start and p_end
  on conflict do nothing;

  get diagnostics inserted_count = row_count;
  return inserted_count;
end;
$$;
