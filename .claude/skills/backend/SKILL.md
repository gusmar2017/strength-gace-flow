---
name: backend
description: FastAPI backend development for Strength Grace & Flow. Use for adding endpoints, services, models, or working with Firebase/Firestore integration.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Backend Development Skill

Expert guidance for working with the Strength Grace & Flow FastAPI backend.

## Architecture Overview

**Stack**: Python 3.13, FastAPI, Firebase Admin SDK, Anthropic Claude API, pytest

**Structure**:
```
backend/app/
├── main.py                 # FastAPI app initialization, CORS, router registration
├── routers/                # API endpoints (users, cycle, energy, workouts, recommendations, health)
├── services/               # Business logic and Firestore operations
├── models/                 # Pydantic models for validation and serialization
├── middleware/             # Authentication (Firebase token verification)
├── ai/                     # Claude AI integration (prompts, agents)
├── config/                 # Settings and Firebase initialization
└── utils/                  # Helper functions (cycle calculations)
```

**Key architectural principles**:
- Routers define API endpoints and handle HTTP concerns
- Services contain business logic and database operations
- Models define request/response schemas with Pydantic
- All Firestore operations are async
- Firebase Auth tokens are verified via middleware
- User context is injected via dependency injection

## Project Structure Patterns

### Router Pattern (`backend/app/routers/`)
Routers handle HTTP concerns: request validation, response formatting, error handling.

**Example**: `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/routers/users.py`

```python
from fastapi import APIRouter, HTTPException, status
from app.middleware.auth import CurrentUser
from app.models.user import UserProfileResponse, UserCreate, UserUpdate
from app.services import user_service

router = APIRouter(prefix="/api/v1/users", tags=["Users"])

@router.get("/me", response_model=UserProfileResponse)
async def get_current_user_profile(user: CurrentUser):
    """Get the current user's profile."""
    profile = await user_service.get_user_profile(user.uid)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found. Please create a profile first.",
        )
    return UserProfileResponse(user=profile)
```

**Key patterns**:
- Use `CurrentUser` type annotation for authenticated endpoints
- Always use `response_model` to document response structure
- Return appropriate HTTP status codes (404, 409, 201, etc.)
- Call services for business logic, don't implement it in routers
- Use meaningful error messages

### Service Pattern (`backend/app/services/`)
Services implement business logic and handle Firestore operations.

**Example**: `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/services/cycle_service.py`

```python
from datetime import datetime
from app.config.firebase import get_firestore_client
from app.models.cycle import CycleData, CycleInfoResponse

async def get_current_cycle_info(user_id: str) -> Optional[CycleInfoResponse]:
    """Get current cycle phase information for a user."""
    user = await user_service.get_user_profile(user_id)
    if user is None:
        return None

    # Calculate current phase
    cycle_info = calculate_current_phase(
        last_period_start=user.last_period_start_date,
        average_cycle_length=user.average_cycle_length,
    )
    return CycleInfoResponse(cycle=cycle_info, ...)
```

**Key patterns**:
- All Firestore operations are async
- Get Firestore client: `db = get_firestore_client()`
- User data path: `db.collection("users").document(user_id)`
- Subcollections: `.collection("cycleData")`
- Always handle None cases when querying
- Use `datetime.utcnow()` for timestamps
- Convert datetime to date when needed: `.date()`

### Model Pattern (`backend/app/models/`)
Pydantic models define request/response schemas and validation rules.

**Example**: `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/models/user.py`

```python
from pydantic import BaseModel, Field, EmailStr
from enum import Enum

class FitnessLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"

class UserCreate(BaseModel):
    """Fields for creating a new user profile."""
    display_name: Optional[str] = None
    fitness_level: Optional[FitnessLevel] = None
    average_cycle_length: int = Field(default=28, ge=21, le=45)

class UserProfileResponse(BaseModel):
    """API response wrapper."""
    user: UserProfile
```

**Key patterns**:
- Use Enums for fixed choices
- Add validation with Field (ge, le, min_length, etc.)
- Separate models for Create, Update, and Response
- Response wrappers contain the data object
- Optional fields use `Optional[T] = None`

## Key Files Reference

### Core Application
- `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/main.py` - FastAPI app, CORS, router registration, lifespan events
- `/Users/gustavomarquez/Documents/strength-grace-flow/backend/requirements.txt` - Dependencies

### Configuration
- `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/config/settings.py` - Environment variables, Pydantic Settings
- `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/config/firebase.py` - Firebase initialization, token verification

### Authentication
- `/Users/gustavomarquez/Documents/strength-grace-flow/backend/app/middleware/auth.py` - `CurrentUser`, `OptionalUser` dependencies

### Routers (API Endpoints)
- `backend/app/routers/users.py` - Profile CRUD
- `backend/app/routers/cycle.py` - Cycle tracking, phase info, predictions
- `backend/app/routers/energy.py` - Energy logging
- `backend/app/routers/workouts.py` - Workout library and history
- `backend/app/routers/recommendations.py` - AI-powered workout recommendations
- `backend/app/routers/health.py` - Health check endpoint

### Services (Business Logic)
- `backend/app/services/user_service.py` - User CRUD operations
- `backend/app/services/cycle_service.py` - Cycle tracking logic
- `backend/app/services/workout_service.py` - Workout management
- `backend/app/services/recommendation_service.py` - Claude AI integration

### AI Integration
- `backend/app/ai/prompts/` - Claude prompt templates
- `backend/app/services/recommendation_service.py` - Anthropic API calls

## Development Patterns

### Adding a New Endpoint

1. **Define the model** (`backend/app/models/`)
```python
class NewFeatureRequest(BaseModel):
    field: str = Field(min_length=1)

class NewFeatureResponse(BaseModel):
    data: dict
    created_at: datetime
```

2. **Create the service** (`backend/app/services/`)
```python
async def create_new_feature(user_id: str, data: NewFeatureRequest):
    db = get_firestore_client()
    user_ref = db.collection("users").document(user_id)
    # Implementation
    return result
```

3. **Add the router** (`backend/app/routers/`)
```python
router = APIRouter(prefix="/api/v1/features", tags=["Features"])

@router.post("/", response_model=NewFeatureResponse)
async def create_feature(user: CurrentUser, data: NewFeatureRequest):
    result = await new_service.create_new_feature(user.uid, data)
    return NewFeatureResponse(data=result, ...)
```

4. **Register in main.py**
```python
from app.routers import new_feature
app.include_router(new_feature.router)
```

### Working with Firebase/Firestore

**Get Firestore client**:
```python
from app.config.firebase import get_firestore_client
db = get_firestore_client()
```

**User document pattern**:
```python
# Get user doc
user_ref = db.collection("users").document(user_id)
doc = user_ref.get()
if not doc.exists:
    return None
data = doc.to_dict()

# Update user
user_ref.update({"field": value, "updated_at": datetime.utcnow()})

# Create user
user_ref.set({"field": value, "created_at": datetime.utcnow()})
```

**Subcollection pattern** (e.g., cycleData):
```python
cycles_ref = db.collection("users").document(user_id).collection("cycleData")

# Query
query = cycles_ref.order_by("start_date", direction="DESCENDING").limit(10)
for doc in query.stream():
    data = doc.to_dict()
    # Process

# Create with auto ID
cycle_id = str(uuid.uuid4())
cycles_ref.document(cycle_id).set(cycle_data)
```

**Date handling**:
```python
from datetime import datetime, date

# Store in Firestore
firestore_timestamp = datetime.combine(date_obj, datetime.min.time())

# Read from Firestore
date_obj = firestore_timestamp.date() if isinstance(firestore_timestamp, datetime) else firestore_timestamp
```

### Authentication Pattern

**Protected endpoint**:
```python
from app.middleware.auth import CurrentUser

@router.get("/protected")
async def protected_route(user: CurrentUser):
    # user.uid, user.email available
    return {"user_id": user.uid}
```

**Optional authentication**:
```python
from app.middleware.auth import OptionalUser

@router.get("/maybe-protected")
async def route(user: OptionalUser):
    if user:
        # Authenticated
        pass
    else:
        # Anonymous
        pass
```

## Testing Patterns

**Setup**: pytest with pytest-asyncio

**Run tests**:
```bash
cd /Users/gustavomarquez/Documents/strength-grace-flow/backend
python -m pytest
python -m pytest tests/test_specific.py -v
```

**Async test pattern**:
```python
import pytest

@pytest.mark.asyncio
async def test_get_user_profile():
    user_id = "test_user_123"
    profile = await user_service.get_user_profile(user_id)
    assert profile is not None
```

## Common Tasks

### Add a new API endpoint
1. Create model in `backend/app/models/`
2. Implement service in `backend/app/services/`
3. Create router in `backend/app/routers/`
4. Register router in `backend/app/main.py`

### Modify existing service logic
1. Read the service file: `backend/app/services/<name>_service.py`
2. Update the business logic
3. Check if models need updates: `backend/app/models/<name>.py`
4. Test the changes

### Add Firebase query
1. Get Firestore client: `get_firestore_client()`
2. Build query with `.collection()`, `.document()`, `.where()`, `.order_by()`
3. Stream results with `.stream()` or get single with `.get()`
4. Convert to model objects

### Integrate with Claude AI
1. Check `backend/app/services/recommendation_service.py` for pattern
2. Create prompt in `backend/app/ai/prompts/`
3. Use Anthropic client:
```python
from anthropic import Anthropic
client = Anthropic(api_key=settings.anthropic_api_key)
message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system=SYSTEM_PROMPT,
    messages=[{"role": "user", "content": prompt}],
)
```

### Debug Firestore queries
1. Check Firebase console for data structure
2. Print query results: `print(doc.to_dict())`
3. Verify collection/document paths
4. Check date/timestamp conversions

## When to Use This Skill

**Use this skill when**:
- Adding new API endpoints
- Modifying service logic
- Working with Firestore queries
- Implementing authentication
- Integrating with Claude AI
- Debugging backend issues
- Understanding FastAPI patterns

**Don't use this skill for**:
- iOS/Swift development (that's frontend)
- Database schema design discussions (use general agent)
- DevOps/deployment (unless modifying Dockerfile)
- Non-backend codebase exploration
