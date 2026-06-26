SELECT
    'stg_permits' AS table_name,
    SUM(CASE WHEN permit_id IS NULL THEN 1 ELSE 0 END) AS null_permit_id,
    SUM(CASE WHEN issue_date IS NULL THEN 1 ELSE 0 END) AS null_issue_date,
    SUM(CASE WHEN permit_status IS NULL THEN 1 ELSE 0 END) AS null_permit_status
FROM city_ops_stg.stg_permits

UNION ALL

SELECT
    'stg_inspections',
    SUM(CASE WHEN inspection_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN inspection_date IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN inspection_result IS NULL THEN 1 ELSE 0 END)
FROM city_ops_stg.stg_inspections;
