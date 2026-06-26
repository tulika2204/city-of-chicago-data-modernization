from __future__ import annotations

import re
import pandas as pd


STREET_REPLACEMENTS = {
    r"\bSTREET\b": "ST",
    r"\bAVENUE\b": "AVE",
    r"\bROAD\b": "RD",
    r"\bDRIVE\b": "DR",
    r"\bBOULEVARD\b": "BLVD",
}


def normalize_text(value: object) -> str:
    text = "" if value is None else str(value).strip().upper()
    text = re.sub(r"\s+", " ", text)
    for pattern, replacement in STREET_REPLACEMENTS.items():
        text = re.sub(pattern, replacement, text)
    return text


def normalize_zip(value: object) -> str:
    digits = re.sub(r"[^0-9]", "", "" if value is None else str(value))
    return digits[:5].zfill(5) if digits else ""


def standardize_addresses(df: pd.DataFrame) -> pd.DataFrame:
    result = df.copy()
    result["address_line_1"] = result["address_line_1"].apply(normalize_text)
    result["city"] = result["city"].apply(normalize_text)
    result["state"] = result["state"].apply(normalize_text)
    result["zip_code"] = result["zip_code"].apply(normalize_zip)
    return result
