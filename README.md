# Supabase Sync Scripts

Scripts to sync data from cloud Supabase to a self-hosted instance.

## Quick Start

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/supa-sync.git /opt/zulu
cd /opt/zulu

# Install dependencies
sudo apt-get update && sudo apt-get install -y curl jq postgresql-client

# Configure
cp .env.ops.sample .env.ops
nano .env.ops  # Add your SUPABASE_SERVICE_ROLE_KEY

# Apply migrations (creates database schema)
./deployment/apply-migrations.sh

# Sync data from cloud
source .env.ops
./deployment/clone-supabase-data.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `deployment/apply-migrations.sh` | Creates database schema from SQL migrations |
| `deployment/clone-supabase-data.sh` | Syncs data from cloud Supabase to local |
| `deployment/ops-server.mjs` | HTTP API for UI-triggered sync (optional) |
| `deployment/bootstrap.sh` | Lightweight Node.js setup |

## Environment Variables

Create `.env.ops`:

```bash
# Required - get from Supabase dashboard
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Optional - for direct PostgreSQL auth sync (preserves passwords)
CLOUD_DB_HOST=db.your-project.supabase.co
CLOUD_DB_PASSWORD=your-db-password
```

## Requirements

- Ubuntu 22.04 (or compatible Linux)
- Docker with Supabase stack running
- `curl`, `jq`, `postgresql-client`
- Node.js 18+ (for ops-server only)
