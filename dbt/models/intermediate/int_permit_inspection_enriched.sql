with permits as (
    select * from {{ ref('stg_permits') }}
),
inspection_summary as (
    select
        permit_id,
        count(*) as total_inspections,
        sum(case when upper(inspection_result) = 'PASS' then 1 else 0 end) as passed_inspections,
        sum(case when upper(inspection_result) = 'FAIL' then 1 else 0 end) as failed_inspections
    from {{ source('city_ops', 'fact_inspections') }}
    group by permit_id
)
select
    p.*,
    coalesce(i.total_inspections, 0) as total_inspections,
    coalesce(i.passed_inspections, 0) as passed_inspections,
    coalesce(i.failed_inspections, 0) as failed_inspections
from permits p
left join inspection_summary i
    on p.permit_id = i.permit_id
