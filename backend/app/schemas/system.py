"""
System status response schema.
"""

from typing import Optional

from pydantic import BaseModel, Field


class DatabaseStats(BaseModel):
    """Database statistics."""

    total_risk_cells: int = Field(default=0, description="Number of risk cells in the database")
    total_sensors: int = Field(default=0, description="Number of sensors deployed")


class DatabaseStatus(BaseModel):
    """Detailed database status."""

    status: str = Field(..., description="Connection status (e.g., 'connected', 'error')")
    message: str = Field(..., description="Human-readable message")
    stats: Optional[DatabaseStats] = Field(default=None, description="Basic table statistics")


class SystemStatusResponse(BaseModel):
    """Response schema for the system status endpoint."""

    api_status: str = Field(..., description="API operational status")
    version: str = Field(..., description="API version")
    database: DatabaseStatus = Field(..., description="Database connection and stats")
