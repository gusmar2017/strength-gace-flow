"""Health check endpoint for Railway deployment"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/api/health")
async def health_check():
    """
    Health check endpoint.
    Used by Railway to verify the service is running.
    """
    return {
        "status": "healthy",
        "version": "0.1.0",
    }
