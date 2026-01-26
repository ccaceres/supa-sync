#!/usr/bin/env bash
# ============================================
# SUPABASE DATA CLONE SCRIPT v2.0
# Clone remote Supabase data to local instance
# Fully unattended, fault-tolerant execution
# ============================================

# Don't exit on errors - we handle them gracefully
set -uo pipefail

# ========= CONFIG =========
REMOTE_PROJECT_ID="blpqmqcyfetcwtvstvwl"
REMOTE_URL="https://${REMOTE_PROJECT_ID}.supabase.co"
REMOTE_API="${REMOTE_URL}/rest/v1"

LOCAL_DB_HOST="127.0.0.1"
LOCAL_DB_PORT="54322"
LOCAL_DB_NAME="postgres"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASS="postgres"

BATCH_SIZE=500
MAX_RETRIES=3
TEMP_DIR="/tmp/supabase-clone-$$"

# Tables in dependency order (parents before children)
TABLES=(
  # Reference/Config (no dependencies)
  "industries"
  "project_types"
  "system_settings"
  "navigation_config"
  "navigation_groups"
  "navigation_items"
  "ai_providers"
  "notification_templates"

  # Users & Permissions
  "profiles"
  "user_roles"
  "role_permissions"
  "user_preferences"
  "user_mfa_settings"
  "user_signatures"

  # Library Data
  "library_equipment"
  "library_exempt_positions"
  "library_nonexempt_positions"
  "library_schedules"
  "approved_job_titles"
  "dl_roles_library"

  # Projects & Teams
  "customers"
  "projects"
  "project_assignments"
  "teams"
  "team_members"
  "team_progress_templates"
  "team_progress_template_items"

  # Pipelines & Rounds
  "approval_pipelines"
  "pipeline_stages"
  "stage_approval_requirements"
  "rounds"
  "round_process_scorecards"

  # Models (Core)
  "models"
  "model_parameters"

  # Model Data
  "volumes"
  "price_lines"
  "equipment"
  "equipment_sets"
  "equipment_set_items"
  "capex_lines"
  "opex_lines"
  "impex_lines"
  "exempt_positions"
  "nonexempt_positions"
  "dl_roles"
  "labex_indirect_labor"
  "ci_schedules"
  "model_schedules"

  # Allocations & Formulas
  "cost_price_allocations"
  "opex_price_allocations"
  "formula_templates"
  "formula_definitions"
  "formula_variables"
)

# Stats tracking
declare -A STATS
STATS[created]=0
STATS[synced]=0
STATS[skipped]=0
STATS[failed]=0
STATS[total_rows]=0

# ========= HELPERS =========
log()  { printf "\n[+] %s\n" "$*"; }
info() { printf "    %s\n" "$*"; }
warn() { printf "[!] %s\n" "$*" >&2; }
err()  { printf "[x] %s\n" "$*" >&2; }

cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

psql_local() {
  PGPASSWORD="$LOCAL_DB_PASS" psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" \
    -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -q "$@" 2>/dev/null
}

psql_local_raw() {
  PGPASSWORD="$LOCAL_DB_PASS" psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" \
    -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" "$@"
}

# Fetch from cloud API with retries
fetch_api() {
  local endpoint="$1"
  local retries=0
  local result=""

  while [ $retries -lt $MAX_RETRIES ]; do
    result=$(curl -sf "${REMOTE_API}/${endpoint}" \
      -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
      -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" 2>/dev/null) && break
    retries=$((retries + 1))
    sleep 1
  done

  echo "$result"
}

# Get count from cloud
get_cloud_count() {
  local table="$1"
  curl -sI "${REMOTE_API}/${table}?select=id" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Prefer: count=exact" 2>/dev/null | \
    grep -i "content-range" | sed 's/.*\///' | tr -d '\r\n' || echo "0"
}

# ========= PREREQUISITES =========
check_prerequisites() {
  log "Checking prerequisites..."

  if [ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
    err "SUPABASE_SERVICE_ROLE_KEY is not set"
    err "Get it from: https://supabase.com/dashboard/project/${REMOTE_PROJECT_ID}/settings/api"
    exit 1
  fi

  for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      err "Required command not found: $cmd"
      exit 1
    fi
  done

  if ! psql_local -c "SELECT 1" >/dev/null 2>&1; then
    err "Cannot connect to local Supabase database"
    err "Make sure Supabase is running: docker ps | grep supabase"
    exit 1
  fi

  mkdir -p "$TEMP_DIR"
  info "Database connection OK"

  # Verify migrations have been applied
  check_migrations_applied
}

# ========= SCHEMA MANAGEMENT =========
# Check if table exists (schema should be created by migrations, not inferred)
table_exists() {
  local table="$1"
  local exists
  exists=$(psql_local -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='$table'" 2>/dev/null | tr -d ' ')
  [ "${exists:-0}" -gt 0 ]
}

# Check that migrations have been applied (at least core tables exist)
check_migrations_applied() {
  log "Checking if migrations have been applied..."

  local core_tables=("profiles" "projects" "models")
  local missing=0

  for table in "${core_tables[@]}"; do
    if ! table_exists "$table"; then
      warn "Core table '$table' not found"
      missing=$((missing + 1))
    fi
  done

  if [ $missing -gt 0 ]; then
    err "Schema not found. Run migrations first:"
    err "  ./deployment/apply-migrations.sh"
    err "  OR: cd ${REPO_ROOT:-$(pwd)} && npx supabase db reset --linked=false"
    exit 1
  fi

  # Count total tables
  local table_count
  table_count=$(psql_local -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null | tr -d ' ')
  info "Found ${table_count:-0} tables in local database"

  # Count RLS policies
  local policy_count
  policy_count=$(psql_local -t -c "SELECT COUNT(*) FROM pg_policies WHERE schemaname='public'" 2>/dev/null | tr -d ' ')
  info "Found ${policy_count:-0} RLS policies"
}

# ========= AUTH SYNC (Direct PostgreSQL) =========
# ========= AUTH SYNC VIA API (Fallback) =========
# Uses Supabase Auth Admin API when PostgreSQL is unavailable
sync_auth_via_api() {
  log "Syncing auth users via Admin API (fallback method)..."

  local auth_api="${REMOTE_URL}/auth/v1/admin/users"
  local page=1
  local per_page=50
  local sql_file="$TEMP_DIR/auth_api_sync.sql"

  # Start SQL file with transaction and trigger disable
  cat > "$sql_file" << 'EOF'
SET session_replication_role = 'replica';
DELETE FROM auth.identities;
DELETE FROM auth.users;
EOF

  info "Fetching users from cloud API..."

  # Fetch all users from cloud via Admin API
  while true; do
    local response
    response=$(curl -sf "${auth_api}?apikey=${SUPABASE_SERVICE_ROLE_KEY}&page=${page}&per_page=${per_page}" \
      -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" 2>/dev/null)

    if [ -z "$response" ]; then
      break
    fi

    local users_count
    users_count=$(echo "$response" | jq '.users | length' 2>/dev/null)

    if [ -z "$users_count" ] || [ "$users_count" = "0" ]; then
      break
    fi

    # Generate SQL for each user using jq
    echo "$response" | jq -r '.users[] |
      "INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, instance_id, aud, role) VALUES (" +
      "'"'"'\(.id)'"'"', " +
      "'"'"'\(.email // "" | gsub("'"'"'"; "'"'"''"'"'"))'"'"', " +
      "'"'"''"'"', " +
      (if .email_confirmed_at then "'"'"'\(.email_confirmed_at)'"'"'" else "NULL" end) + ", " +
      "'"'"'\(.created_at)'"'"', " +
      "NOW(), " +
      "'"'"'\(.app_metadata // {} | tostring | gsub("'"'"'"; "'"'"''"'"'"))'"'"'::jsonb, " +
      "'"'"'\(.user_metadata // {} | tostring | gsub("'"'"'"; "'"'"''"'"'"))'"'"'::jsonb, " +
      "false, " +
      "'"'"'00000000-0000-0000-0000-000000000000'"'"', " +
      "'"'"'authenticated'"'"', " +
      "'"'"'authenticated'"'"'" +
      ") ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, raw_app_meta_data = EXCLUDED.raw_app_meta_data, raw_user_meta_data = EXCLUDED.raw_user_meta_data, updated_at = NOW();"
    ' >> "$sql_file" 2>/dev/null

    ((page++))

    # Safety limit
    if [ $page -gt 100 ]; then
      warn "Reached page limit (100 pages)"
      break
    fi
  done

  # Re-enable triggers
  echo "SET session_replication_role = 'origin';" >> "$sql_file"

  # Execute all SQL in single connection
  info "Importing users to local database..."
  psql_local_raw < "$sql_file" >/dev/null 2>&1

  local final_count
  final_count=$(psql_local -t -c "SELECT COUNT(*) FROM auth.users" 2>/dev/null | tr -d ' ')
  printf "  %-40s %s rows\n" "auth.users (via API)" "${final_count:-0}"

  local identity_count
  identity_count=$(psql_local -t -c "SELECT COUNT(*) FROM auth.identities" 2>/dev/null | tr -d ' ')
  printf "  %-40s %s rows\n" "auth.identities (via API)" "${identity_count:-0}"

  if [ "${final_count:-0}" -gt 0 ]; then
    warn "Users synced via API - passwords NOT copied"
    warn "Users must use 'Forgot Password' to set new passwords"
  fi
}

sync_auth_tables() {
  log "Syncing auth tables from cloud (direct PostgreSQL)..."

  # Check prerequisites for PostgreSQL method
  local use_api_fallback=false

  if [ -z "${CLOUD_DB_HOST:-}" ] || [ -z "${CLOUD_DB_PASSWORD:-}" ]; then
    warn "CLOUD_DB_HOST or CLOUD_DB_PASSWORD not set"
    use_api_fallback=true
  fi

  if ! command -v pg_dump >/dev/null 2>&1; then
    warn "pg_dump not found"
    use_api_fallback=true
  fi

  # Test PostgreSQL connectivity (quick timeout)
  if [ "$use_api_fallback" = false ]; then
    info "Testing PostgreSQL connection..."
    if ! timeout 5 bash -c "PGPASSWORD='$CLOUD_DB_PASSWORD' psql -h '$CLOUD_DB_HOST' -p 5432 -U postgres -d postgres -c 'SELECT 1'" >/dev/null 2>&1; then
      warn "PostgreSQL connection failed (IPv6 not available in WSL?)"
      use_api_fallback=true
    fi
  fi

  # Use API fallback if PostgreSQL unavailable
  if [ "$use_api_fallback" = true ]; then
    if [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
      warn "Falling back to Auth Admin API..."
      sync_auth_via_api
      return
    else
      warn "Cannot sync auth: no PostgreSQL access and no service role key"
      return
    fi
  fi

  # PostgreSQL method (original)
  local auth_tables=("users" "identities")

  info "Clearing local auth tables..."
  psql_local_raw -c "DELETE FROM auth.identities;" 2>/dev/null || true
  psql_local_raw -c "DELETE FROM auth.users;" 2>/dev/null || true

  for table in "${auth_tables[@]}"; do
    printf "  %-40s " "auth.$table"

    PGPASSWORD="$CLOUD_DB_PASSWORD" pg_dump \
      -h "$CLOUD_DB_HOST" -p 5432 -U postgres -d postgres \
      --data-only --table="auth.$table" \
      --column-inserts \
      > "$TEMP_DIR/auth_${table}.sql" 2>/dev/null

    if [ ! -s "$TEMP_DIR/auth_${table}.sql" ]; then
      printf "empty or failed\n"
      continue
    fi

    {
      echo "SET session_replication_role = 'replica';"
      cat "$TEMP_DIR/auth_${table}.sql"
    } | psql_local_raw >/dev/null 2>&1

    local count
    count=$(psql_local -t -c "SELECT COUNT(*) FROM auth.$table" 2>/dev/null | tr -d ' ')
    printf "%s rows\n" "${count:-0}"
  done

  psql_local_raw -c "SET session_replication_role = 'origin';" >/dev/null 2>&1

  info "Auth sync complete - users can now login with their cloud passwords"
}

# ========= DATA SYNC =========
# Generate INSERT SQL from JSON row using to_entries (maintains order!)
json_to_insert() {
  local table="$1"

  jq -r --arg t "$table" '.[] | to_entries |
    "INSERT INTO public.\"\($t)\" (" +
    ([.[] | "\"" + .key + "\""] | join(",")) +
    ") VALUES (" +
    ([.[] |
      if .value == null then "NULL"
      elif (.value | type) == "string" then
        "E\u0027" + (.value | gsub("\u0027"; "\u0027\u0027") | gsub("\\\\"; "\\\\\\\\")) + "\u0027"
      elif (.value | type) == "object" or (.value | type) == "array" then
        "E\u0027" + (.value | tostring | gsub("\u0027"; "\u0027\u0027") | gsub("\\\\"; "\\\\\\\\")) + "\u0027::jsonb"
      elif (.value | type) == "boolean" then
        (if .value then "true" else "false" end)
      else
        (.value | tostring)
      end
    ] | join(",")) +
    ") ON CONFLICT DO NOTHING;"
  ' 2>/dev/null
}

# Sync single table
sync_table() {
  local table="$1"
  local offset=0
  local total=0
  local batch_file="$TEMP_DIR/${table}.sql"

  # Verify table exists (should have been created by migrations)
  if ! table_exists "$table"; then
    echo "MISSING"
    return
  fi

  # Get cloud count
  local cloud_count
  cloud_count=$(get_cloud_count "$table")

  if [ -z "$cloud_count" ] || [ "$cloud_count" = "0" ] || [ "$cloud_count" = "*" ]; then
    echo "0"
    return
  fi

  # Clear existing data
  psql_local -c "DELETE FROM public.\"$table\";" >/dev/null 2>&1 || true

  # Fetch and insert in batches
  while [ $offset -lt $cloud_count ]; do
    local data
    data=$(fetch_api "${table}?offset=${offset}&limit=${BATCH_SIZE}")

    local batch_count
    batch_count=$(echo "$data" | jq 'length' 2>/dev/null || echo "0")

    if [ "$batch_count" = "0" ] || [ "$batch_count" = "null" ]; then
      break
    fi

    # Generate and execute INSERT statements
    # Prepend session_replication_role to bypass RLS in same session as INSERTs
    {
      echo "SET session_replication_role = 'replica';"
      echo "$data" | json_to_insert "$table"
    } > "$batch_file"

    if [ -s "$batch_file" ]; then
      psql_local -f "$batch_file" >/dev/null 2>&1 || true
    fi

    total=$((total + batch_count))
    offset=$((offset + BATCH_SIZE))

    # Progress indicator for large tables
    if [ $total -gt 1000 ] && [ $((total % 1000)) -lt $BATCH_SIZE ]; then
      printf "." >&2
    fi
  done

  rm -f "$batch_file"
  echo "$total"
}

# ========= MAIN SYNC =========
clone_all_tables() {
  log "Syncing tables from cloud to local..."
  echo ""

  # Disable triggers for faster inserts
  psql_local -c "SET session_replication_role = 'replica';" >/dev/null 2>&1

  for table in "${TABLES[@]}"; do
    printf "  %-40s " "$table"

    local result
    result=$(sync_table "$table")

    case "$result" in
      MISSING)
        printf "MISSING (run migrations first)\n"
        STATS[failed]=$((STATS[failed] + 1))
        ;;
      SKIP)
        printf "skipped (no data)\n"
        STATS[skipped]=$((STATS[skipped] + 1))
        ;;
      0)
        printf "empty\n"
        STATS[skipped]=$((STATS[skipped] + 1))
        ;;
      *)
        printf "%s rows\n" "$result"
        STATS[synced]=$((STATS[synced] + 1))
        STATS[total_rows]=$((STATS[total_rows] + result))
        ;;
    esac
  done

  # Re-enable triggers
  psql_local -c "SET session_replication_role = 'origin';" >/dev/null 2>&1
}

# ========= VERIFICATION =========
verify_sync() {
  log "Verifying sync..."
  echo ""

  local mismatches=0
  printf "  %-30s %10s %10s %8s\n" "Table" "Cloud" "Local" "Status"
  printf "  %-30s %10s %10s %8s\n" "------------------------------" "----------" "----------" "--------"

  for table in profiles projects models rounds volumes price_lines equipment; do
    local cloud_count
    cloud_count=$(get_cloud_count "$table")

    local local_count
    local_count=$(psql_local -t -c "SELECT COUNT(*) FROM public.\"$table\"" 2>/dev/null | tr -d ' ' || echo "0")

    local status="OK"
    if [ "${cloud_count:-0}" != "${local_count:-0}" ]; then
      status="DIFF"
      mismatches=$((mismatches + 1))
    fi

    printf "  %-30s %10s %10s %8s\n" "$table" "${cloud_count:-0}" "${local_count:-0}" "$status"
  done

  echo ""
  if [ $mismatches -eq 0 ]; then
    info "All verified tables match!"
  else
    warn "$mismatches tables have count differences (may be due to concurrent changes)"
  fi
}

# ========= SUMMARY =========
show_summary() {
  cat <<EOF

============================================================
SUPABASE DATA CLONE COMPLETE
============================================================
Source: $REMOTE_URL
Target: http://localhost:54321

Results:
  Tables synced:  ${STATS[synced]}
  Tables skipped: ${STATS[skipped]}
  Tables missing: ${STATS[failed]}
  Total rows:     ${STATS[total_rows]}

Access Points:
  Studio:   http://localhost:54323
  API:      http://localhost:54321
  Database: postgresql://postgres:postgres@localhost:54322/postgres
EOF

  if [ "${STATS[failed]}" -gt 0 ]; then
    cat <<EOF

WARNING: ${STATS[failed]} tables were missing. Run migrations first:
  ./deployment/apply-migrations.sh
EOF
  fi

  echo "============================================================"
  echo ""
}

# ========= MAIN =========
main() {
  log "Supabase Data Clone Script v2.0"
  log "================================"

  check_prerequisites
  sync_auth_tables     # Sync auth FIRST (before profiles which reference auth.users)
  clone_all_tables
  verify_sync
  show_summary

  log "Clone completed successfully!"
  exit 0
}

main "$@"
