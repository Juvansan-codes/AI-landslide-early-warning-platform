"""
Supabase database client initialization.

Provides two client types:
  1. Service client — uses the service role key, bypasses RLS.
     Used by the FastAPI backend for all server-side operations.
  2. User client factory — accepts a user JWT to create a client
     that respects RLS policies. Used when we need user-context queries.

Neither client is created at import time. They are initialized lazily
so the application can start even without Supabase credentials
(useful for local development and testing).
"""

from functools import lru_cache
from typing import Optional

from supabase import create_client, Client

from app.config import settings


class DatabaseError(Exception):
    """Raised when database operations fail."""
    pass


class SupabaseNotConfiguredError(DatabaseError):
    """Raised when Supabase credentials are not configured."""
    pass


def _validate_supabase_config() -> None:
    """Check that required Supabase environment variables are set."""
    if not settings.SUPABASE_URL:
        raise SupabaseNotConfiguredError(
            "SUPABASE_URL is not configured. "
            "Set it in your .env file or environment variables."
        )
    if not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise SupabaseNotConfiguredError(
            "SUPABASE_SERVICE_ROLE_KEY is not configured. "
            "Set it in your .env file or environment variables."
        )


@lru_cache(maxsize=1)
def get_supabase_client() -> Client:
    """
    Get the Supabase service client (bypasses RLS).

    This client uses the service role key and should ONLY be used
    in the backend. Never expose the service role key to the frontend.

    Returns:
        Supabase Client instance.

    Raises:
        SupabaseNotConfiguredError: If credentials are missing.
    """
    _validate_supabase_config()
    return create_client(
        settings.SUPABASE_URL,
        settings.SUPABASE_SERVICE_ROLE_KEY,
    )


def get_user_client(access_token: str) -> Client:
    """
    Create a Supabase client with a user's JWT for RLS-aware queries.

    Args:
        access_token: The user's Supabase JWT access token.

    Returns:
        Supabase Client instance scoped to the user's permissions.

    Raises:
        SupabaseNotConfiguredError: If credentials are missing.
    """
    if not settings.SUPABASE_URL:
        raise SupabaseNotConfiguredError(
            "SUPABASE_URL is not configured."
        )
    if not settings.SUPABASE_ANON_KEY:
        raise SupabaseNotConfiguredError(
            "SUPABASE_ANON_KEY is not configured."
        )

    client = create_client(
        settings.SUPABASE_URL,
        settings.SUPABASE_ANON_KEY,
    )
    client.auth.set_session(access_token, "")
    return client


def is_supabase_configured() -> bool:
    """
    Check if Supabase credentials are configured.

    Returns:
        True if both SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set.
    """
    return bool(settings.SUPABASE_URL and settings.SUPABASE_SERVICE_ROLE_KEY)


async def check_database_health() -> dict:
    """
    Check database connectivity by attempting a simple query.

    Returns:
        Dict with status information.
    """
    if not is_supabase_configured():
        return {
            "status": "not_configured",
            "message": "Supabase credentials not set",
        }

    try:
        client = get_supabase_client()
        # Simple connectivity check — query a non-existent table
        # will fail gracefully but proves the connection works
        result = client.table("risk_cells").select("id").limit(1).execute()
        return {
            "status": "connected",
            "message": "Database connection successful",
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Database connection failed: {str(e)}",
        }
