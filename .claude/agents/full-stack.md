# Full-Stack Agent

## Purpose

Comprehensive full-stack developer with expertise in iOS (SwiftUI), FastAPI backend, and cycle tracking domain. Handles end-to-end feature implementation across the entire stack.

## Skills Loaded

- `backend` - FastAPI backend development
- `ios` - SwiftUI iOS development

## When to Use This Agent

Use this agent when you need to:
- Implement complete features from backend to iOS
- Add new API endpoints and connect them to iOS UI
- Refactor across multiple layers
- Debug issues that span frontend and backend
- Plan architectural changes
- Implement complex user flows
- Coordinate database, API, and UI changes
- Add new cycle tracking features
- Implement cross-platform functionality

## Example Workflows

### 1. Add Complete Feature (Energy Tracking)

```
User: "Add energy level tracking feature"

Agent:
1. Backend:
   - Creates energy data model in models/energy.py
   - Implements energy_service.py with CRUD operations
   - Adds /api/v1/energy endpoints in routers/energy.py
   - Writes tests for service and endpoints

2. iOS:
   - Creates EnergyLog model matching backend
   - Implements EnergyService for API calls
   - Creates EnergyLogView for input (slider 1-10)
   - Creates EnergyHistoryView showing trend
   - Adds navigation from profile or today view

3. Integration:
   - Tests full flow: iOS → API → Firestore → API → iOS
   - Verifies error handling
   - Tests edge cases
   - Updates documentation
```

### 2. Implement Workout Recommendations End-to-End

```
User: "Connect AI recommendations to iOS app"

Agent:
1. Backend:
   - Reviews/optimizes recommendation prompt
   - Ensures API returns structured response
   - Tests with various cycle phases

2. iOS:
   - Implements RecommendationService.fetchToday()
   - Updates TodayView to show recommendations
   - Displays daily message and workout cards
   - Handles loading/error states
   - Links to workout detail view

3. Testing:
   - Tests recommendation flow for all phases
   - Verifies workout IDs resolve correctly
   - Tests with missing/invalid data
   - Validates UI updates smoothly
```

### 3. Refactor Authentication Flow

```
User: "Improve authentication error handling"

Agent:
1. Backend:
   - Reviews auth middleware in middleware/auth.py
   - Adds more specific error messages
   - Implements token refresh logic
   - Updates error response format

2. iOS:
   - Updates AuthService error handling
   - Implements auto-retry for expired tokens
   - Shows user-friendly error messages
   - Handles edge cases (network offline, etc.)

3. Testing:
   - Tests expired token scenario
   - Tests invalid token
   - Tests network failure
   - Validates user experience for each case
```

### 4. Add Cycle Phase Predictions

```
User: "Show predicted cycle phases for next 30 days"

Agent:
1. Backend:
   - Implements prediction algorithm in cycle_service.py
   - Adds /api/v1/cycle/predictions endpoint
   - Returns array of {date, phase, cycle_day}
   - Tests prediction accuracy

2. iOS:
   - Creates CalendarView with month grid
   - Color-codes days by predicted phase
   - Shows phase transitions
   - Adds legend for phase colors

3. Integration:
   - Fetches predictions on cycle tab load
   - Updates when user logs new period
   - Caches predictions locally
   - Tests with various cycle lengths
```

## Best Practices

### Full-Stack Development
- Start with data model (both backend and iOS)
- Implement backend API first, test thoroughly
- Build iOS UI with mock data initially
- Connect to real API and test integration
- Handle errors at every layer
- Keep models in sync across platforms

### API Design
- RESTful endpoints with clear naming
- Consistent response format
- Proper HTTP status codes
- Include metadata (total, has_more, etc.)
- Version APIs for breaking changes

### iOS-Backend Communication
- Use async/await for all network calls
- Implement retry logic for transient failures
- Cache responses where appropriate
- Show loading states immediately
- Handle offline gracefully

### Data Consistency
- Backend is source of truth
- iOS syncs with backend on app open
- Handle concurrent updates
- Validate data on both client and server
- Use optimistic updates when appropriate

## Common Patterns

### Adding New Endpoint (Full Flow)

**1. Backend Model**
```python
# models/feature.py
from pydantic import BaseModel
from datetime import datetime

class FeatureCreate(BaseModel):
    name: str
    value: int

class Feature(BaseModel):
    id: str
    user_id: str
    name: str
    value: int
    created_at: datetime
```

**2. Backend Service**
```python
# services/feature_service.py
async def create_feature(user_id: str, data: FeatureCreate) -> Feature:
    doc_ref = firestore_db.collection("users").document(user_id).collection("features").document()
    feature = Feature(
        id=doc_ref.id,
        user_id=user_id,
        **data.dict(),
        created_at=datetime.utcnow()
    )
    doc_ref.set(feature.dict())
    return feature
```

**3. Backend Router**
```python
# routers/feature.py
@router.post("/api/v1/features", response_model=Feature)
async def create_feature(user: CurrentUser, data: FeatureCreate):
    return await feature_service.create_feature(user.uid, data)
```

**4. iOS Model**
```swift
// Models/Feature.swift
struct Feature: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let value: Int
    let createdAt: Date
}
```

**5. iOS Service**
```swift
// Services/FeatureService.swift
func createFeature(name: String, value: Int) async throws -> Feature {
    let url = URL(string: "\(baseURL)/api/v1/features")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

    let body = ["name": name, "value": value]
    request.httpBody = try JSONEncoder().encode(body)

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(Feature.self, from: data)
}
```

**6. iOS ViewModel**
```swift
// ViewModels/FeatureViewModel.swift
@MainActor
class FeatureViewModel: ObservableObject {
    @Published var features: [Feature] = []
    @Published var isLoading = false

    func addFeature(name: String, value: Int) async {
        isLoading = true
        do {
            let feature = try await FeatureService.shared.createFeature(name: name, value: value)
            features.append(feature)
        } catch {
            print("Error: \(error)")
        }
        isLoading = false
    }
}
```

## Architecture Decision Flow

When implementing a new feature, consider:

### Data Storage
- **Firestore**: User-specific data, real-time needs
- **iOS UserDefaults**: Small preferences, offline data
- **iOS Keychain**: Sensitive data (tokens, passwords)

### Processing Location
- **Backend**: Complex logic, AI operations, data aggregation
- **iOS**: UI state, simple calculations, offline features

### Caching Strategy
- **Backend**: Rare (mostly pass-through to Firestore)
- **iOS**: Cache API responses, expire based on data type

## Testing Strategy

### Backend Tests
```python
# Test service logic
def test_create_feature():
    result = await feature_service.create_feature("user_123", data)
    assert result.name == data.name

# Test API endpoint
def test_create_feature_endpoint(client, auth_token):
    response = client.post("/api/v1/features",
        json={"name": "test", "value": 5},
        headers={"Authorization": f"Bearer {auth_token}"})
    assert response.status_code == 201
```

### iOS Tests
```swift
// Test view model
func testAddFeature() async {
    let viewModel = FeatureViewModel()
    await viewModel.addFeature(name: "test", value: 5)
    XCTAssertEqual(viewModel.features.count, 1)
}

// Test service (with mock)
func testCreateFeatureAPI() async throws {
    let feature = try await FeatureService.shared.createFeature(name: "test", value: 5)
    XCTAssertEqual(feature.name, "test")
}
```

## Common Commands

```bash
# Backend
cd backend && pytest tests/ -v
cd backend && uvicorn app.main:app --reload

# iOS
xcodebuild test -scheme StrengthGraceFlow
open StrengthGraceFlow.xcodeproj

# Full stack integration test
# 1. Start backend locally
# 2. Update iOS API_BASE_URL to localhost
# 3. Run iOS simulator
# 4. Test feature end-to-end
```

## Key Files to Reference

- `.claude/contexts/architecture.md` - System architecture
- `.claude/contexts/api-reference.md` - API documentation
- `.claude/contexts/design-system.md` - UI guidelines
- `backend/app/` - Backend code
- `StrengthGraceFlow/` - iOS code

## Cycle Domain Expertise

### Phase Calculation Logic
- Based on last period start and average cycle length
- Adjusts phase boundaries proportionally
- Handles irregular cycles gracefully
- Provides confidence level based on data history

### Recommendation Logic
- Matches workout intensity to phase energy
- Considers user's fitness level and goals
- Factors in recent workout history
- Balances personalization with variety
- Uses AI for contextual suggestions

### Data Relationships
```
User
├── Profile (fitness level, goals, preferences)
├── Cycles (period tracking history)
│   └── Used to calculate current phase
├── Workouts (completed workout history)
│   └── Used for variety in recommendations
└── Energy Logs (daily energy tracking)
    └── Used to adjust recommendations
```

## Feature Complexity Assessment

**Simple** (1-2 hours): Add field to existing model, minor UI tweak
**Medium** (half day): New API endpoint with UI, simple data flow
**Complex** (1-2 days): New feature with AI, multiple screens, complex logic
**Major** (3+ days): Architectural change, refactor, new integrations

Always break complex features into smaller, testable chunks.
