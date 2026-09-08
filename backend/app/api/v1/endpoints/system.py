"""
System status and integration verification endpoint.

Provides an endpoint to verify that the complete architecture
(API -> Supabase -> Database) is fully functional and returns
basic database statistics.
"""

import logging
from fastapi import APIRouter, HTTPException, status

from app.schemas.system import SystemStatusResponse, DatabaseStatus, DatabaseStats
from app.config import settings
from app.core.database import get_supabase_client, is_supabase_configured

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get(
    "/status",
    response_model=SystemStatusResponse,
    summary="System Status",
    description="Returns the full system status, including live Supabase database connectivity and stats.",
)
async def get_system_status() -> SystemStatusResponse:
    """
    Check full system health, including database connectivity and statistics.
    
    This is the primary verification endpoint for the frontend dashboard.
    """
    if not is_supabase_configured():
        # Fast failure if credentials are not configured
        db_status = DatabaseStatus(
            status="not_configured",
            message="Supabase credentials are missing from the environment configuration."
        )
        return SystemStatusResponse(
            api_status="healthy",
            version=settings.APP_VERSION,
            database=db_status
        )

    try:
        # Initialize service role client (bypasses RLS)
        client = get_supabase_client()
        
        # We query for counts using the count='exact' and limit=1 for performance
        # Fetching count of risk cells
        cells_response = client.table("risk_cells").select("id", count="exact").limit(1).execute()
        cells_count = cells_response.count if cells_response.count is not None else 0
        
        # Fetching count of sensors
        sensors_response = client.table("sensors").select("id", count="exact").limit(1).execute()
        sensors_count = sensors_response.count if sensors_response.count is not None else 0

        # Create the stats object
        stats = DatabaseStats(
            total_risk_cells=cells_count,
            total_sensors=sensors_count
        )

        db_status = DatabaseStatus(
            status="connected",
            message="Live connection to Supabase established successfully.",
            stats=stats
        )

    except Exception as e:
        logger.error(f"Database status check failed: {str(e)}")
        # Do not expose full stack trace to the client, but log it server-side
        db_status = DatabaseStatus(
            status="error",
            message="Database connection failed. Please check the server logs for details."
        )

    return SystemStatusResponse(
        api_status="healthy",
        version=settings.APP_VERSION,
        database=db_status
    )
