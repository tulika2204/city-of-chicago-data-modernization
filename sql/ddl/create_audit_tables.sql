CREATE TABLE IF NOT EXISTS city_ops.audit_load_log (
    load_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pipeline_name         VARCHAR(255),
    source_table          VARCHAR(255),
    target_table          VARCHAR(255),
    load_start_ts         TIMESTAMP,
    load_end_ts           TIMESTAMP,
    status                VARCHAR(50),
    records_read          BIGINT,
    records_written       BIGINT,
    records_rejected      BIGINT,
    message               VARCHAR(2000)
);

CREATE TABLE IF NOT EXISTS city_ops.audit_reconciliation (
    recon_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recon_name            VARCHAR(255),
    table_name            VARCHAR(255),
    source_count          BIGINT,
    target_count          BIGINT,
    variance_count        BIGINT,
    variance_pct          NUMERIC(9, 4),
    status                VARCHAR(20),
    run_ts                TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
