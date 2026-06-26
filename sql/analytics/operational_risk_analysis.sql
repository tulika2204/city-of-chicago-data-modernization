WITH permit_base AS (
    SELECT
        p.permit_id,
        p.property_sk,
        p.permit_type,
        p.permit_status,
        p.issue_date,
        p.expiration_date,
        p.closed_date,
        p.estimated_cost,
        p.ward_id,
        p.community_area_id,
        p.updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY p.permit_id
            ORDER BY p.updated_at DESC
        ) AS rn
    FROM city_ops.fact_permits p
    WHERE p.issue_date >= CURRENT_DATE - INTERVAL '24 MONTH'
),
dedup_permits AS (
    SELECT *
    FROM permit_base
    WHERE rn = 1
),
inspection_summary AS (
    SELECT
        permit_id,
        COUNT(*) AS total_inspections,
        SUM(CASE WHEN UPPER(inspection_result) = 'PASS' THEN 1 ELSE 0 END) AS passed_inspections,
        SUM(CASE WHEN UPPER(inspection_result) = 'FAIL' THEN 1 ELSE 0 END) AS failed_inspections,
        MAX(inspection_date) AS last_inspection_date
    FROM city_ops.fact_inspections
    GROUP BY permit_id
),
service_requests AS (
    SELECT
        community_area_id,
        ward_id,
        DATE_TRUNC('month', request_created_date) AS request_month,
        COUNT(*) AS total_311_requests,
        SUM(CASE WHEN request_status = 'Closed' THEN 1 ELSE 0 END) AS closed_311_requests,
        SUM(CASE
                WHEN request_type IN (
                    'BUILDING VIOLATION',
                    'VACANT AND ABANDONED BUILDINGS REPORTED',
                    'SANITATION CODE VIOLATION'
                ) THEN 1 ELSE 0
            END) AS critical_311_requests
    FROM city_ops_stg.stg_311_requests
    GROUP BY
        community_area_id,
        ward_id,
        DATE_TRUNC('month', request_created_date)
),
permit_enriched AS (
    SELECT
        p.permit_id,
        p.permit_type,
        p.permit_status,
        p.issue_date,
        p.expiration_date,
        p.closed_date,
        p.estimated_cost,
        p.ward_id,
        p.community_area_id,
        COALESCE(i.total_inspections, 0) AS total_inspections,
        COALESCE(i.passed_inspections, 0) AS passed_inspections,
        COALESCE(i.failed_inspections, 0) AS failed_inspections,
        CASE
            WHEN p.closed_date IS NOT NULL THEN p.closed_date - p.issue_date
            ELSE CURRENT_DATE - p.issue_date
        END AS permit_age_days,
        CASE
            WHEN p.closed_date IS NULL AND p.expiration_date < CURRENT_DATE THEN 1
            ELSE 0
        END AS expired_open_flag,
        CASE
            WHEN COALESCE(i.failed_inspections, 0) >= 2 THEN 1
            ELSE 0
        END AS repeat_failure_flag
    FROM dedup_permits p
    LEFT JOIN inspection_summary i
        ON p.permit_id = i.permit_id
),
community_monthly AS (
    SELECT
        community_area_id,
        ward_id,
        DATE_TRUNC('month', issue_date) AS metric_month,
        COUNT(*) AS permits_issued,
        SUM(CASE WHEN permit_status IN ('OPEN', 'IN_PROGRESS', 'PENDING') THEN 1 ELSE 0 END) AS open_permits,
        SUM(CASE WHEN closed_date IS NOT NULL THEN 1 ELSE 0 END) AS closed_permits,
        SUM(expired_open_flag) AS expired_open_permits,
        SUM(repeat_failure_flag) AS repeat_failure_permits,
        AVG(permit_age_days) AS avg_permit_age_days,
        AVG(total_inspections) AS avg_inspections_per_permit,
        SUM(estimated_cost) AS total_estimated_cost
    FROM permit_enriched
    GROUP BY
        community_area_id,
        ward_id,
        DATE_TRUNC('month', issue_date)
),
combined AS (
    SELECT
        cm.*,
        COALESCE(sr.total_311_requests, 0) AS total_311_requests,
        COALESCE(sr.closed_311_requests, 0) AS closed_311_requests,
        COALESCE(sr.critical_311_requests, 0) AS critical_311_requests
    FROM community_monthly cm
    LEFT JOIN service_requests sr
        ON cm.community_area_id = sr.community_area_id
       AND cm.ward_id = sr.ward_id
       AND cm.metric_month = sr.request_month
),
rolling AS (
    SELECT
        c.*,
        AVG(open_permits) OVER (
            PARTITION BY community_area_id
            ORDER BY metric_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3mo_avg_open_permits,
        AVG(total_311_requests) OVER (
            PARTITION BY community_area_id
            ORDER BY metric_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3mo_avg_311_requests,
        SUM(repeat_failure_permits) OVER (
            PARTITION BY community_area_id
            ORDER BY metric_month
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) AS rolling_6mo_repeat_failures,
        LAG(open_permits) OVER (
            PARTITION BY community_area_id
            ORDER BY metric_month
        ) AS prior_month_open_permits,
        LAG(total_311_requests) OVER (
            PARTITION BY community_area_id
            ORDER BY metric_month
        ) AS prior_month_311_requests
    FROM combined c
),
scored AS (
    SELECT
        r.*,
        CASE
            WHEN prior_month_open_permits IS NULL OR prior_month_open_permits = 0 THEN NULL
            ELSE ROUND(((open_permits - prior_month_open_permits) * 100.0) / prior_month_open_permits, 2)
        END AS open_permits_mom_pct,
        CASE
            WHEN prior_month_311_requests IS NULL OR prior_month_311_requests = 0 THEN NULL
            ELSE ROUND(((total_311_requests - prior_month_311_requests) * 100.0) / prior_month_311_requests, 2)
        END AS requests_mom_pct,
        PERCENT_RANK() OVER (PARTITION BY metric_month ORDER BY open_permits) AS open_permit_pct_rank,
        PERCENT_RANK() OVER (PARTITION BY metric_month ORDER BY avg_permit_age_days) AS permit_age_pct_rank,
        PERCENT_RANK() OVER (PARTITION BY metric_month ORDER BY critical_311_requests) AS critical_311_pct_rank,
        PERCENT_RANK() OVER (PARTITION BY metric_month ORDER BY repeat_failure_permits) AS repeat_failure_pct_rank
    FROM rolling r
)
SELECT
    s.community_area_id,
    dca.community_area_name,
    s.ward_id,
    dw.ward_name,
    s.metric_month,
    s.permits_issued,
    s.open_permits,
    s.closed_permits,
    s.expired_open_permits,
    s.repeat_failure_permits,
    s.avg_permit_age_days,
    s.avg_inspections_per_permit,
    s.total_estimated_cost,
    s.total_311_requests,
    s.closed_311_requests,
    s.critical_311_requests,
    s.rolling_3mo_avg_open_permits,
    s.rolling_3mo_avg_311_requests,
    s.rolling_6mo_repeat_failures,
    s.open_permits_mom_pct,
    s.requests_mom_pct,
    ROUND(
        (
            COALESCE(s.open_permit_pct_rank, 0) * 0.30 +
            COALESCE(s.permit_age_pct_rank, 0) * 0.25 +
            COALESCE(s.critical_311_pct_rank, 0) * 0.25 +
            COALESCE(s.repeat_failure_pct_rank, 0) * 0.20
        ) * 100,
        2
    ) AS composite_risk_score,
    CASE
        WHEN (
            COALESCE(s.open_permit_pct_rank, 0) * 0.30 +
            COALESCE(s.permit_age_pct_rank, 0) * 0.25 +
            COALESCE(s.critical_311_pct_rank, 0) * 0.25 +
            COALESCE(s.repeat_failure_pct_rank, 0) * 0.20
        ) >= 0.80 THEN 'CRITICAL'
        WHEN (
            COALESCE(s.open_permit_pct_rank, 0) * 0.30 +
            COALESCE(s.permit_age_pct_rank, 0) * 0.25 +
            COALESCE(s.critical_311_pct_rank, 0) * 0.25 +
            COALESCE(s.repeat_failure_pct_rank, 0) * 0.20
        ) >= 0.60 THEN 'HIGH'
        WHEN (
            COALESCE(s.open_permit_pct_rank, 0) * 0.30 +
            COALESCE(s.permit_age_pct_rank, 0) * 0.25 +
            COALESCE(s.critical_311_pct_rank, 0) * 0.25 +
            COALESCE(s.repeat_failure_pct_rank, 0) * 0.20
        ) >= 0.40 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_category
FROM scored s
LEFT JOIN city_ops.dim_community_area dca
    ON s.community_area_id = dca.community_area_id
LEFT JOIN city_ops.dim_ward dw
    ON s.ward_id = dw.ward_id
WHERE s.metric_month >= CURRENT_DATE - INTERVAL '12 MONTH'
ORDER BY composite_risk_score DESC, metric_month DESC, community_area_id;
