from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime


@dataclass
class AuditRecord:
    pipeline_name: str
    source_table: str
    target_table: str
    load_start_ts: datetime
    load_end_ts: datetime
    status: str
    records_read: int
    records_written: int
    records_rejected: int
    message: str
