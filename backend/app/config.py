"""
Application configuration using Pydantic Settings.

Loads environment variables from a .env file (if present) and exposes
them as typed attributes. All fields are optional at this stage so the
application can start without a .env file during initial development.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # --- Application ---
    APP_NAME: str = "AI Landslide Early Warning Platform"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False

    # --- CORS ---
    CORS_ORIGINS: str = "http://localhost:3000"

    # --- Supabase (future) ---
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    DATABASE_URL: str = ""

    # --- External APIs (future) ---
    ROBOFLOW_API_KEY: str = ""
    IMD_API_KEY: str = ""
    EARTHENGINE_PROJECT: str = ""

    @property
    def cors_origins_list(self) -> list[str]:
        """Parse CORS_ORIGINS as a comma-separated list."""
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]


settings = Settings()
