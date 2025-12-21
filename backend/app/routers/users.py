"""
User profile API endpoints.
"""

from fastapi import APIRouter, HTTPException, status

from app.middleware.auth import CurrentUser
from app.models.user import (
    UserCreate,
    UserProfile,
    UserProfileResponse,
    UserUpdate,
)
from app.services import user_service

router = APIRouter(prefix="/api/v1/users", tags=["Users"])


@router.get("/me", response_model=UserProfileResponse)
async def get_current_user_profile(user: CurrentUser):
    """
    Get the current user's profile.

    Returns 404 if the user has authenticated but hasn't created a profile yet.
    """
    profile = await user_service.get_user_profile(user.uid)

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found. Please create a profile first.",
        )

    return UserProfileResponse(user=profile)


@router.post("/me", response_model=UserProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_current_user_profile(
    user: CurrentUser,
    data: UserCreate,
):
    """
    Create a profile for the current user.

    This should be called after initial authentication to set up the user's profile.
    Returns 409 if a profile already exists.
    """
    # Check if profile already exists
    existing = await user_service.get_user_profile(user.uid)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User profile already exists. Use PATCH to update.",
        )

    profile = await user_service.create_user_profile(
        user_id=user.uid,
        email=user.email,
        data=data,
    )

    return UserProfileResponse(user=profile)


@router.patch("/me", response_model=UserProfileResponse)
async def update_current_user_profile(
    user: CurrentUser,
    data: UserUpdate,
):
    """
    Update the current user's profile.

    Only provided fields will be updated. Returns 404 if profile doesn't exist.
    """
    profile = await user_service.update_user_profile(user.uid, data)

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found. Please create a profile first.",
        )

    return UserProfileResponse(user=profile)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_current_user_profile(user: CurrentUser):
    """
    Delete the current user's profile and all associated data.

    This is a destructive operation and cannot be undone.
    Note: This only deletes Firestore data, not the Firebase Auth account.
    """
    deleted = await user_service.delete_user_profile(user.uid)

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found.",
        )

    return None
