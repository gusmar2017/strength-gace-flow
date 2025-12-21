"""
Strength Grace & Flow API
Backend for the cycle-synced fitness iOS app
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config.firebase import initialize_firebase
from app.config.settings import get_settings
from app.routers import cycle, health, users


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize services on startup."""
    settings = get_settings()

    # Initialize Firebase Admin SDK
    try:
        initialize_firebase()
        print("Firebase Admin SDK initialized successfully")
    except Exception as e:
        print(f"Warning: Firebase initialization failed: {e}")
        if settings.is_production:
            raise

    yield


app = FastAPI(
    title="Strength Grace & Flow API",
    description="Backend API for the cycle-synced fitness app",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS configuration - allow iOS app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict to specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["Health"])
app.include_router(users.router)
app.include_router(cycle.router)


@app.get("/")
async def root():
    """Root endpoint with API info"""
    return {
        "name": "Strength Grace & Flow API",
        "version": "0.1.0",
        "docs": "/docs",
        "health": "/api/health",
        "endpoints": {
            "users": "/api/v1/users/me",
            "cycle": "/api/v1/cycle/current",
        },
    }
