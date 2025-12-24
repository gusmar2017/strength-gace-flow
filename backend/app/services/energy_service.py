"""
Energy tracking service for managing daily energy levels.
"""

from datetime import date, datetime, timedelta
from typing import Optional

from google.cloud.firestore_v1 import FieldFilter

from app.config.firebase import get_firestore_client
from app.models.energy import EnergyLog, LogEnergyRequest


async def log_energy(user_id: str, data: LogEnergyRequest) -> EnergyLog:
    """
    Log daily energy level for a user.

    If an entry already exists for the given date, it will be updated.
    Otherwise, a new entry is created.
    """
    db = get_firestore_client()
    energy_ref = db.collection("users").document(user_id).collection("energy_logs")

    # Check if entry already exists for this date
    existing_query = (
        energy_ref
        .where(filter=FieldFilter("date", "==", data.date))
        .limit(1)
    )

    existing_docs = list(existing_query.stream())

    now = datetime.utcnow()

    if existing_docs:
        # Update existing entry
        doc_ref = existing_docs[0].reference
        doc_ref.update({
            "score": data.score,
            "notes": data.notes,
            "updated_at": now,
        })
        doc_id = doc_ref.id
    else:
        # Create new entry
        doc_data = {
            "user_id": user_id,
            "date": data.date,
            "score": data.score,
            "notes": data.notes,
            "created_at": now,
            "updated_at": now,
        }
        doc_ref = energy_ref.document()
        doc_ref.set(doc_data)
        doc_id = doc_ref.id

    # Fetch and return the created/updated document
    doc = doc_ref.get()
    doc_data = doc.to_dict()

    return EnergyLog(
        id=doc_id,
        user_id=user_id,
        date=doc_data["date"],
        score=doc_data["score"],
        notes=doc_data.get("notes"),
        created_at=doc_data["created_at"],
        updated_at=doc_data["updated_at"],
    )


async def get_energy_for_date(user_id: str, target_date: date) -> Optional[EnergyLog]:
    """
    Get energy log for a specific date.

    Returns None if no entry exists for the given date.
    """
    db = get_firestore_client()
    energy_ref = db.collection("users").document(user_id).collection("energy_logs")

    query = (
        energy_ref
        .where(filter=FieldFilter("date", "==", target_date))
        .limit(1)
    )

    docs = list(query.stream())

    if not docs:
        return None

    doc = docs[0]
    doc_data = doc.to_dict()

    return EnergyLog(
        id=doc.id,
        user_id=user_id,
        date=doc_data["date"],
        score=doc_data["score"],
        notes=doc_data.get("notes"),
        created_at=doc_data["created_at"],
        updated_at=doc_data["updated_at"],
    )


async def get_energy_history(user_id: str, days: int = 30) -> list[EnergyLog]:
    """
    Get energy log history for the user.

    Returns entries from the past N days, sorted by date descending.
    """
    db = get_firestore_client()
    energy_ref = db.collection("users").document(user_id).collection("energy_logs")

    # Calculate cutoff date
    cutoff_date = date.today() - timedelta(days=days)

    query = (
        energy_ref
        .where(filter=FieldFilter("date", ">=", cutoff_date))
        .order_by("date", direction="DESCENDING")
        .limit(days)
    )

    docs = query.stream()

    energy_logs = []
    for doc in docs:
        doc_data = doc.to_dict()
        energy_logs.append(
            EnergyLog(
                id=doc.id,
                user_id=user_id,
                date=doc_data["date"],
                score=doc_data["score"],
                notes=doc_data.get("notes"),
                created_at=doc_data["created_at"],
                updated_at=doc_data["updated_at"],
            )
        )

    return energy_logs


async def delete_energy_log(user_id: str, log_id: str) -> bool:
    """
    Delete an energy log entry.

    Returns True if deleted, False if not found.
    """
    db = get_firestore_client()
    doc_ref = (
        db.collection("users")
        .document(user_id)
        .collection("energy_logs")
        .document(log_id)
    )

    doc = doc_ref.get()
    if not doc.exists:
        return False

    # Verify the log belongs to the user
    doc_data = doc.to_dict()
    if doc_data.get("user_id") != user_id:
        return False

    doc_ref.delete()
    return True
