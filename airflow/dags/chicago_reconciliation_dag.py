from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="chicago_reconciliation_validation",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["city-of-chicago", "reconciliation", "data-quality"],
) as dag:
    row_count_validation = BashOperator(
        task_id="row_count_validation",
        bash_command="python -m src.reconciliation.compare_row_counts",
    )

    checksum_validation = BashOperator(
        task_id="checksum_validation",
        bash_command="python -m src.reconciliation.compare_hash_totals",
    )

    foreign_key_validation = BashOperator(
        task_id="foreign_key_validation",
        bash_command="python -m src.reconciliation.validate_foreign_keys",
    )

    dq_scorecard = BashOperator(
        task_id="dq_scorecard",
        bash_command="python -m src.quality.dq_scorecard",
    )

    build_report = BashOperator(
        task_id="build_reconciliation_report",
        bash_command="python -m src.reconciliation.generate_reconciliation_report",
    )

    row_count_validation >> checksum_validation >> foreign_key_validation >> dq_scorecard >> build_report
