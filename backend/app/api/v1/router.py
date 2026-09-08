"""
API v1 router.

Aggregates all v1 endpoint routers into a single router
that is included by the main application.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import health, system

v1_router = APIRouter()

# Include endpoint routers
v1_router.include_router(health.router, prefix="/health", tags=["health"])
v1_router.include_router(system.router, prefix="/system", tags=["system"])
