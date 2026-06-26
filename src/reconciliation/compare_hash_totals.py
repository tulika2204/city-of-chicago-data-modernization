from __future__ import annotations

from pathlib import Path
import pandas as pd

from src.config.settings import settings
from src.utils.db import fetch_dataframe


SOURCE_QUERY = '''
SELECT
    permit_id,
    permit_status,
    issue_date
FROM city_ops_stg.stg_permits
ORDER BY permit_id
'''

TARGET_QUERY = '''
SELECT
    permit_id,
    permit_status,
    issue_date
FROM city_ops.fact_permits
ORDER BY permit_id
'''


def dataframe_checksum(df: pd.DataFrame) -> str:
    payload = "||".join(
        f"{row.permit_id}|{row.permit_status}|{row.issue_date}"
        for row in df.itertuples(index=False)
    )
    return __import__("hashlib").md5(payload.encode("utf-8")).hexdigest()


def compare_hash_totals() -> dict[str, str]:
    source_df = fetch_dataframe(settings.target_postgres_url, SOURCE_QUERY)
    target_df = fetch_dataframe(settings.target_postgres_url, TARGET_QUERY)
    source_checksum = dataframe_checksum(source_df)
    target_checksum = dataframe_checksum(target_df)
    return {
        "source_checksum": source_checksum,
        "target_checksum": target_checksum,
        "status": "PASS" if source_checksum == target_checksum else "FAIL",
    }


def main() -> None:
    output_dir = Path(settings.reconciliation_output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    result = compare_hash_totals()
    pd.DataFrame([result]).to_csv(output_dir / "checksum_reconciliation.csv", index=False)


if __name__ == "__main__":
    main()
