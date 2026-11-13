#!/usr/bin/env bash
# Structured Finance Interviews from Zero: run every SQL Server script of Chapter 17
# on a real SQL Server in Docker, check the numbers the book quotes, and write a report.
# Usage (macOS, Linux or GitHub Actions), from the repository root:  bash tests/run_all.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/tests/output"
C=ashcombe-test
PW="${SA_PASSWORD:-Ashcombe#Test2026}"
IMAGE="${IMAGE:-mcr.microsoft.com/mssql/server:2025-latest}"
IMPORT=/tmp
rm -rf "$OUT"; mkdir -p "$OUT/logs" "$OUT/work"

echo "Starting $IMAGE ..."
docker rm -f $C >/dev/null 2>&1
docker run -d --platform linux/amd64 --name $C -e ACCEPT_EULA=Y -e "MSSQL_SA_PASSWORD=$PW" \
  -p 14334:1433 "$IMAGE" >/dev/null || { echo "docker run failed"; exit 2; }
TOOLS=""
for i in $(seq 1 90); do
  for t in /opt/mssql-tools18/bin /opt/mssql-tools/bin; do
    if docker exec $C test -x $t/sqlcmd 2>/dev/null; then TOOLS=$t; fi
  done
  if [ -n "$TOOLS" ] && docker exec $C $TOOLS/sqlcmd -S localhost -U sa -P "$PW" -C -Q "SELECT 1" >/dev/null 2>&1; then break; fi
  sleep 2
done
[ -n "$TOOLS" ] || { echo "sqlcmd not found in the image"; exit 2; }
docker exec $C $TOOLS/sqlcmd -S localhost -U sa -P "$PW" -C -h -1 -Q "SET NOCOUNT ON; SELECT @@VERSION" | head -1 | tee "$OUT/version.txt"

docker cp "$ROOT/data/." $C:$IMPORT/

sql() {  # sql <file> <log>
  docker cp "$1" $C:/tmp/run.sql
  docker exec $C $TOOLS/sqlcmd -S localhost -U sa -P "$PW" -C -I -W -s"|" -d master -i /tmp/run.sql >"$2" 2>&1
}
adapt() {  # the book's Windows paths -> the container's import folder
  sed -e "s#C:\\\\temp\\\\#$IMPORT/#g" "$1" > "$2"
}
setup() {
  adapt "$ROOT/sql/00_setup.sql" "$OUT/work/00_setup.sql"
  sql "$OUT/work/00_setup.sql" "$OUT/logs/00_setup.log"
}

REPORT="$OUT/REPORT.md"
{ echo "# Structured Finance Interviews from Zero: SQL Server test run"; echo
  echo "Server: $(cat "$OUT/version.txt")"; echo; echo "Date: $(date -u '+%Y-%m-%d %H:%M UTC')"; echo
  echo "| Script | Unexpected errors | Expected errors | First unexpected error |"; echo "|---|---:|---:|---|"; } > "$REPORT"
TOTAL=0
run_one() {  # run_one <script path> <chapter key>
  local f="$1" key="$2" name allowed errs exp n first
  name=$(basename "$f" .sql)
  adapt "$f" "$OUT/work/$name.sql"
  echo "Running $name ..."
  sql "$OUT/work/$name.sql" "$OUT/logs/$name.log"
  allowed=$(grep -E "^$key " "$ROOT/tests/expected_messages.txt" 2>/dev/null | cut -d' ' -f2- | tr ' ' '|')
  errs=$(grep -E "^Msg [0-9]+, Level (1[1-9]|2[0-5])|Sqlcmd: Error" "$OUT/logs/$name.log" || true)
  exp=0
  if [ -n "$allowed" ]; then
    exp=$(printf '%s\n' "$errs" | grep -cE "^Msg ($allowed)," || true)
    errs=$(printf '%s\n' "$errs" | grep -vE "^Msg ($allowed)," || true)
  fi
  n=$(printf '%s' "$errs" | grep -c "^Msg\|^Sqlcmd" || true)
  need=$(grep -E "^$key " "$ROOT/tests/expected_messages.txt" 2>/dev/null | awk '{print NF-1}')
  if [ -n "$need" ] && [ "$exp" -ne "$need" ]; then
    n=$((n+1)); errs="expected $need planned errors (Msg ${allowed//|/, }), got $exp"
  fi
  if [ -f "$ROOT/tests/after_$name.sql" ]; then
    sql "$ROOT/tests/after_$name.sql" "$OUT/logs/after_$name.log"
    if ! grep -q "ALL CHECKS PASSED" "$OUT/logs/after_$name.log"; then
      n=$((n+1)); errs="after_$name.sql: checks failed"
    fi
  fi
  first=""
  if [ "$n" -gt 0 ]; then first=$(printf '%s\n' "$errs" | head -1 | cut -c1-120); fi
  TOTAL=$((TOTAL + n))
  echo "| $name | $n | $exp | ${first//|//} |" >> "$REPORT"
}
echo "Building the database ..."
setup
run_one "$OUT/work/00_setup.sql" "00"
for f in "$ROOT"/sql/ch17_*.sql; do
  key=$(basename "$f" | cut -c6-7)
  setup                                  # as a reader does: a fresh database for each script
  run_one "$f" "$key"
done
setup
run_one "$ROOT/tests/checks.sql" "checks"
grep -q "ALL CHECKS PASSED" "$OUT/logs/checks.log" || { echo "| checks | numbers differ from the book | | see logs/checks.log |" >> "$REPORT"; TOTAL=$((TOTAL+1)); }
{ echo; echo "**Unexpected errors in total: $TOTAL**"; echo
  echo "## Error details"; echo
  for lg in "$OUT"/logs/*.log; do
    if grep -qE "^Msg [0-9]+, Level (1[1-9]|2[0-5])|Sqlcmd: Error" "$lg"; then
      echo "### $(basename "$lg" .log)"; echo '```'
      grep -E -A4 "^Msg [0-9]+, Level (1[1-9]|2[0-5])|Sqlcmd: Error" "$lg" | head -30
      echo '```'; echo
    fi
  done; } >> "$REPORT"
cat "$REPORT"
if [ "${FULL_LOGS:-0}" = "1" ]; then
  for lg in "$OUT"/logs/*.log; do echo "===== LOG $(basename "$lg" .log)"; cat "$lg"; done
fi
[ "${KEEP:-0}" = "1" ] || docker rm -f $C >/dev/null
[ "$TOTAL" -eq 0 ]
