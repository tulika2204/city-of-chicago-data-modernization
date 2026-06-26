import pandas as pd

from src.quality.custom_validations import validate_issue_before_close


def test_validate_issue_before_close_flags_invalid_rows() -> None:
    df = pd.DataFrame(
        [
            {"issue_date": "2026-01-02", "closed_date": "2026-01-01"},
            {"issue_date": "2026-01-01", "closed_date": "2026-01-05"},
        ]
    )
    invalid = validate_issue_before_close(df)
    assert len(invalid) == 1
