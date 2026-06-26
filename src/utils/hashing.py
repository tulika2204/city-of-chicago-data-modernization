from __future__ import annotations

import hashlib
from typing import Iterable


def stable_row_hash(values: Iterable[object]) -> str:
    payload = "|".join("" if value is None else str(value).strip() for value in values)
    return hashlib.md5(payload.encode("utf-8")).hexdigest()
