SELECT
    inspection_id,
    permit_id,
    inspection_date,
    CASE
        WHEN UPPER(TRIM(inspection_result)) IN ('PASS', 'PASSED') THEN 'PASS'
        WHEN UPPER(TRIM(inspection_result)) IN ('FAIL', 'FAILED') THEN 'FAIL'
        ELSE 'UNKNOWN'
    END AS inspection_result,
    inspector_id,
    source_system,
    source_updated_at
FROM city_ops_stg.stg_inspections;
