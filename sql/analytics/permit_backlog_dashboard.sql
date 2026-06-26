SELECT
    ward_id,
    community_area_id,
    COUNT(*) AS total_permits,
    SUM(CASE WHEN permit_status IN ('OPEN', 'IN_PROGRESS', 'PENDING') THEN 1 ELSE 0 END) AS open_permits,
    SUM(CASE WHEN closed_date IS NOT NULL THEN 1 ELSE 0 END) AS closed_permits,
    AVG(CASE
            WHEN closed_date IS NOT NULL THEN closed_date - issue_date
            ELSE CURRENT_DATE - issue_date
        END) AS avg_cycle_time_days,
    SUM(CASE
            WHEN closed_date IS NULL AND expiration_date < CURRENT_DATE THEN 1
            ELSE 0
        END) AS expired_open_permits,
    SUM(estimated_cost) AS estimated_cost_total
FROM city_ops.fact_permits
GROUP BY ward_id, community_area_id
ORDER BY open_permits DESC, avg_cycle_time_days DESC;
