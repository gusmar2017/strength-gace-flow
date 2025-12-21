"""
Application settings using Pydantic Settings management.
Loads configuration from environment variables.
"""

from functools import lru_cache
from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # Server
    environment: str = "development"
    port: int = 8000
    api_url: str = "http://localhost:8000"

    # Firebase - either path to JSON file or the JSON content itself
    firebase_service_account_path: Optional[str] = None
    firebase_service_account_json: Optional[str] = None

    # Claude AI
    anthropic_api_key: Optional[str] = None

    # Vimeo (deferred)
    vimeo_access_token: Optional[str] = None

    @property
    def is_production(self) -> bool:
        return self.environment == "production"

    @property
    def is_development(self) -> bool:
        return self.environment == "development"


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
