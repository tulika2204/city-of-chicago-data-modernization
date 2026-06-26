from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="chicago_permits_modernization",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["city-of-chicago", "migration", "permits"],
) as dag:
    extract_permits = BashOperator(
        task_id="extract_permits",
        bash_command="python -m src.jobs.permits_pipeline",
    )

    load_staging = BashOperator(
        task_id="load_staging",
        bash_command="echo 'Loading standardized permit data to staging layer'",
    )

    apply_scd2_property = BashOperator(
        task_id="apply_scd2_property",
        bash_command="echo 'Applying SCD Type 2 logic for dim_property'",
    )

    merge_fact_permits = BashOperator(
        task_id="merge_fact_permits",
        bash_command="echo 'Merging permit facts into curated warehouse'",
    )

    reconcile_permits = BashOperator(
        task_id="reconcile_permits",
        bash_command="python -m src.reconciliation.compare_row_counts && python -m src.reconciliation.compare_hash_totals",
    )

    publish_operational_risk = BashOperator(
        task_id="publish_operational_risk",
        bash_command="echo 'Publishing operational risk mart'",
    )

    extract_permits >> load_staging >> apply_scd2_property >> merge_fact_permits >> reconcile_permits >> publish_operational_risk
