from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    source_sqlserver_url: str = os.getenv("SOURCE_SQLSERVER_URL", "")
    source_oracle_url: str = os.getenv("SOURCE_ORACLE_URL", "")
    target_postgres_url: str = os.getenv("TARGET_POSTGRES_URL", "")
    environment: str = os.getenv("ENVIRONMENT", "dev")
    reconciliation_output_dir: str = os.getenv("RECONCILIATION_OUTPUT_DIR", "artifacts")


settings = Settings()
