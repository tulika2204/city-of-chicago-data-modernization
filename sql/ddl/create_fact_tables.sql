CREATE TABLE IF NOT EXISTS city_ops.fact_permits (
    permit_id             VARCHAR(100) PRIMARY KEY,
    property_sk           BIGINT,
    permit_type           VARCHAR(100),
    permit_status         VARCHAR(50),
    issue_date            DATE,
    expiration_date       DATE,
    closed_date           DATE,
    estimated_cost        NUMERIC(18, 2),
    ward_id               INTEGER,
    community_area_id     INTEGER,
    record_hash           VARCHAR(64),
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS city_ops.fact_inspections (
    inspection_id         VARCHAR(100) PRIMARY KEY,
    permit_id             VARCHAR(100),
    inspection_date       DATE,
    inspection_result     VARCHAR(50),
    inspector_id          VARCHAR(100),
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
