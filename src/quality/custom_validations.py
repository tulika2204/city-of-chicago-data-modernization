from __future__ import annotations

import pandas as pd


def validate_issue_before_close(df: pd.DataFrame) -> pd.DataFrame:
    invalid = df[
        df["closed_date"].notna() &
        (pd.to_datetime(df["closed_date"]) < pd.to_datetime(df["issue_date"]))
    ].copy()
    invalid["validation_name"] = "issue_date_before_closed_date"
    return invalid
