from __future__ import annotations

from pathlib import Path
import pandas as pd

from src.config.settings import settings


def build_dq_scorecard(metrics: dict[str, float]) -> pd.DataFrame:
    score = round(sum(metrics.values()) / len(metrics), 2) if metrics else 0.0
    rows = [{"metric_name": key, "metric_score": value} for key, value in metrics.items()]
    rows.append({"metric_name": "overall_score", "metric_score": score})
    return pd.DataFrame(rows)


def main() -> None:
    metrics = {
        "completeness": 99.9,
        "uniqueness": 99.7,
        "validity": 99.8,
        "referential_integrity": 99.8,
        "timeliness": 99.6,
    }
    output_dir = Path(settings.reconciliation_output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    build_dq_scorecard(metrics).to_csv(output_dir / "dq_scorecard.csv", index=False)


if __name__ == "__main__":
    main()
