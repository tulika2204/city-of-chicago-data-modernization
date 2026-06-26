from __future__ import annotations

from sqlalchemy import create_engine, text
import pandas as pd


def fetch_dataframe(connection_url: str, query: str) -> pd.DataFrame:
    engine = create_engine(connection_url)
    with engine.begin() as connection:
        return pd.read_sql(text(query), connection)


def execute_sql(connection_url: str, query: str) -> None:
    engine = create_engine(connection_url)
    with engine.begin() as connection:
        connection.execute(text(query))
