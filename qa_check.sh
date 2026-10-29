#!/usr/bin/env bash
# Local QA check: runs the same gates as the OpsPulse CI and prints one summary table.
#
# Usage:
#   ./qa_check.sh /path/to/OpsPulse-AI-Autonomous-Incident-Response-RCA-Agent [--apply-patch]
#
# Needs Python 3.11+ and network access for pip. It creates a throwaway virtualenv in .qa-venv
# next to this script and never modifies the target repo unless --apply-patch is given.

TARGET="${1:-}"
APPLY_PATCH="${2:-}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$HERE/.qa-venv"

if [[ -z "$TARGET" || ! -f "$TARGET/pyproject.toml" ]]; then
  echo "Usage: $0 /path/to/target-repo [--apply-patch]" >&2
  exit 2
fi
cd "$TARGET" || exit 2

if [[ "$APPLY_PATCH" == "--apply-patch" ]]; then
  echo "== applying patch =="
  git apply --verbose "$HERE/patches/fix-tests-and-coverage.patch" || { echo "patch did not apply" >&2; exit 2; }
fi

PY="${PYTHON:-python3}"
[[ -d "$VENV" ]] || "$PY" -m venv "$VENV" || exit 2
"$VENV/bin/pip" install -q -r requirements-dev.txt || { echo "dependency install failed" >&2; exit 2; }

declare -a NAMES RESULTS
run() {
  local name="$1"; shift
  echo; echo "== $name =="
  "$@"
  local code=$?
  NAMES+=("$name")
  if [[ $code -eq 0 ]]; then RESULTS+=("PASS"); else RESULTS+=("FAIL"); fi
}

run "ruff check"  "$VENV/bin/ruff" check src tests evals scripts migrations
run "ruff format" "$VENV/bin/ruff" format --check src tests evals scripts migrations
run "mypy"        "$VENV/bin/mypy"
run "pytest+cov"  "$VENV/bin/pytest" -q --cov=src --cov=evals --cov-report=term-missing:skip-covered --cov-fail-under=84

echo; echo "================ SUMMARY ================"
status=0
for i in "${!NAMES[@]}"; do
  printf '%-14s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}"
  [[ "${RESULTS[$i]}" == "FAIL" ]] && status=1
done
exit $status
