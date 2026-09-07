"""
Health check endpoint.

Provides a simple endpoint to verify that the API server is running
and responsive. Optionally checks database connectivity.
"""

from fastapi import APIRouter

from app.schemas.health import HealthResponse, DatabaseHealth
from app.config import settings
from app.core.database import check_database_health, is_supabase_configured

router = APIRouter()


@router.get(
    "",
    response_model=HealthResponse,
    summary="Health Check",
    description="Returns the current health status and version of the API, including database connectivity.",
)
async def health_check() -> HealthResponse:
    """Return the health status of the API."""
    db_health = None

    if is_supabase_configured():
        db_status = await check_database_health()
        db_health = DatabaseHealth(**db_status)

    return HealthResponse(
        status="healthy",
        version=settings.APP_VERSION,
        database=db_health,
    )
