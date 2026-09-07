"""
Health check response schema.
"""

from typing import Optional

from pydantic import BaseModel


class DatabaseHealth(BaseModel):
    """Database connectivity status."""

    status: str
    message: str


class HealthResponse(BaseModel):
    """Response schema for the health check endpoint."""

    status: str
    version: str
    database: Optional[DatabaseHealth] = None
