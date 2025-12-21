# Strength Grace & Flow — Technical Architecture

## Overview

This document outlines the technical architecture for the Strength Grace & Flow iOS application, a cycle-synced fitness platform for women.

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

---

## 1. iOS App Architecture

### Framework Choice: SwiftUI

We'll use **SwiftUI** for the iOS app. This gives us:
- Declarative UI that's easy to modify as design evolves
- Native iOS feel and performance
- Easy theming/styling system for future design iterations
- Built-in support for dark mode, accessibility, etc.

### Project Structure

```
StrengthGraceFlow/
├── App/
│   ├── StrengthGraceFlowApp.swift      # App entry point
│   └── AppState.swift                   # Global app state
│
├── Core/
│   ├── Theme/
│   │   ├── Theme.swift                  # Colors, fonts, spacing
│   │   ├── Colors.swift                 # Color palette (easy to swap)
│   │   └── Typography.swift             # Font styles
│   │
│   ├── Components/                      # Reusable UI components
│   │   ├── SGFButton.swift
│   │   ├── SGFCard.swift
│   │   ├── SGFTextField.swift
│   │   └── PhaseIndicator.swift
│   │
│   └── Extensions/
│       ├── View+Extensions.swift
│       └── Date+Extensions.swift
│
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── OnboardingView.swift
│   │   └── ViewModels/
│   │       └── AuthViewModel.swift
│   │
│   ├── CycleTracking/
│   │   ├── Views/
│   │   │   ├── CycleInputView.swift
│   │   │   ├── PhaseDetailView.swift
│   │   │   └── CalendarView.swift
│   │   ├── ViewModels/
│   │   │   └── CycleViewModel.swift
│   │   └── Models/
│   │       └── CyclePhase.swift
│   │
│   ├── Workouts/
│   │   ├── Views/
│   │   │   ├── WorkoutHomeView.swift
│   │   │   ├── WorkoutListView.swift
│   │   │   ├── WorkoutDetailView.swift
│   │   │   └── WorkoutPlayerView.swift
│   │   ├── ViewModels/
│   │   │   └── WorkoutViewModel.swift
│   │   └── Models/
│   │       └── Workout.swift
│   │
│   ├── Profile/
│   │   ├── Views/
│   │   │   ├── ProfileView.swift
│   │   │   └── SettingsView.swift
│   │   └── ViewModels/
│   │       └── ProfileViewModel.swift
│   │
│   └── Recommendations/
│       ├── Views/
│       │   └── TodayView.swift
│       └── ViewModels/
│           └── RecommendationViewModel.swift
│
├── Services/
│   ├── AuthService.swift                # Firebase Auth wrapper
│   ├── DatabaseService.swift            # Firestore wrapper
│   ├── StorageService.swift             # Firebase Storage wrapper
│   ├── APIService.swift                 # Railway backend calls
│   └── NotificationService.swift        # Push notifications
│
├── Models/
│   ├── User.swift
│   ├── Workout.swift
│   ├── CycleData.swift
│   └── Subscription.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### Design System (Flexible for Future Changes)

The key to keeping design flexible is centralizing all visual decisions:

```swift
// Theme.swift - Single source of truth for all design tokens
struct Theme {
    // Your wife can tweak these values anytime
    static let colors = ThemeColors()
    static let typography = ThemeTypography()
    static let spacing = ThemeSpacing()
    static let radius = ThemeRadius()
}

struct ThemeColors {
    // Primary palette - easy to swap
    let primary = Color("Primary")           // Defined in Assets
    let secondary = Color("Secondary")
    let background = Color("Background")
    let surface = Color("Surface")
    let text = Color("Text")
    let textSecondary = Color("TextSecondary")
    
    // Phase colors - can be customized per phase
    let menstrual = Color("PhaseMenstrual")
    let follicular = Color("PhaseFollicular")
    let ovulatory = Color("PhaseOvulatory")
    let luteal = Color("PhaseLuteal")
}

struct ThemeTypography {
    let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    let headline = Font.system(size: 17, weight: .semibold)
    let body = Font.system(size: 17, weight: .regular)
    let caption = Font.system(size: 12, weight: .regular)
}
```

---

## 2. Data Models

### Firestore Collections Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile: { ... }
│       ├── cycleData/
│       │   └── {cycleId}: { ... }
│       ├── workoutHistory/
│       │   └── {historyId}: { ... }
│       └── preferences: { ... }
│
├── workouts/
│   └── {workoutId}: { ... }
│
├── programs/
│   └── {programId}: { ... }
│
└── subscriptions/
    └── {userId}: { ... }
```

### User Model

```swift
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String?
    var profileImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
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
    var preferredWorkoutTime: Date?
    
    // Subscription
    var subscriptionStatus: SubscriptionStatus
    var subscriptionExpiresAt: Date?
}

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}

enum FitnessGoal: String, Codable, CaseIterable {
    case buildStrength
    case improveFlexibility
    case reduceStress
    case postpartumRecovery
    case hormoneBalance
    case consistency
}

enum SubscriptionStatus: String, Codable {
    case none
    case trial
    case active
    case expired
    case cancelled
}
```

### Cycle Data Model

```swift
struct CycleData: Codable, Identifiable {
    let id: String
    let userId: String
    var startDate: Date                  // First day of period
    var endDate: Date?                   // First day of next period (when known)
    var periodEndDate: Date?             // Last day of bleeding
    var cycleLength: Int?                // Calculated when cycle completes
    var notes: String?
    var symptoms: [Symptom]?
    var createdAt: Date
}

enum CyclePhase: String, Codable, CaseIterable {
    case menstrual      // Days 1-5 (approx)
    case follicular     // Days 6-13 (approx)
    case ovulatory      // Days 14-16 (approx)
    case luteal         // Days 17-28 (approx)
    
    var displayName: String {
        switch self {
        case .menstrual: return "Menstrual"
        case .follicular: return "Follicular"
        case .ovulatory: return "Ovulatory"
        case .luteal: return "Luteal"
        }
    }
    
    var description: String {
        switch self {
        case .menstrual:
            return "Rest and restore. Honor lower energy with gentle movement."
        case .follicular:
            return "Energy is rising. Great time to try new things and build strength."
        case .ovulatory:
            return "Peak energy. Embrace challenging workouts and social movement."
        case .luteal:
            return "Winding down. Focus on steady, grounding practices."
        }
    }
    
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

enum IntensityLevel: String, Codable {
    case low
    case medium
    case high
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
    var phases: [CyclePhase]             // Which phases this is good for
    var equipment: [Equipment]
    var thumbnailURL: String
    var videoURL: String                 // Vimeo URL or ID
    var instructorName: String
    var tags: [String]
    var isFeatured: Bool
    var isPremium: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // For filtering/recommendations
    var targetAreas: [TargetArea]
    var benefits: [String]
}

enum WorkoutType: String, Codable, CaseIterable {
    case strength
    case hiitStrength
    case pilates
    case powerPilates
    case walkingPilates
    case barre
    case yoga
    case gentleStretch
    case meditation
    
    var displayName: String {
        switch self {
        case .strength: return "Strength"
        case .hiitStrength: return "HIIT Strength"
        case .pilates: return "Pilates"
        case .powerPilates: return "Power Pilates"
        case .walkingPilates: return "Walking Pilates"
        case .barre: return "Barre"
        case .yoga: return "Yoga"
        case .gentleStretch: return "Gentle Stretch"
        case .meditation: return "Meditation"
        }
    }
}

enum Equipment: String, Codable, CaseIterable {
    case none
    case dumbbells
    case resistanceBands
    case yogaMat
    case pilatesRing
    case kettlebell
    case barreOrChair
}

enum TargetArea: String, Codable, CaseIterable {
    case fullBody
    case upperBody
    case lowerBody
    case core
    case glutes
    case arms
    case back
}
```

### Workout History Model

```swift
struct WorkoutHistory: Codable, Identifiable {
    let id: String
    let userId: String
    let workoutId: String
    var completedAt: Date
    var duration: Int                    // Actual time spent
    var cyclePhase: CyclePhase?          // Phase when completed
    var cycleDay: Int?
    var rating: Int?                     // 1-5 stars
    var energyBefore: EnergyLevel?
    var energyAfter: EnergyLevel?
    var notes: String?
}

enum EnergyLevel: Int, Codable, CaseIterable {
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5
}
```

---

## 3. Authentication Flow

### Supported Auth Methods
1. **Email/Password** — Standard sign up/login
2. **Sign in with Apple** — Required for App Store if you have any third-party auth

### Auth Flow Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Launch    │────▶│  Check Auth │────▶│  Logged In? │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │ NO                       │                     YES  │
                    ▼                          │                          ▼
            ┌───────────────┐                  │                  ┌───────────────┐
            │   Welcome/    │                  │                  │    Check      │
            │   Onboarding  │                  │                  │   Profile     │
            └───────┬───────┘                  │                  └───────┬───────┘
                    │                          │                          │
        ┌───────────┼───────────┐              │              ┌───────────┼───────────┐
        ▼           ▼           ▼              │              ▼                       ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐        │      ┌─────────────┐         ┌─────────────┐
   │  Sign   │ │  Sign   │ │  Apple  │        │      │  Complete?  │         │  Incomplete │
   │   Up    │ │   In    │ │  Auth   │        │      │    YES      │         │   Profile   │
   └────┬────┘ └────┬────┘ └────┬────┘        │      └──────┬──────┘         └──────┬──────┘
        │           │           │              │             │                       │
        └───────────┴───────────┴──────────────┘             │                       │
                                                             ▼                       ▼
                                                     ┌───────────────┐       ┌───────────────┐
                                                     │   Main App    │       │   Complete    │
                                                     │   (Home)      │◀──────│   Onboarding  │
                                                     └───────────────┘       └───────────────┘
```

### Onboarding Data Collection

After authentication, collect:
1. Display name
2. Fitness level (beginner/intermediate/advanced)
3. Goals (multi-select)
4. Preferred workout types
5. Cycle information:
   - Last period start date
   - Average cycle length (or use default 28)
   - Average period length (or use default 5)
6. Notification preferences

---

## 4. Railway Backend Architecture

### API Endpoints

```
Base URL: https://your-app.railway.app/api/v1

Authentication:
  POST   /auth/verify              # Verify Firebase token

Users:
  GET    /users/me                 # Get current user profile
  PATCH  /users/me                 # Update profile
  DELETE /users/me                 # Delete account

Cycle:
  GET    /cycle/current            # Get current cycle info + phase
  POST   /cycle/log-period         # Log period start
  GET    /cycle/history            # Get cycle history
  GET    /cycle/predictions        # Get predicted upcoming phases

Workouts:
  GET    /workouts                 # List all workouts (with filters)
  GET    /workouts/:id             # Get workout details
  GET    /workouts/featured        # Get featured workouts
  GET    /workouts/phase/:phase    # Get workouts for specific phase

Recommendations:
  GET    /recommendations/today    # AI-powered daily recommendations
  GET    /recommendations/week     # Weekly workout plan
  POST   /recommendations/refresh  # Regenerate recommendations

History:
  GET    /history                  # Get workout history
  POST   /history                  # Log completed workout
  GET    /history/stats            # Get stats and streaks

Subscriptions:
  GET    /subscriptions/status     # Check subscription status
  POST   /subscriptions/webhook    # Stripe webhook handler
```

### Backend Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI app entry
│   ├── config/
│   │   ├── __init__.py
│   │   ├── firebase.py          # Firebase Admin SDK init
│   │   ├── stripe.py            # Stripe config
│   │   ├── anthropic.py         # Claude API config
│   │   └── settings.py          # Pydantic settings
│   │
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth.py              # Firebase token verification
│   │   └── rate_limiter.py
│   │
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── cycle.py
│   │   ├── workouts.py
│   │   ├── recommendations.py
│   │   ├── history.py
│   │   └── subscriptions.py
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── cycle_service.py     # Cycle phase calculations
│   │   ├── recommendation_service.py  # AI recommendation logic
│   │   ├── workout_service.py
│   │   └── subscription_service.py
│   │
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── prompts/
│   │   │   ├── __init__.py
│   │   │   ├── daily_recommendation.py
│   │   │   └── weekly_plan.py
│   │   └── agents/
│   │       ├── __init__.py
│   │       └── coach_agent.py   # Claude-powered coaching
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py              # Pydantic models
│   │   ├── cycle.py
│   │   ├── workout.py
│   │   └── recommendation.py
│   │
│   └── utils/
│       ├── __init__.py
│       ├── cycle_calculations.py
│       └── helpers.py
│
├── tests/
│   ├── __init__.py
│   ├── test_cycle.py
│   └── test_recommendations.py
│
├── pyproject.toml
├── requirements.txt
├── Dockerfile
└── railway.toml
```

---

## 5. AI Recommendation System

### How Phase Detection Works

```python
# cycle_calculations.py

from datetime import date
from enum import Enum
from typing import Literal
from pydantic import BaseModel


class CyclePhase(str, Enum):
    MENSTRUAL = "menstrual"
    FOLLICULAR = "follicular"
    OVULATORY = "ovulatory"
    LUTEAL = "luteal"


class CycleInfo(BaseModel):
    current_phase: CyclePhase
    cycle_day: int
    days_until_next_phase: int
    next_phase: CyclePhase
    confidence: Literal["high", "medium", "low"]


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
        days_until_next = menstrual_end - cycle_day + 1
        next_phase = CyclePhase.FOLLICULAR
    elif cycle_day <= follicular_end:
        phase = CyclePhase.FOLLICULAR
        days_until_next = follicular_end - cycle_day + 1
        next_phase = CyclePhase.OVULATORY
    elif cycle_day <= ovulatory_end:
        phase = CyclePhase.OVULATORY
        days_until_next = ovulatory_end - cycle_day + 1
        next_phase = CyclePhase.LUTEAL
    else:
        phase = CyclePhase.LUTEAL
        days_until_next = average_cycle_length - cycle_day + 1
        next_phase = CyclePhase.MENSTRUAL

    confidence = "high" if days_since_start < average_cycle_length * 2 else "medium"

    return CycleInfo(
        current_phase=phase,
        cycle_day=cycle_day,
        days_until_next_phase=days_until_next,
        next_phase=next_phase,
        confidence=confidence,
    )
```

### AI Recommendation Prompt Structure

```python
# prompts/daily_recommendation.py

from dataclasses import dataclass
from typing import Optional


@dataclass
class RecommendationContext:
    cycle_phase: str
    cycle_day: int
    fitness_level: str
    goals: list[str]
    preferred_types: list[str]
    recent_workouts: list[dict]
    available_workouts: list[dict]
    energy_level: Optional[str] = None


def build_daily_recommendation_prompt(context: RecommendationContext) -> str:
    goals_str = ", ".join(context.goals)
    preferred_types_str = ", ".join(context.preferred_types)
    recent_workouts_str = ", ".join(w["type"] for w in context.recent_workouts)

    workouts_list = "\n".join(
        f"- {w['id']}: {w['title']} ({w['type']}, {w['duration']}min, {w['intensity']})"
        for w in context.available_workouts
    )

    return f"""
You are a supportive women's fitness coach for Strength Grace & Flow, a cycle-synced movement platform.

## User Context
- Current Phase: {context.cycle_phase} (Day {context.cycle_day} of cycle)
- Fitness Level: {context.fitness_level}
- Goals: {goals_str}
- Preferred Workout Types: {preferred_types_str}
- Recent Workouts: {recent_workouts_str}
- Energy Level Today: {context.energy_level or 'Not specified'}

## Available Workouts
{workouts_list}

## Your Task
Recommend 3 workouts for today, ranked by how well they fit this user's current phase and needs.

For each recommendation, explain briefly why it's a good fit for their current phase.

Keep your tone warm, supportive, and grounded—never pushy or performative.

Respond in JSON format:
{{
  "recommendations": [
    {{
      "workoutId": "...",
      "reason": "...",
      "priority": 1
    }}
  ],
  "phaseGuidance": "A brief, supportive message about movement during this phase",
  "alternativeIfLowEnergy": "workoutId for a gentler option"
}}
"""
```

---

## 6. Video Integration (Vimeo)

### Vimeo Setup
1. Create a Vimeo Pro or Business account (needed for privacy controls)
2. Upload videos with "Hide from Vimeo" privacy setting
3. Use Vimeo's native player SDK in the iOS app

### Video Player Implementation

```swift
// WorkoutPlayerView.swift
import SwiftUI
import WebKit

struct WorkoutPlayerView: View {
    let workout: Workout
    @StateObject private var viewModel: WorkoutPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Vimeo embed player
            VimeoPlayerView(videoId: workout.vimeoId)
                .aspectRatio(16/9, contentMode: .fit)
            
            // Workout info and controls
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacing.md) {
                    Text(workout.title)
                        .font(Theme.typography.title)
                    
                    Text(workout.description)
                        .font(Theme.typography.body)
                        .foregroundColor(Theme.colors.textSecondary)
                    
                    // Duration, intensity, equipment tags
                    WorkoutMetadataView(workout: workout)
                }
                .padding()
            }
        }
        .onDisappear {
            viewModel.logWorkoutCompletion()
        }
    }
}

// Simple Vimeo embed using WKWebView
struct VimeoPlayerView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { margin: 0; background: black; }
                iframe { width: 100%; height: 100%; }
            </style>
        </head>
        <body>
            <iframe src="https://player.vimeo.com/video/\(videoId)?autoplay=1"
                    frameborder="0"
                    allow="autoplay; fullscreen"
                    allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}
```

---

## 7. Subscription & Payments (Stripe + StoreKit)

For iOS, you have two options:

### Option A: Apple In-App Purchases (Required for App Store)
If users subscribe within the app, Apple requires you use their IAP system (and takes 15-30% cut).

### Option B: Web-Based Stripe (No Apple Cut)
Users can subscribe via your website, and the app checks their subscription status. Apple allows this but you cannot link to your website from within the app for purchases.

### Recommended Hybrid Approach
1. Use **StoreKit 2** for in-app purchases (simplest for users)
2. Also support web subscriptions via Stripe for users who prefer that
3. Backend validates both and syncs subscription status

```swift
// SubscriptionService.swift
import StoreKit

class SubscriptionService: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus = .none
    @Published var availableProducts: [Product] = []
    
    private let productIds = [
        "com.strengthgraceflow.monthly",
        "com.strengthgraceflow.yearly"
    ]
    
    func loadProducts() async {
        do {
            availableProducts = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction
        case .pending:
            return nil
        case .userCancelled:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    subscriptionStatus = .active
                    return
                }
            }
        }
        subscriptionStatus = .none
    }
}
```

---

## 8. Apple Developer Account & TestFlight Setup

### Step 1: Enroll in Apple Developer Program

1. Go to [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll)
2. Sign in with your Apple ID (or create one)
3. Choose **Individual** enrollment ($99/year)
4. Complete identity verification (may take 24-48 hours)

### Step 2: Xcode Setup

1. Install Xcode from the Mac App Store
2. Open Xcode → Preferences → Accounts
3. Add your Apple ID
4. Your team should appear after enrollment completes

### Step 3: Create App ID & Provisioning

1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. Certificates, Identifiers & Profiles → Identifiers
3. Create new App ID:
   - Platform: iOS
   - Bundle ID: `com.strengthgraceflow.app` (or similar)
   - Enable capabilities: Push Notifications, Sign in with Apple

### Step 4: App Store Connect Setup

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. My Apps → "+" → New App
3. Fill in:
   - Platform: iOS
   - Name: Strength Grace & Flow
   - Primary Language: English
   - Bundle ID: Select the one you created
   - SKU: `strengthgraceflow-ios-1`

### Step 5: TestFlight Distribution

```
Development Flow:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Develop   │────▶│   Archive   │────▶│   Upload    │────▶│  TestFlight │
│   in Xcode  │     │   Build     │     │  to ASC     │     │   Testing   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

To upload a build:
1. In Xcode: Product → Archive
2. Window → Organizer → Select archive → Distribute App
3. Choose "App Store Connect" → Upload
4. Wait for processing (10-30 minutes)
5. In App Store Connect → TestFlight → Add testers
```

### TestFlight Testing Groups

1. **Internal Testers**: Up to 100 people from your App Store Connect team
   - Builds available immediately after processing
   - No review required
   
2. **External Testers**: Up to 10,000 people via email/public link
   - First build requires Beta App Review (1-2 days)
   - Great for beta launch

### Step 6: Required Before App Store Submission

Before you can submit to the App Store, you'll need:

- [ ] App icon (1024x1024)
- [ ] Screenshots for various device sizes
- [ ] Privacy policy URL
- [ ] App description and keywords
- [ ] Age rating questionnaire
- [ ] If using Sign in with Apple: properly configured
- [ ] If using subscriptions: configured in App Store Connect

---

## 9. Development Phases

### Phase 1: Foundation (Weeks 1-2)
- [ ] Set up Xcode project with SwiftUI
- [ ] Configure Firebase (Auth, Firestore, Storage)
- [ ] Implement authentication (Email + Apple Sign In)
- [ ] Create basic navigation structure
- [ ] Set up Railway backend with basic endpoints

### Phase 2: Core Features (Weeks 3-4)
- [ ] User onboarding flow
- [ ] Cycle tracking input and phase calculation
- [ ] Basic workout listing and filtering
- [ ] Workout detail view
- [ ] Video player integration (Vimeo)

### Phase 3: Recommendations (Weeks 5-6)
- [ ] Connect to Claude API for recommendations
- [ ] Build "Today" view with daily recommendations
- [ ] Implement workout history logging
- [ ] Add phase-based workout filtering

### Phase 4: Polish & Subscriptions (Weeks 7-8)
- [ ] StoreKit integration for subscriptions
- [ ] Paywall implementation
- [ ] Push notifications
- [ ] Profile and settings screens
- [ ] UI polish and your wife's design input

### Phase 5: Beta Launch (Week 9+)
- [ ] TestFlight internal testing
- [ ] Fix bugs and iterate
- [ ] External beta with founding members
- [ ] Prepare App Store submission

---

## 10. Environment Variables & Secrets

### iOS App (stored in Xcode configuration)
```
FIREBASE_API_KEY=xxx
FIREBASE_PROJECT_ID=strength-grace-flow
FIREBASE_APP_ID=xxx
API_BASE_URL=https://your-app.railway.app
VIMEO_ACCESS_TOKEN=xxx (if using private videos)
```

### Railway Backend
```
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
ANTHROPIC_API_KEY=sk-ant-xxx
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
VIMEO_ACCESS_TOKEN=xxx
```

---

## Quick Reference: Tech Stack Summary

| Component | Technology | Purpose |
|-----------|------------|---------|
| iOS App | SwiftUI | Native iOS interface |
| Auth | Firebase Auth | Email + Apple Sign In |
| Database | Firestore | User data, workouts, history |
| File Storage | Firebase Storage | Thumbnails, profile images |
| Backend | Railway + FastAPI (Python) | API, AI orchestration |
| AI | Claude API | Workout recommendations |
| Video | Vimeo | Workout video hosting |
| Payments | StoreKit 2 + Stripe | Subscriptions |
| Analytics | Firebase Analytics | Usage tracking |
