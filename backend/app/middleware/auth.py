"""
Authentication middleware for Firebase token verification.
"""

from typing import Annotated, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.config.firebase import verify_firebase_token

# HTTP Bearer token scheme
security = HTTPBearer(auto_error=False)


class AuthenticatedUser:
    """Represents an authenticated Firebase user."""

    def __init__(self, uid: str, email: Optional[str], token_data: dict):
        self.uid = uid
        self.email = email
        self.token_data = token_data

    @property
    def email_verified(self) -> bool:
        return self.token_data.get("email_verified", False)


async def get_current_user(
    credentials: Annotated[
        Optional[HTTPAuthorizationCredentials], Depends(security)
    ],
) -> AuthenticatedUser:
    """
    Dependency that extracts and verifies the Firebase token.

    Usage:
        @router.get("/protected")
        async def protected_route(user: AuthenticatedUser = Depends(get_current_user)):
            return {"uid": user.uid}
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    decoded_token = verify_firebase_token(token)

    if decoded_token is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return AuthenticatedUser(
        uid=decoded_token["uid"],
        email=decoded_token.get("email"),
        token_data=decoded_token,
    )


async def get_optional_user(
    credentials: Annotated[
        Optional[HTTPAuthorizationCredentials], Depends(security)
    ],
) -> Optional[AuthenticatedUser]:
    """
    Dependency that optionally extracts the Firebase token.
    Returns None if no token provided (doesn't raise error).

    Usage:
        @router.get("/public-or-private")
        async def route(user: Optional[AuthenticatedUser] = Depends(get_optional_user)):
            if user:
                return {"message": f"Hello {user.email}"}
            return {"message": "Hello guest"}
    """
    if credentials is None:
        return None

    token = credentials.credentials
    decoded_token = verify_firebase_token(token)

    if decoded_token is None:
        return None

    return AuthenticatedUser(
        uid=decoded_token["uid"],
        email=decoded_token.get("email"),
        token_data=decoded_token,
    )


# Type alias for cleaner dependency injection
CurrentUser = Annotated[AuthenticatedUser, Depends(get_current_user)]
OptionalUser = Annotated[Optional[AuthenticatedUser], Depends(get_optional_user)]
