"""
Core utilities package.

Provides database connectivity and shared infrastructure.
"""

from app.core.database import (
    get_supabase_client,
    get_user_client,
    is_supabase_configured,
    check_database_health,
    DatabaseError,
    SupabaseNotConfiguredError,
)

__all__ = [
    "get_supabase_client",
    "get_user_client",
    "is_supabase_configured",
    "check_database_health",
    "DatabaseError",
    "SupabaseNotConfiguredError",
]
