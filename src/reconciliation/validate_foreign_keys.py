from __future__ import annotations

from pathlib import Path
import pandas as pd

from src.config.settings import settings
from src.utils.db import fetch_dataframe


VALIDATION_QUERY = '''
SELECT
    'fact_permits_without_dim_property' AS validation_name,
    COUNT(*) AS orphan_count
FROM city_ops.fact_permits f
LEFT JOIN city_ops.dim_property d
    ON f.property_sk = d.property_sk
WHERE d.property_sk IS NULL
UNION ALL
SELECT
    'fact_inspections_without_permit',
    COUNT(*)
FROM city_ops.fact_inspections i
LEFT JOIN city_ops.fact_permits p
    ON i.permit_id = p.permit_id
WHERE p.permit_id IS NULL
'''


def validate_foreign_keys() -> pd.DataFrame:
    df = fetch_dataframe(settings.target_postgres_url, VALIDATION_QUERY)
    df["status"] = df["orphan_count"].apply(lambda count: "PASS" if count == 0 else "FAIL")
    return df


def main() -> None:
    output_dir = Path(settings.reconciliation_output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    validate_foreign_keys().to_csv(output_dir / "foreign_key_validation.csv", index=False)


if __name__ == "__main__":
    main()
