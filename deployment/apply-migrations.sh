#!/usr/bin/env bash
# ============================================
# SUPABASE MIGRATION SCRIPT
# Apply all database migrations from supabase/migrations/
# Creates tables, RLS policies, triggers, functions, and indexes
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ========= HELPERS =========
log()  { printf "\n[+] %s\n" "$*"; }
info() { printf "    %s\n" "$*"; }
warn() { printf "[!] %s\n" "$*" >&2; }
die()  { printf "[x] %s\n" "$*" >&2; exit 1; }

psql_local() {
  PGPASSWORD="${LOCAL_DB_PASS:-postgres}" psql \
    -h "${LOCAL_DB_HOST:-127.0.0.1}" \
    -p "${LOCAL_DB_PORT:-54322}" \
    -U "${LOCAL_DB_USER:-postgres}" \
    -d "${LOCAL_DB_NAME:-postgres}" \
    -q "$@" 2>/dev/null
}

# ========= CHECKS =========
# Check if Supabase containers are running via docker
supabase_containers_running() {
  docker ps --format '{{.Names}}' 2>/dev/null | grep -q 'supabase'
}

check_supabase_running() {
  log "Checking local Supabase is running..."

  cd "${REPO_ROOT}"

  # First check: Docker containers
  if ! supabase_containers_running; then
    # Fallback: try supabase status (may work if containers started differently)
    if ! npx --yes supabase status >/dev/null 2>&1; then
      die "Local Supabase not running. Run install-supabase-wsl.sh first."
    fi
  else
    info "Supabase containers detected via Docker"
  fi

  # Verify DB connection (most important check)
  if ! psql_local -c "SELECT 1" >/dev/null 2>&1; then
    die "Cannot connect to local database on port ${LOCAL_DB_PORT:-54322}"
  fi

  info "Supabase is running and database is accessible"
}

check_migrations_exist() {
  log "Checking for migrations..."

  if [ ! -d "${REPO_ROOT}/supabase/migrations" ]; then
    die "No supabase/migrations/ folder found in ${REPO_ROOT}"
  fi

  MIGRATION_COUNT=$(ls -1 "${REPO_ROOT}/supabase/migrations"/*.sql 2>/dev/null | wc -l)

  if [ "${MIGRATION_COUNT:-0}" -eq 0 ]; then
    die "No .sql files found in supabase/migrations/"
  fi

  info "Found ${MIGRATION_COUNT} migration files"
}

# ========= MIGRATION =========
apply_migrations() {
  log "Applying database migrations..."
  info "This will reset the database and apply all ${MIGRATION_COUNT} migrations"
  info "WARNING: This destroys existing local data!"
  echo ""

  cd "${REPO_ROOT}"

  # Run db reset which applies all migrations
  # --linked=false ensures we use the local database, not a linked remote
  if npx --yes supabase db reset --linked=false; then
    log "Migrations applied successfully!"
  else
    die "Migration failed. Check the output above for errors."
  fi
}

# ========= VERIFICATION =========
verify_schema() {
  log "Verifying schema..."

  # Count tables
  local table_count
  table_count=$(psql_local -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null | tr -d ' ')
  info "Tables created: ${table_count:-0}"

  # Count RLS policies
  local policy_count
  policy_count=$(psql_local -t -c "SELECT COUNT(*) FROM pg_policies WHERE schemaname='public'" 2>/dev/null | tr -d ' ')
  info "RLS policies: ${policy_count:-0}"

  # Count triggers
  local trigger_count
  trigger_count=$(psql_local -t -c "SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema='public'" 2>/dev/null | tr -d ' ')
  info "Triggers: ${trigger_count:-0}"

  # Count functions
  local function_count
  function_count=$(psql_local -t -c "SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema='public'" 2>/dev/null | tr -d ' ')
  info "Functions: ${function_count:-0}"

  # Count indexes
  local index_count
  index_count=$(psql_local -t -c "SELECT COUNT(*) FROM pg_indexes WHERE schemaname='public'" 2>/dev/null | tr -d ' ')
  info "Indexes: ${index_count:-0}"

  # Count custom types
  local type_count
  type_count=$(psql_local -t -c "SELECT COUNT(*) FROM pg_type t JOIN pg_namespace n ON t.typnamespace = n.oid WHERE n.nspname = 'public' AND t.typtype = 'e'" 2>/dev/null | tr -d ' ')
  info "Custom types (enums): ${type_count:-0}"
}

# ========= SUMMARY =========
show_summary() {
  cat <<EOF

============================================================
MIGRATIONS APPLIED SUCCESSFULLY
============================================================
Repository:       ${REPO_ROOT}
Migrations:       ${MIGRATION_COUNT} files applied

The local database now has:
  - All tables with proper column types
  - Foreign key constraints
  - RLS policies for row-level security
  - Triggers for automated operations
  - Functions for business logic
  - Indexes for query performance

NEXT STEP:
  Sync data from cloud:
  SUPABASE_SERVICE_ROLE_KEY=<key> ./deployment/clone-supabase-data.sh

Access Points:
  Studio:   http://localhost:54323
  API:      http://localhost:54321
  Database: postgresql://postgres:postgres@localhost:54322/postgres
============================================================

EOF
}

# ========= MAIN =========
main() {
  log "Supabase Migration Script"
  log "========================="

  check_supabase_running
  check_migrations_exist
  apply_migrations
  verify_schema
  show_summary

  log "Migration completed successfully!"
  exit 0
}

main "$@"
