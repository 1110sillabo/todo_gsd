# Phase 03 Plan 03 — SUMMARY

## What was built
GdUnit4 unit tests for `TaskEditDialog`'s static deadline helpers.

## Artifacts created
- `tests/unit/test_task_edit_dialog.gd` — 7 tests covering:
  - `test_parse_valid_deadline` — valid date string → positive int
  - `test_parse_empty_deadline` — empty string → 0
  - `test_parse_invalid_deadline` — non-date string → 0
  - `test_parse_zero_parts` — "0/0/0" → 0
  - `test_format_zero` — ts=0 → ""
  - `test_format_roundtrip` — parse then format "15/06/2026" → "15/06/2026"
  - `test_format_roundtrip_jan` — parse then format "01/01/2025" → "01/01/2025"

## Notes
- `parse_deadline` and `format_deadline` remain as `static func` on `task_edit_dialog.gd` even though the dialog now uses SpinBoxes internally — kept as tested utilities
- Tests use `preload` directly (no `class_name` dependency)
- GdUnit4 stub assertion style: `assert_int(v).is_equal(0)`, `assert_str(v).is_equal("")`
