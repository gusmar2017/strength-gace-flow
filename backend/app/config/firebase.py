"""
Firebase Admin SDK initialization.
Handles authentication token verification and Firestore access.
"""

import json
from functools import lru_cache
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials, firestore

from app.config.settings import get_settings


def _get_credentials() -> credentials.Certificate:
    """Get Firebase credentials from environment."""
    settings = get_settings()

    # Try JSON string first (for Railway/production)
    if settings.firebase_service_account_json:
        try:
            service_account_info = json.loads(settings.firebase_service_account_json)
            return credentials.Certificate(service_account_info)
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid Firebase service account JSON: {e}")

    # Fall back to file path (for local development)
    if settings.firebase_service_account_path:
        return credentials.Certificate(settings.firebase_service_account_path)

    raise ValueError(
        "Firebase credentials not configured. "
        "Set FIREBASE_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_PATH"
    )


def initialize_firebase() -> None:
    """Initialize Firebase Admin SDK if not already initialized."""
    if not firebase_admin._apps:
        cred = _get_credentials()
        firebase_admin.initialize_app(cred)


@lru_cache
def get_firestore_client() -> firestore.Client:
    """Get Firestore client instance."""
    initialize_firebase()
    return firestore.client()


def verify_firebase_token(id_token: str) -> Optional[dict]:
    """
    Verify a Firebase ID token and return the decoded token.

    Args:
        id_token: The Firebase ID token from the client

    Returns:
        Decoded token dict with user info, or None if invalid
    """
    initialize_firebase()
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except auth.InvalidIdTokenError:
        return None
    except auth.ExpiredIdTokenError:
        return None
    except Exception:
        return None


def get_user_by_uid(uid: str) -> Optional[auth.UserRecord]:
    """Get Firebase user by UID."""
    initialize_firebase()
    try:
        return auth.get_user(uid)
    except auth.UserNotFoundError:
        return None
