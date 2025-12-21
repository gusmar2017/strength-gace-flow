"""
Strength Grace & Flow API
Backend for the cycle-synced fitness iOS app
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import health

app = FastAPI(
    title="Strength Grace & Flow API",
    description="Backend API for the cycle-synced fitness app",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
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


@app.get("/")
async def root():
    """Root endpoint with API info"""
    return {
        "name": "Strength Grace & Flow API",
        "version": "0.1.0",
        "docs": "/docs",
        "health": "/api/health",
    }
