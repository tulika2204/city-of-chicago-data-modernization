import pandas as pd

from src.reconciliation.compare_row_counts import compare_row_counts


def test_compare_row_counts_shape(monkeypatch) -> None:
    source = pd.DataFrame({"table_name": ["permits"], "record_count": [10]})
    target = pd.DataFrame({"table_name": ["permits"], "record_count": [10]})

    calls = {"count": 0}

    def fake_fetch_dataframe(*args, **kwargs):
        calls["count"] += 1
        return source if calls["count"] == 1 else target

    monkeypatch.setattr("src.reconciliation.compare_row_counts.fetch_dataframe", fake_fetch_dataframe)
    result = compare_row_counts()
    assert result.loc[0, "status"] == "PASS"
