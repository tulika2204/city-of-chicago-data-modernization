CREATE SCHEMA IF NOT EXISTS city_ops_raw;
CREATE SCHEMA IF NOT EXISTS city_ops_stg;

CREATE TABLE IF NOT EXISTS city_ops_stg.stg_permits (
    permit_id             VARCHAR(100),
    property_id           VARCHAR(100),
    permit_type           VARCHAR(100),
    permit_status         VARCHAR(50),
    issue_date            DATE,
    expiration_date       DATE,
    closed_date           DATE,
    estimated_cost        NUMERIC(18, 2),
    ward_id               INTEGER,
    community_area_id     INTEGER,
    address_line_1        VARCHAR(255),
    city                  VARCHAR(100),
    state                 VARCHAR(50),
    zip_code              VARCHAR(20),
    source_system         VARCHAR(50),
    source_updated_at     TIMESTAMP,
    load_ts               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS city_ops_stg.stg_inspections (
    inspection_id         VARCHAR(100),
    permit_id             VARCHAR(100),
    inspection_date       DATE,
    inspection_result     VARCHAR(50),
    inspector_id          VARCHAR(100),
    source_system         VARCHAR(50),
    source_updated_at     TIMESTAMP,
    load_ts               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS city_ops_stg.stg_311_requests (
    service_request_id    VARCHAR(100),
    request_type          VARCHAR(255),
    request_status        VARCHAR(50),
    request_created_date  DATE,
    request_closed_date   DATE,
    ward_id               INTEGER,
    community_area_id     INTEGER,
    address_line_1        VARCHAR(255),
    city                  VARCHAR(100),
    state                 VARCHAR(50),
    zip_code              VARCHAR(20),
    source_system         VARCHAR(50),
    source_updated_at     TIMESTAMP,
    load_ts               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
