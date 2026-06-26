SELECT
    ward_id,
    DATE_TRUNC('month', issue_date) AS metric_month,
    COUNT(*) AS permits_issued,
    AVG(estimated_cost) AS avg_estimated_cost,
    SUM(CASE WHEN permit_status IN ('OPEN', 'IN_PROGRESS', 'PENDING') THEN 1 ELSE 0 END) AS open_permits,
    SUM(CASE WHEN closed_date IS NOT NULL THEN 1 ELSE 0 END) AS closed_permits
FROM city_ops.fact_permits
GROUP BY ward_id, DATE_TRUNC('month', issue_date)
ORDER BY ward_id, metric_month DESC;
