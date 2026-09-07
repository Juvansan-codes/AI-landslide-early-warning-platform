# Database Migrations

This directory contains SQL migration files for the Supabase PostgreSQL + PostGIS database.

## Migration Strategy

Migrations are **numbered SQL files** applied in order. Each file is idempotent where possible (uses `IF NOT EXISTS`, `CREATE OR REPLACE`).

### How to Apply Migrations

#### Option 1: Supabase Dashboard (Recommended for initial setup)

1. Open your Supabase project dashboard.
2. Navigate to **SQL Editor**.
3. Copy and paste each migration file in order (001, 002, ...).
4. Execute each one sequentially.

#### Option 2: Supabase CLI

```bash
supabase db push
```

#### Option 3: Direct psql

```bash
psql $DATABASE_URL -f migrations/001_enable_postgis.sql
psql $DATABASE_URL -f migrations/002_core_schema.sql
```

### Migration Order

| File | Description |
|------|-------------|
| `001_enable_postgis.sql` | Enable PostGIS extension, create utility functions |
| `002_core_schema.sql` | Core schema: all tables, indexes, constraints, RLS |

### Creating New Migrations

1. Create a new file with the next sequential number: `003_description.sql`
2. Write idempotent SQL (use `IF NOT EXISTS` where possible).
3. Test in a development Supabase project first.
4. Document the migration in this README.
5. Apply to production only after verification.

### Rollback

Supabase does not have built-in rollback. For destructive changes:

1. Create a backup first.
2. Write a separate rollback SQL file if needed.
3. Test in development before applying to production.

### PostGIS

PostGIS is enabled in `001_enable_postgis.sql`. It provides:

- Spatial data types (`geometry`, `geography`)
- Spatial functions (`ST_DWithin`, `ST_Intersects`, `ST_Distance`, etc.)
- Spatial indexes (GiST)

All spatial data uses **SRID 4326 (WGS 84)**.
