MERGE INTO city_ops.fact_inspections AS target
USING (
    SELECT
        inspection_id,
        permit_id,
        inspection_date,
        inspection_result,
        inspector_id
    FROM city_ops_stg.stg_inspections
) AS source
ON target.inspection_id = source.inspection_id
WHEN MATCHED THEN
    UPDATE SET
        permit_id = source.permit_id,
        inspection_date = source.inspection_date,
        inspection_result = source.inspection_result,
        inspector_id = source.inspector_id,
        updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (
        inspection_id,
        permit_id,
        inspection_date,
        inspection_result,
        inspector_id
    )
    VALUES (
        source.inspection_id,
        source.permit_id,
        source.inspection_date,
        source.inspection_result,
        source.inspector_id
    );
