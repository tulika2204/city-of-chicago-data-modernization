from src.utils.hashing import stable_row_hash


def test_stable_row_hash_returns_same_value_for_same_input() -> None:
    left = stable_row_hash(["A", 1, "2026-01-01"])
    right = stable_row_hash(["A", 1, "2026-01-01"])
    assert left == right
