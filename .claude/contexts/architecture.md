# Strength Grace & Flow - Architecture Context

## System Overview

Strength Grace & Flow is a cycle-synced fitness platform for women, combining iOS native development with a Python backend and AI-powered recommendations.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App (SwiftUI)                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │  Auth    │  │  Cycle   │  │  Workout │  │  Video Player    │ │
│  │  Views   │  │  Tracker │  │  Browser │  │  & Library       │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘ │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Firebase                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │    Auth      │  │   Firestore  │  │      Storage         │   │
│  │  (Email,     │  │  (User data, │  │  (Video thumbnails,  │   │
│  │   Apple)     │  │   workouts)  │  │   profile images)    │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Railway Backend                               │
│  ┌──────────────────┐  ┌────────────────────────────────────┐   │
│  │   API Server     │  │         AI Services                │   │
│  │   (Python/       │  │  - Workout recommendations         │   │
│  │    FastAPI)      │  │  - Phase-based suggestions         │   │
│  │                  │  │  - Personalization engine          │   │
│  └──────────────────┘  └────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    External Services                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │    Vimeo     │  │    Stripe    │  │   Claude API         │   │
│  │  (Video      │  │  (Payments/  │  │   (AI recommendations│   │
│  │   hosting)   │  │   Subs)      │  │    & coaching)       │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## iOS App Architecture

### Framework: SwiftUI

The iOS app is built entirely with SwiftUI for:
- Declarative UI that's easy to modify
- Native iOS performance and feel
- Built-in accessibility and dark mode
- Easy theming for design iteration

### Project Structure

```
StrengthGraceFlow/
├── App/
│   ├── StrengthGraceFlowApp.swift      # App entry point
│   └── AppState.swift                   # Global app state
│
├── Core/
│   ├── Theme/                           # Colors, fonts, spacing
│   ├── Components/                      # Reusable UI components
│   └── Extensions/                      # Helpers
│
├── Features/
│   ├── Auth/                           # Login, SignUp, Onboarding
│   ├── CycleTracking/                  # Phase tracking, calendar
│   ├── Workouts/                       # Browse, detail, player
│   ├── Profile/                        # Settings, preferences
│   └── Recommendations/                # Today view, AI suggestions
│
├── Services/
│   ├── AuthService.swift               # Firebase Auth wrapper
│   ├── DatabaseService.swift           # Firestore wrapper
│   ├── StorageService.swift            # Firebase Storage
│   ├── APIService.swift                # Backend API calls
│   └── NotificationService.swift       # Push notifications
│
└── Models/                             # Data models
```

## Data Models

### User Model

```swift
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String?
    var profileImageURL: String?

    // Cycle-related
    var averageCycleLength: Int          // Default: 28
    var averagePeriodLength: Int         // Default: 5
    var lastPeriodStartDate: Date?
    var cycleTrackingEnabled: Bool

    // Preferences
    var preferredWorkoutTypes: [WorkoutType]
    var fitnessLevel: FitnessLevel
    var goals: [FitnessGoal]
    var notificationsEnabled: Bool

    // Subscription
    var subscriptionStatus: SubscriptionStatus
    var subscriptionExpiresAt: Date?
}
```

### Cycle Phase Model

```swift
enum CyclePhase: String, Codable, CaseIterable {
    case menstrual      // Days 1-5
    case follicular     // Days 6-13
    case ovulatory      // Days 14-16
    case luteal         // Days 17-28

    var recommendedIntensity: IntensityLevel {
        switch self {
        case .menstrual: return .low
        case .follicular: return .medium
        case .ovulatory: return .high
        case .luteal: return .medium
        }
    }

    var recommendedWorkoutTypes: [WorkoutType] {
        switch self {
        case .menstrual:
            return [.yoga, .gentleStretch, .walkingPilates]
        case .follicular:
            return [.strength, .pilates, .barre, .yoga]
        case .ovulatory:
            return [.hiitStrength, .strength, .powerPilates, .barre]
        case .luteal:
            return [.pilates, .barre, .yoga, .strength]
        }
    }
}
```

### Workout Model

```swift
struct Workout: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var type: WorkoutType
    var duration: Int                    // Minutes
    var intensity: IntensityLevel
    var phases: [CyclePhase]            // Recommended phases
    var equipment: [Equipment]
    var thumbnailURL: String
    var videoURL: String                // Vimeo URL or ID
    var instructorName: String
    var tags: [String]
    var isFeatured: Bool
    var isPremium: Bool
    var targetAreas: [TargetArea]
    var benefits: [String]
}

enum WorkoutType: String, Codable {
    case strength, hiitStrength, pilates, powerPilates
    case walkingPilates, barre, yoga, gentleStretch, meditation
}
```

## Backend Architecture (FastAPI)

### Project Structure

```
backend/
├── app/
│   ├── main.py                  # FastAPI app entry
│   ├── config/
│   │   ├── firebase.py          # Firebase Admin SDK
│   │   ├── stripe.py            # Stripe config
│   │   ├── anthropic.py         # Claude API config
│   │   └── settings.py          # Pydantic settings
│   │
│   ├── middleware/
│   │   ├── auth.py              # Firebase token verification
│   │   └── rate_limiter.py
│   │
│   ├── routers/                 # API endpoints
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── cycle.py
│   │   ├── workouts.py
│   │   ├── recommendations.py
│   │   ├── history.py
│   │   └── energy.py
│   │
│   ├── services/                # Business logic
│   │   ├── cycle_service.py
│   │   ├── recommendation_service.py
│   │   ├── workout_service.py
│   │   └── energy_service.py
│   │
│   ├── ai/                      # AI/Claude integration
│   │   ├── prompts/
│   │   │   ├── daily_recommendation.py
│   │   │   └── weekly_plan.py
│   │   └── agents/
│   │       └── coach_agent.py
│   │
│   └── models/                  # Pydantic models
│       ├── user.py
│       ├── cycle.py
│       ├── workout.py
│       └── recommendation.py
│
├── tests/
└── pyproject.toml
```

## Firestore Collections

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile: { ... }
│       ├── cycleData/
│       │   └── {cycleId}: { startDate, endDate, length, notes }
│       ├── workoutHistory/
│       │   └── {historyId}: { workoutId, completedAt, phase }
│       ├── energyLogs/
│       │   └── {logId}: { date, score, notes }
│       └── preferences: { ... }
│
├── workouts/
│   └── {workoutId}: { title, type, duration, intensity, videoURL }
│
└── programs/
    └── {programId}: { ... }
```

## AI Recommendation System

### Phase Detection Logic

```python
def calculate_current_phase(
    last_period_start: date,
    average_cycle_length: int = 28,
    average_period_length: int = 5,
) -> CycleInfo:
    today = date.today()
    days_since_start = (today - last_period_start).days
    cycle_day = (days_since_start % average_cycle_length) + 1

    # Phase boundaries (adjustable based on cycle length)
    menstrual_end = average_period_length
    follicular_end = round(average_cycle_length * 0.46)  # ~Day 13
    ovulatory_end = round(average_cycle_length * 0.57)   # ~Day 16

    if cycle_day <= menstrual_end:
        phase = CyclePhase.MENSTRUAL
    elif cycle_day <= follicular_end:
        phase = CyclePhase.FOLLICULAR
    elif cycle_day <= ovulatory_end:
        phase = CyclePhase.OVULATORY
    else:
        phase = CyclePhase.LUTEAL

    return phase, cycle_day
```

### AI Recommendation Prompt Structure

Recommendations are generated using Claude API with context including:
- Current cycle phase and day
- User's fitness level and goals
- Recent workout history
- Energy levels
- Available workouts with metadata

The AI coach provides:
- 3 ranked workout recommendations with reasons
- Phase-specific guidance message
- Self-care tip aligned with current phase
- Alternative gentle option for low energy

## Integration Patterns

### Authentication Flow

1. User signs in via Firebase Auth (Email or Apple)
2. iOS app receives Firebase ID token
3. Token sent to backend with every API request
4. Backend middleware verifies token with Firebase Admin SDK
5. User ID extracted from verified token for all operations

### Cycle Tracking Flow

1. User logs period start in iOS app
2. App calls `/api/v1/cycle/log-period`
3. Backend updates Firestore cycle data
4. Backend calculates current phase using service logic
5. iOS app receives updated cycle info
6. App UI updates to show current phase

### Workout Recommendation Flow

1. iOS app requests daily recommendations
2. Backend fetches user profile and cycle info from Firestore
3. Backend calls Claude API with structured prompt
4. AI generates personalized recommendations
5. Backend matches workout titles to IDs
6. Returns recommendations with metadata to iOS app

## Video Integration (Vimeo)

- Videos hosted on Vimeo Pro/Business account
- Privacy set to "Hide from Vimeo"
- iOS app embeds Vimeo player using WKWebView
- Video URLs stored in Firestore workout documents
- Thumbnail URLs cached for quick loading

## Subscription & Payments

### Hybrid Approach
1. StoreKit 2 for in-app purchases (primary)
2. Stripe for web subscriptions (alternative)
3. Backend validates both and syncs status

### Flow
- User initiates purchase in iOS app
- StoreKit handles transaction
- iOS app notifies backend of purchase
- Backend validates receipt and updates Firestore
- Subscription status checked on API requests

## Environment Variables

### iOS App (Xcode Config)
```
FIREBASE_API_KEY
FIREBASE_PROJECT_ID
FIREBASE_APP_ID
API_BASE_URL (Railway backend URL)
```

### Backend (Railway)
```
FIREBASE_SERVICE_ACCOUNT (JSON)
ANTHROPIC_API_KEY
STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET
VIMEO_ACCESS_TOKEN
```

## Tech Stack Summary

| Component | Technology | Purpose |
|-----------|------------|---------|
| iOS App | SwiftUI | Native iOS interface |
| Auth | Firebase Auth | Email + Apple Sign In |
| Database | Firestore | User data, workouts, history |
| File Storage | Firebase Storage | Images, thumbnails |
| Backend | Railway + FastAPI | API, AI orchestration |
| AI | Claude API | Workout recommendations |
| Video | Vimeo Pro | Workout video hosting |
| Payments | StoreKit 2 + Stripe | Subscriptions |
| Analytics | Firebase Analytics | Usage tracking |

## Development Workflow

### Local Development
1. Backend runs locally via `uvicorn` or in Railway preview
2. iOS app in Xcode simulator connects to local/preview backend
3. Firebase emulators for Auth/Firestore (optional)
4. Test API endpoints with Swagger UI at `/docs`

### Deployment
- Backend: Automatic deployment to Railway on main branch push
- iOS: Manual build and upload to TestFlight via Xcode
- Firebase: Rules and indexes deployed via Firebase CLI

## Key Design Patterns

### iOS
- MVVM architecture with SwiftUI
- Combine for reactive data flow
- Environment objects for shared state
- Repository pattern for API/Firebase access

### Backend
- Dependency injection for services
- Service layer for business logic
- Middleware for auth and error handling
- Pydantic models for validation
- Async/await throughout

## Performance Considerations

### iOS
- Lazy loading for workout lists
- Image caching with AsyncImage
- Background fetch for cycle updates
- Local caching of user preferences

### Backend
- Firestore indexes for efficient queries
- Rate limiting on expensive endpoints
- Response caching for static data
- Batched operations where possible
