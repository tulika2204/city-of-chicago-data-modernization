with monthly_metrics as (
    select
        community_area_id,
        ward_id,
        date_trunc('month', issue_date) as metric_month,
        count(*) as permits_issued,
        sum(case when permit_status in ('OPEN', 'IN_PROGRESS', 'PENDING') then 1 else 0 end) as open_permits,
        avg(total_inspections) as avg_inspections_per_permit,
        avg(case
                when closed_date is not null then closed_date - issue_date
                else current_date - issue_date
            end) as avg_permit_age_days
    from {{ ref('int_permit_inspection_enriched') }}
    group by community_area_id, ward_id, date_trunc('month', issue_date)
)
select
    *,
    percent_rank() over (partition by metric_month order by open_permits) as open_permit_pct_rank,
    percent_rank() over (partition by metric_month order by avg_permit_age_days) as permit_age_pct_rank
from monthly_metrics
