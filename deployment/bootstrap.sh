#!/usr/bin/env bash
# ============================================
# OPS SERVER BOOTSTRAP SCRIPT
# ============================================
# Ensures Node.js is installed, loads .env.ops, and starts ops-server.
# Designed for unattended startup of the Supabase management API.
#
# Usage:
#   ./deployment/bootstrap.sh
#   ./deployment/bootstrap.sh --check  (just verify prerequisites)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NODE_MIN_VERSION=18

# ========= HELPERS =========
log()  { printf "[bootstrap] %s\n" "$*"; }
warn() { printf "[bootstrap] WARNING: %s\n" "$*" >&2; }
die()  { printf "[bootstrap] ERROR: %s\n" "$*" >&2; exit 1; }

get_node_major() {
  if command -v node >/dev/null 2>&1; then
    node -v | sed 's/^v//' | cut -d. -f1
  else
    echo "0"
  fi
}

# ========= PREREQUISITES =========
check_node() {
  local major
  major=$(get_node_major)

  if [ "$major" -ge "$NODE_MIN_VERSION" ]; then
    log "Node.js v$(node -v | sed 's/^v//') detected (OK)"
    return 0
  fi

  return 1
}

install_node() {
  log "Node.js not found or version too old. Attempting to install..."

  # Detect OS and install accordingly
  if command -v apt-get >/dev/null 2>&1; then
    # Debian/Ubuntu
    log "Installing Node.js ${NODE_MIN_VERSION}.x via NodeSource..."
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MIN_VERSION}.x" | sudo -E bash -
    sudo apt-get install -y nodejs
  elif command -v dnf >/dev/null 2>&1; then
    # Fedora/RHEL
    log "Installing Node.js via dnf..."
    sudo dnf module install -y nodejs:${NODE_MIN_VERSION}
  elif command -v brew >/dev/null 2>&1; then
    # macOS with Homebrew
    log "Installing Node.js via Homebrew..."
    brew install node@${NODE_MIN_VERSION}
  else
    die "Cannot auto-install Node.js. Please install Node.js ${NODE_MIN_VERSION}+ manually."
  fi

  # Verify installation
  if ! check_node; then
    die "Node.js installation failed. Please install Node.js ${NODE_MIN_VERSION}+ manually."
  fi
}

load_env_file() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    log "Loading environment from: $env_file"
    # Export variables from .env.ops (skip comments and empty lines)
    while IFS= read -r line || [ -n "$line" ]; do
      # Skip comments and empty lines
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// }" ]] && continue
      # Only export if line contains =
      if [[ "$line" == *"="* ]]; then
        # Extract key and check if already set
        local key="${line%%=*}"
        key="${key// /}"  # trim spaces
        if [ -z "${!key:-}" ]; then
          export "$line" 2>/dev/null || true
        fi
      fi
    done < "$env_file"
  else
    warn ".env.ops not found at $env_file"
    warn "Copy .env.ops.sample to .env.ops and configure your secrets"
  fi
}

# ========= MAIN =========
main() {
  log "Starting ops-server bootstrap..."
  log "Repository root: $REPO_ROOT"

  # Check for --check flag
  if [ "${1:-}" = "--check" ]; then
    log "Running prerequisite check only..."
    if check_node; then
      log "All prerequisites OK"
      exit 0
    else
      warn "Node.js ${NODE_MIN_VERSION}+ not found"
      exit 1
    fi
  fi

  # Ensure Node.js is available
  if ! check_node; then
    install_node
  fi

  # Load .env.ops if it exists
  load_env_file "$REPO_ROOT/.env.ops"

  # Change to repo root for consistent paths
  cd "$REPO_ROOT"

  # Start the ops server
  log "Starting ops-server..."
  log "Press Ctrl+C to stop"
  echo ""

  exec node deployment/ops-server.mjs
}

main "$@"
