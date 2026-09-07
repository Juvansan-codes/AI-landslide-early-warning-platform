"""
Health check endpoint.

Provides a simple endpoint to verify that the API server is running
and responsive.
"""

from fastapi import APIRouter

from app.schemas.health import HealthResponse
from app.config import settings

router = APIRouter()


@router.get(
    "",
    response_model=HealthResponse,
    summary="Health Check",
    description="Returns the current health status and version of the API.",
)
async def health_check() -> HealthResponse:
    """Return the health status of the API."""
    return HealthResponse(
        status="healthy",
        version=settings.APP_VERSION,
    )
