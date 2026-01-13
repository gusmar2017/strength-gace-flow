# Strength Grace & Flow - API Reference

## Base URL

```
Production: https://strength-grace-flow.railway.app
```

All endpoints are prefixed with `/api/v1` unless otherwise noted.

## Authentication

All API endpoints (except `/api/health`) require Firebase authentication.

### Authentication Header

```http
Authorization: Bearer <firebase-id-token>
```

The backend middleware verifies the Firebase token and extracts the user ID for all operations.

## Health Check

### GET /api/health

Health check endpoint used by Railway to verify service status.

**Response:**
```json
{
  "status": "healthy",
  "version": "0.1.0"
}
```

## Users

### GET /api/v1/users/me

Get the current user's profile.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "display_name": "Jane Doe",
    "fitness_level": "intermediate",
    "goals": ["buildStrength", "hormoneBalance"],
    "average_cycle_length": 28,
    "average_period_length": 5,
    "last_period_start": "2026-01-01",
    "notifications_enabled": true,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-10T00:00:00Z"
  }
}
```

**Error:** `404 Not Found` - Profile not created yet

---

### POST /api/v1/users/me

Create a profile for the current authenticated user.

**Authentication:** Required

**Request Body:**
```json
{
  "display_name": "Jane Doe",
  "fitness_level": "intermediate",
  "goals": ["buildStrength", "hormoneBalance"],
  "average_cycle_length": 28,
  "average_period_length": 5
}
```

**Response:** `201 Created`
```json
{
  "user": { ... }
}
```

**Error:** `409 Conflict` - Profile already exists

---

### PATCH /api/v1/users/me

Update the current user's profile. Only provided fields will be updated.

**Authentication:** Required

**Request Body:**
```json
{
  "display_name": "Jane Smith",
  "fitness_level": "advanced",
  "notifications_enabled": false
}
```

**Response:** `200 OK`
```json
{
  "user": { ... }
}
```

---

### DELETE /api/v1/users/me

Delete the current user's profile and all associated data.

**Authentication:** Required

**Response:** `204 No Content`

**Note:** This only deletes Firestore data, not the Firebase Auth account.

## Cycle Tracking

### GET /api/v1/cycle/current

Get current cycle phase information including phase, cycle day, and predictions.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "cycle": {
    "current_phase": "follicular",
    "cycle_day": 10,
    "days_until_next_phase": 3,
    "next_phase": "ovulatory"
  },
  "phase_info": {
    "name": "Follicular",
    "description": "Energy is rising. Great time to try new things and build strength.",
    "color": "#6F8F9B"
  }
}
```

**Error:** `404 Not Found` - No period logged yet

---

### POST /api/v1/cycle/log-period

Log the start of a new period. Updates cycle tracking and recalculates phase.

**Authentication:** Required

**Request Body:**
```json
{
  "start_date": "2026-01-12",
  "notes": "Light flow, minimal cramping"
}
```

**Response:** `200 OK`
```json
{
  "cycle": {
    "current_phase": "menstrual",
    "cycle_day": 1,
    "days_until_next_phase": 4,
    "next_phase": "follicular"
  },
  "phase_info": { ... }
}
```

---

### GET /api/v1/cycle/history

Get past cycle entries with start dates, lengths, and notes.

**Authentication:** Required

**Query Parameters:**
- `limit` (optional, default: 12, max: 24) - Number of cycles to return

**Response:** `200 OK`
```json
{
  "cycles": [
    {
      "id": "cycle_123",
      "start_date": "2026-01-12",
      "end_date": "2026-02-08",
      "cycle_length": 27,
      "period_end_date": "2026-01-16",
      "notes": "Light flow"
    }
  ],
  "average_cycle_length": 28,
  "total_cycles_logged": 6
}
```

---

### GET /api/v1/cycle/predictions

Get predicted cycle phases for upcoming days.

**Authentication:** Required

**Query Parameters:**
- `days` (optional, default: 30, min: 7, max: 90) - Days ahead to predict

**Response:** `200 OK`
```json
{
  "predictions": [
    {
      "date": "2026-01-13",
      "phase": "menstrual",
      "cycle_day": 2
    },
    {
      "date": "2026-01-14",
      "phase": "menstrual",
      "cycle_day": 3
    }
  ],
  "next_period_start": "2026-02-09"
}
```

---

### PATCH /api/v1/cycle/history/{cycle_id}

Update a cycle entry (change dates, add notes).

**Authentication:** Required

**Request Body:**
```json
{
  "period_end_date": "2026-01-17",
  "notes": "Updated notes"
}
```

**Response:** `200 OK`
```json
{
  "id": "cycle_123",
  "start_date": "2026-01-12",
  "period_end_date": "2026-01-17",
  "notes": "Updated notes"
}
```

---

### DELETE /api/v1/cycle/history/{cycle_id}

Delete a cycle entry. Cannot delete if it's the only cycle.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Cycle deleted successfully"
}
```

## Workouts

### GET /api/v1/workouts

Get all workouts with optional filters.

**Authentication:** Required

**Query Parameters:**
- `category` (optional) - Filter by workout type (strength, pilates, yoga, etc.)
- `intensity` (optional) - Filter by intensity (low, medium, high)
- `phase` (optional) - Filter by recommended cycle phase
- `limit` (optional, default: 20, max: 50) - Number of results
- `offset` (optional, default: 0) - Pagination offset

**Response:** `200 OK`
```json
{
  "workouts": [
    {
      "id": "workout_123",
      "title": "Morning Flow Yoga",
      "description": "Gentle yoga to start your day",
      "type": "yoga",
      "duration": 30,
      "intensity": "low",
      "recommended_phases": ["menstrual", "luteal"],
      "equipment": ["yogaMat"],
      "thumbnail_url": "https://...",
      "instructor_name": "Sarah"
    }
  ],
  "total": 45,
  "has_more": true
}
```

---

### GET /api/v1/workouts/recommended

Get workouts recommended for a specific cycle phase.

**Authentication:** Required

**Query Parameters:**
- `phase` (required) - Cycle phase (menstrual, follicular, ovulatory, luteal)
- `limit` (optional, default: 4, max: 10)

**Response:** `200 OK`
```json
{
  "workouts": [ ... ],
  "total": 4,
  "has_more": false
}
```

---

### GET /api/v1/workouts/{workout_id}

Get detailed information for a single workout.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "workout": {
    "id": "workout_123",
    "title": "Morning Flow Yoga",
    "description": "Gentle yoga to start your day with mindful movement",
    "type": "yoga",
    "duration": 30,
    "intensity": "low",
    "recommended_phases": ["menstrual", "luteal"],
    "equipment": ["yogaMat"],
    "thumbnail_url": "https://...",
    "video_url": "https://vimeo.com/...",
    "instructor_name": "Sarah",
    "target_areas": ["fullBody", "flexibility"],
    "benefits": ["Reduces stress", "Improves flexibility"],
    "is_premium": false
  }
}
```

**Error:** `404 Not Found` - Workout not found

---

### POST /api/v1/workouts/history

Log a completed workout.

**Authentication:** Required

**Request Body:**
```json
{
  "workout_id": "workout_123",
  "duration_minutes": 30,
  "calories_burned": 150,
  "notes": "Felt great during this session"
}
```

**Response:** `201 Created`
```json
{
  "id": "history_123",
  "user_id": "user_123",
  "workout_id": "workout_123",
  "completed_at": "2026-01-12T10:30:00Z",
  "duration_minutes": 30,
  "calories_burned": 150,
  "cycle_phase": "follicular",
  "cycle_day": 10,
  "notes": "Felt great during this session"
}
```

---

### GET /api/v1/workouts/history/me

Get the current user's workout history.

**Authentication:** Required

**Query Parameters:**
- `limit` (optional, default: 20, max: 50)

**Response:** `200 OK`
```json
{
  "history": [
    {
      "id": "history_123",
      "workout_id": "workout_123",
      "workout_title": "Morning Flow Yoga",
      "completed_at": "2026-01-12T10:30:00Z",
      "duration_minutes": 30,
      "cycle_phase": "follicular"
    }
  ],
  "total_workouts": 42,
  "total_minutes": 1260
}
```

## Recommendations

### GET /api/v1/recommendations/today

Get AI-powered workout recommendations for today based on cycle phase, fitness level, and goals.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "daily_message": "You're in your follicular phase - a great time to build strength and try new movements.",
  "recommendations": [
    {
      "workout_title": "Lower Body Strength",
      "workout_id": "workout_456",
      "reason": "Perfect for this phase when energy is rising and you can challenge yourself with weights."
    },
    {
      "workout_title": "Power Pilates",
      "workout_id": "workout_789",
      "reason": "Builds core strength with dynamic movement that matches your current energy."
    },
    {
      "workout_title": "Vinyasa Flow",
      "workout_id": "workout_234",
      "reason": "A gentle alternative if you're feeling lower energy today."
    }
  ],
  "self_care_tip": "Notice how your energy shifts throughout the day. Stay hydrated and honor what your body needs.",
  "phase": "follicular",
  "cycle_day": 10
}
```

**Error:** `404 Not Found` - No cycle data found

---

### GET /api/v1/recommendations/phase/{phase}

Get recommendations for a specific cycle phase (for exploration).

**Authentication:** Required

**Path Parameters:**
- `phase` - One of: menstrual, follicular, ovulatory, luteal

**Query Parameters:**
- `cycle_day` (optional, default: 1) - Day within the cycle

**Response:** Same as `/recommendations/today`

**Error:** `400 Bad Request` - Invalid phase

## Energy Tracking

### POST /api/v1/energy/log

Log daily energy level (1-10 scale).

**Authentication:** Required

**Request Body:**
```json
{
  "date": "2026-01-12",
  "score": 7,
  "notes": "Felt energized in the morning"
}
```

**Response:** `200 OK`
```json
{
  "energy": {
    "id": "energy_123",
    "user_id": "user_123",
    "date": "2026-01-12",
    "score": 7,
    "notes": "Felt energized in the morning",
    "created_at": "2026-01-12T20:00:00Z"
  }
}
```

---

### GET /api/v1/energy/today

Get today's energy level if logged.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "energy": {
    "id": "energy_123",
    "date": "2026-01-12",
    "score": 7,
    "notes": "Felt energized in the morning"
  }
}
```

**Error:** `404 Not Found` - No energy logged for today

---

### GET /api/v1/energy/history

Get energy level history for the past N days.

**Authentication:** Required

**Query Parameters:**
- `days` (optional, default: 30, min: 7, max: 90)

**Response:** `200 OK`
```json
{
  "entries": [
    {
      "id": "energy_123",
      "date": "2026-01-12",
      "score": 7,
      "notes": "Felt energized"
    },
    {
      "id": "energy_122",
      "date": "2026-01-11",
      "score": 5,
      "notes": "Low energy day"
    }
  ],
  "average_score": 6.5,
  "total_logs": 25
}
```

---

### DELETE /api/v1/energy/{log_id}

Delete an energy log entry.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Energy log deleted successfully"
}
```

**Error:** `404 Not Found` - Log not found

## Common Error Responses

### 401 Unauthorized
```json
{
  "detail": "Invalid or missing authentication token"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 422 Validation Error
```json
{
  "detail": [
    {
      "loc": ["body", "score"],
      "msg": "ensure this value is less than or equal to 10",
      "type": "value_error"
    }
  ]
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

## Rate Limiting

- Rate limits apply per user (identified by Firebase token)
- Default: 100 requests per minute per user
- Headers included in response:
  - `X-RateLimit-Limit`: Max requests allowed
  - `X-RateLimit-Remaining`: Requests remaining
  - `X-RateLimit-Reset`: Unix timestamp when limit resets

## Pagination

List endpoints support pagination via `limit` and `offset` query parameters:

```http
GET /api/v1/workouts?limit=20&offset=40
```

Response includes:
- `total` - Total number of items
- `has_more` - Boolean indicating if more items exist

## Data Validation

All request bodies are validated using Pydantic models:

- Required fields must be present
- Types are strictly enforced
- Enums must match allowed values
- Dates must be in ISO 8601 format (YYYY-MM-DD)
- Email addresses must be valid format

## Versioning

The API is versioned via URL path (`/api/v1`). Breaking changes will result in a new version (`/api/v2`).

Current version: `v1`
