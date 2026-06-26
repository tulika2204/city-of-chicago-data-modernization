from __future__ import annotations

from pathlib import Path
import pandas as pd

from src.config.settings import settings
from src.utils.db import fetch_dataframe


SOURCE_QUERY = '''
SELECT 'permits' AS table_name, COUNT(*) AS record_count FROM city_ops_stg.stg_permits
UNION ALL
SELECT 'inspections', COUNT(*) FROM city_ops_stg.stg_inspections
UNION ALL
SELECT '311_requests', COUNT(*) FROM city_ops_stg.stg_311_requests
'''

TARGET_QUERY = '''
SELECT 'permits' AS table_name, COUNT(*) AS record_count FROM city_ops.fact_permits
UNION ALL
SELECT 'inspections', COUNT(*) FROM city_ops.fact_inspections
UNION ALL
SELECT '311_requests', COUNT(*) FROM city_ops_stg.stg_311_requests
'''


def compare_row_counts() -> pd.DataFrame:
    source_df = fetch_dataframe(settings.target_postgres_url, SOURCE_QUERY).rename(
        columns={"record_count": "source_count"}
    )
    target_df = fetch_dataframe(settings.target_postgres_url, TARGET_QUERY).rename(
        columns={"record_count": "target_count"}
    )
    result = source_df.merge(target_df, on="table_name", how="inner")
    result["variance_count"] = result["source_count"] - result["target_count"]
    result["variance_pct"] = result.apply(
        lambda row: 0.0 if row["source_count"] == 0 else round((row["variance_count"] / row["source_count"]) * 100, 4),
        axis=1,
    )
    result["status"] = result.apply(
        lambda row: "PASS" if row["variance_count"] == 0 else "FAIL",
        axis=1,
    )
    return result.sort_values("table_name").reset_index(drop=True)


def main() -> None:
    output_dir = Path(settings.reconciliation_output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    result = compare_row_counts()
    result.to_csv(output_dir / "row_count_reconciliation.csv", index=False)


if __name__ == "__main__":
    main()
