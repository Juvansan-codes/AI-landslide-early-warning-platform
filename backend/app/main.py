"""
FastAPI application entrypoint.

Creates the FastAPI app, configures CORS middleware,
and includes all API routers.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.api.v1.router import v1_router


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    application = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description=(
            "Backend API for the AI Landslide Early Warning Platform. "
            "Provides risk assessment, GIS data, sensor ingestion, "
            "and alert management endpoints."
        ),
        docs_url="/docs",
        redoc_url="/redoc",
    )

    # CORS middleware
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include API routers
    application.include_router(v1_router, prefix="/api/v1")

    return application


app = create_app()
