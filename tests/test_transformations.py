import pandas as pd

from src.transformations.standardize_addresses import standardize_addresses


def test_standardize_addresses_normalizes_address_fields() -> None:
    df = pd.DataFrame(
        [
            {
                "address_line_1": "123 Main Street ",
                "city": " chicago",
                "state": " il ",
                "zip_code": "6060-1",
            }
        ]
    )
    result = standardize_addresses(df)
    assert result.loc[0, "address_line_1"] == "123 MAIN ST"
    assert result.loc[0, "city"] == "CHICAGO"
    assert result.loc[0, "state"] == "IL"
    assert result.loc[0, "zip_code"] == "06060"
