WITH source_counts AS (
    SELECT 'permits' AS table_name, COUNT(*) AS source_count
    FROM city_ops_stg.stg_permits
    UNION ALL
    SELECT 'inspections', COUNT(*)
    FROM city_ops_stg.stg_inspections
    UNION ALL
    SELECT '311_requests', COUNT(*)
    FROM city_ops_stg.stg_311_requests
),
target_counts AS (
    SELECT 'permits' AS table_name, COUNT(*) AS target_count
    FROM city_ops.fact_permits
    UNION ALL
    SELECT 'inspections', COUNT(*)
    FROM city_ops.fact_inspections
    UNION ALL
    SELECT '311_requests', COUNT(*)
    FROM city_ops_stg.stg_311_requests
)
SELECT
    s.table_name,
    s.source_count,
    t.target_count,
    s.source_count - t.target_count AS variance_count,
    CASE
        WHEN s.source_count = 0 THEN 0
        ELSE ROUND(((s.source_count - t.target_count) * 100.0) / s.source_count, 4)
    END AS variance_pct,
    CASE
        WHEN s.source_count = t.target_count THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM source_counts s
JOIN target_counts t
    ON s.table_name = t.table_name
ORDER BY table_name;
