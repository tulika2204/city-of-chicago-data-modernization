from __future__ import annotations

from pathlib import Path
import pandas as pd

from src.config.settings import settings


def generate_report() -> pd.DataFrame:
    output_dir = Path(settings.reconciliation_output_dir)
    frames = []
    for name in [
        "row_count_reconciliation.csv",
        "checksum_reconciliation.csv",
        "foreign_key_validation.csv",
    ]:
        path = output_dir / name
        if path.exists():
            df = pd.read_csv(path)
            df.insert(0, "report_source", name)
            frames.append(df)
    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


def main() -> None:
    report_df = generate_report()
    if not report_df.empty:
        report_df.to_csv(Path(settings.reconciliation_output_dir) / "reconciliation_report.csv", index=False)


if __name__ == "__main__":
    main()
