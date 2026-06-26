install:
	pip install -r requirements.txt

test:
	pytest tests -q

reconcile:
	python -m src.reconciliation.compare_row_counts
	python -m src.reconciliation.compare_hash_totals
	python -m src.reconciliation.validate_foreign_keys
	python -m src.reconciliation.generate_reconciliation_report
