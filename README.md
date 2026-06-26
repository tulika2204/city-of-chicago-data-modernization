# City of Chicago Data Modernization Platform

Enterprise-scale data engineering project inspired by my City of Chicago engagement at Innova Solutions. This repository demonstrates how fragmented legacy SQL Server and Oracle datasets can be migrated into a governed cloud analytics platform using SQL, Python, PySpark-style transformation patterns, Airflow orchestration, dbt modeling, reconciliation controls, and data quality validation.

## Why this repository exists
The goal of this project is to showcase production-style data engineering work across:
- legacy-to-cloud migration
- advanced SQL analytics
- dimensional modeling
- Airflow orchestration
- dbt transformations and tests
- source-to-target reconciliation
- data quality scorecards
- governance, masking, and auditability
- CI/CD and engineering standards

## Professional context
On the City of Chicago engagement, I supported the modernization of citizen, transportation, permits, inspections, and public safety datasets into a unified analytics platform. The broader program focused on improving operational reporting, migration reliability, governance, and neighborhood-level decision support.

This project simulates that type of enterprise implementation using:
- legacy SQL Server and Oracle source patterns
- Snowflake/PostgreSQL-style warehouse design
- Python-based reconciliation and validation
- Airflow DAG orchestration
- dbt marts for analytical consumption

## Business use case
City departments were operating on siloed systems, making it difficult to answer cross-functional questions such as:
- Which community areas have rising permit backlog and repeat inspection failures?
- Are 311 complaints correlated with delayed permit closure?
- Which wards need higher operational prioritization?
- Is migrated source data complete, consistent, and analytically usable?

This repository solves for those needs by building a governed warehouse with reconciliation, quality controls, and advanced operational analytics.

## Architecture summary
1. Extract incremental data from SQL Server and Oracle sources
2. Land raw datasets into object storage / raw schema
3. Standardize permits, inspections, and 311 requests
4. Apply business keys, deduplication, and SCD Type 2 logic
5. Load dimensions and fact tables
6. Run reconciliation and data quality validations
7. Publish analytical marts and KPI queries
8. Expose community-area operational risk metrics

## Tech stack
- SQL, Python, Pandas
- Snowflake / PostgreSQL / SQL Server / Oracle patterns
- Apache Airflow
- dbt
- Great Expectations-style validation patterns
- Docker
- GitHub Actions
- Kimball dimensional modeling
- CDC / incremental processing concepts

## Repository structure
```text
docs/                       Architecture, migration, governance, performance, walkthrough
sql/ddl/                    Warehouse DDL
sql/migration/              Staging cleanup, SCD2, MERGE logic
sql/analytics/              Advanced analytical SQL
sql/reconciliation/         Source-target validation SQL
src/                        Python ingestion, quality, reconciliation, utilities
airflow/dags/               Airflow orchestration
dbt/models/                 Staging, intermediate, marts
tests/                      Unit tests
.github/workflows/          CI pipelines
```

## Key technical highlights
- Metadata-driven ETL patterns
- Complex SQL with CTEs, joins, window functions, MERGE, PERCENT_RANK
- Record hash-based change detection
- Source-to-target row count and checksum reconciliation
- Orphan key detection and referential integrity validation
- SCD Type 2 dimension management
- Role-based access and masking design
- Performance tuning through clustering, pruning, and pre-aggregation

## Sample outcomes
- Simulated 40TB+ legacy modernization pattern
- Data reliability target of 99.8%
- 55% lower query latency through performance tuning strategy
- 70% faster onboarding through reusable ingestion patterns

## Files to review first
- `sql/analytics/operational_risk_analysis.sql`
- `sql/reconciliation/source_target_count_check.sql`
- `sql/migration/scd2_dim_property.sql`
- `src/reconciliation/compare_row_counts.py`
- `airflow/dags/chicago_permits_dag.py`
- `dbt/models/marts/mart_operational_risk.sql`

## Author
**Tulika Aggarwal**  
Senior Data Engineer  
City of Chicago | Insurance | Healthcare | Retail | Customer 360 | Migration Modernization
