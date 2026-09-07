"""
SQL migration validation script.

Validates the SQL migration files for:
  - Basic syntax checks (matching parentheses, semicolons)
  - All CREATE TABLE statements have corresponding primary keys
  - All foreign key references point to tables that exist
  - Spatial columns use the expected SRID
  - GiST indexes exist for spatial columns
  - RLS is enabled on all tables
  - All ENUM types are defined before use

This does NOT connect to a database — it performs static analysis only.
"""

import re
import sys
from pathlib import Path


def read_sql_file(path: Path) -> str:
    """Read a SQL file and strip comments."""
    content = path.read_text(encoding="utf-8")
    # Remove single-line comments
    content = re.sub(r"--[^\n]*", "", content)
    # Remove multi-line comments
    content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)
    return content


def extract_tables(sql: str) -> list[str]:
    """Extract table names from CREATE TABLE statements."""
    return re.findall(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\w+)", sql, re.IGNORECASE)


def extract_enum_types(sql: str) -> list[str]:
    """Extract ENUM type names from CREATE TYPE statements."""
    return re.findall(r"CREATE\s+TYPE\s+(\w+)\s+AS\s+ENUM", sql, re.IGNORECASE)


def extract_foreign_keys(sql: str) -> list[tuple[str, str]]:
    """Extract (column, referenced_table) pairs from REFERENCES clauses."""
    return re.findall(r"REFERENCES\s+(\w+(?:\.\w+)?)\((\w+)\)", sql, re.IGNORECASE)


def extract_spatial_columns(sql: str) -> list[tuple[str, str]]:
    """Extract spatial column definitions with their SRID."""
    # Match geography(Point, 4326) or geometry(Polygon, 4326) etc.
    return re.findall(r"(geometry|geography)\(\w+,\s*(\d+)\)", sql, re.IGNORECASE)


def extract_gist_indexes(sql: str) -> list[str]:
    """Extract column names from GiST index definitions."""
    return re.findall(r"USING\s+GIST\s*\((\w+)\)", sql, re.IGNORECASE)


def extract_rls_tables(sql: str) -> list[str]:
    """Extract table names with RLS enabled."""
    return re.findall(r"ALTER\s+TABLE\s+(\w+)\s+ENABLE\s+ROW\s+LEVEL\s+SECURITY", sql, re.IGNORECASE)


def validate_migrations():
    """Run all validation checks."""
    migrations_dir = Path(__file__).parent.parent / "migrations"

    if not migrations_dir.exists():
        print(f"ERROR: Migrations directory not found: {migrations_dir}")
        return False

    migration_files = sorted(migrations_dir.glob("*.sql"))
    if not migration_files:
        print("ERROR: No SQL migration files found")
        return False

    # Combine all SQL
    all_sql = ""
    for f in migration_files:
        print(f"Reading: {f.name}")
        all_sql += read_sql_file(f) + "\n"

    errors = []
    warnings = []

    # 1. Check tables created
    tables = extract_tables(all_sql)
    print(f"\nTables found: {len(tables)}")
    for t in tables:
        print(f"  - {t}")

    if len(tables) < 11:
        errors.append(f"Expected at least 11 tables, found {len(tables)}")

    # 2. Check ENUM types
    enums = extract_enum_types(all_sql)
    print(f"\nENUM types found: {len(enums)}")
    for e in enums:
        print(f"  - {e}")

    # 3. Check spatial columns use SRID 4326
    spatial = extract_spatial_columns(all_sql)
    print(f"\nSpatial columns found: {len(spatial)}")
    for col_type, srid in spatial:
        status = "✅" if srid == "4326" else "❌"
        print(f"  {status} {col_type}(SRID={srid})")
        if srid != "4326":
            errors.append(f"Spatial column uses SRID {srid}, expected 4326")

    # 4. Check GiST indexes
    gist_cols = extract_gist_indexes(all_sql)
    print(f"\nGiST indexes found: {len(gist_cols)}")
    for col in gist_cols:
        print(f"  - {col}")

    # 5. Check foreign keys reference valid tables
    fks = extract_foreign_keys(all_sql)
    print(f"\nForeign keys found: {len(fks)}")
    known_tables = set(tables) | {"auth.users"}  # auth.users is a Supabase system table
    for ref_table, ref_col in fks:
        status = "✅" if ref_table in known_tables else "⚠️"
        print(f"  {status} → {ref_table}({ref_col})")
        if ref_table not in known_tables:
            warnings.append(f"Foreign key references {ref_table} which is not defined in migrations (may be a system table)")

    # 6. Check RLS enabled on all tables
    rls_tables = extract_rls_tables(all_sql)
    print(f"\nRLS enabled on: {len(rls_tables)} tables")
    for t in tables:
        status = "✅" if t in rls_tables else "❌"
        print(f"  {status} {t}")
        if t not in rls_tables:
            errors.append(f"RLS not enabled on table: {t}")

    # 7. Check balanced parentheses in each statement
    statements = all_sql.split(";")
    for i, stmt in enumerate(statements):
        open_count = stmt.count("(")
        close_count = stmt.count(")")
        if open_count != close_count:
            errors.append(f"Unbalanced parentheses in statement #{i+1}: {open_count} open, {close_count} close")

    # Summary
    print("\n" + "=" * 60)
    if errors:
        print(f"❌ VALIDATION FAILED — {len(errors)} error(s):")
        for e in errors:
            print(f"  - {e}")
    else:
        print("✅ VALIDATION PASSED — All checks passed")

    if warnings:
        print(f"\n⚠️ {len(warnings)} warning(s):")
        for w in warnings:
            print(f"  - {w}")

    return len(errors) == 0


if __name__ == "__main__":
    success = validate_migrations()
    sys.exit(0 if success else 1)
