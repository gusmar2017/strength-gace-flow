# Strength Grace & Flow — Implementation Guide

## Overview

This document breaks down the implementation of Strength Grace & Flow into concrete phases with specific tasks, dependencies, and milestones. Each phase builds on the previous one.

**Timeline Estimate:** 10-12 weeks to MVP beta launch

---

## Phase 0: Project Infrastructure Setup
**Duration:** 1-2 days  
**Goal:** All accounts, projects, and local development environment ready

### 0.1 Firebase Project Setup

1. **Go to [Firebase Console](https://console.firebase.google.com)**

2. **Create New Project**
   - Click "Add project"
   - Project name: `strength-grace-flow`
   - Enable Google Analytics (optional, but useful)
   - Select or create Analytics account
   - Click "Create project"

3. **Enable Authentication**
   - In Firebase Console → Build → Authentication
   - Click "Get started"
   - Enable providers:
     - Email/Password (click, enable, save)
     - Apple (requires Apple Developer account - can do later)

4. **Create Firestore Database**
   - Build → Firestore Database
   - Click "Create database"
   - Start in **test mode** (we'll add rules later)
   - Select region: `us-central1` (or closest to your users)

5. **Enable Storage**
   - Build → Storage
   - Click "Get started"
   - Start in test mode
   - Same region as Firestore

6. **Get Configuration Keys**
   - Project Settings (gear icon) → General
   - Scroll to "Your apps" → Click iOS icon
   - Register app:
     - iOS bundle ID: `com.strengthgraceflow.app`
     - App nickname: `SGF iOS`
     - Skip App Store ID for now
   - Download `GoogleService-Info.plist` (save for later)
   - Also note the web config (for backend):
     ```
     apiKey: "xxx"
     authDomain: "strength-grace-flow.firebaseapp.com"
     projectId: "strength-grace-flow"
     storageBucket: "strength-grace-flow.appspot.com"
     messagingSenderId: "xxx"
     appId: "xxx"
     ```

7. **Generate Service Account Key (for backend)**
   - Project Settings → Service accounts
   - Click "Generate new private key"
   - Save JSON file securely (never commit to git)

### 0.2 Railway Project Setup

1. **Go to [Railway Dashboard](https://railway.app/dashboard)**

2. **Create New Project**
   - Click "New Project"
   - Select "Empty Project"
   - Name it: `strength-grace-flow`

3. **Add Backend Service**
   - In the project, click "New"
   - Select "GitHub Repo" (after we push code) OR "Empty Service" for now
   - Name the service: `api`

4. **Configure Environment Variables** (do after backend code exists)
   - Click on the service → Variables
   - Add variables (we'll populate these as we go):
     ```
     NODE_ENV=production
     PORT=3000
     FIREBASE_SERVICE_ACCOUNT={"type":"service_account"...}
     ANTHROPIC_API_KEY=sk-ant-xxx
     ```

5. **Note the Service URL**
   - Settings → Networking → Generate Domain
   - You'll get something like: `sgf-api-production.up.railway.app`

### 0.3 Apple Developer Account (if not done)

1. **Enroll at [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll)**
   - $99/year
   - Identity verification takes 24-48 hours

2. **While waiting, you can still:**
   - Develop on simulator
   - Build the entire app
   - Just can't deploy to TestFlight until approved

### 0.4 Local Development Setup

```bash
# Clone the repo
git clone https://github.com/gusmar2017/strength-gace-flow.git
cd strength-gace-flow

# Set up Python virtual environment (backend)
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..

# Install Firebase CLI
npm install -g firebase-tools
firebase login
firebase use strength-grace-flow

# Copy environment template
cp backend/.env.example backend/.env
# Edit .env with your actual values

# Verify Xcode is installed
xcode-select --install  # if needed
```

### 0.5 Vimeo Account Setup

1. **Create Vimeo Pro or Business account** (needed for privacy controls)
   - Go to [vimeo.com](https://vimeo.com)
   - Upgrade to Pro ($20/mo) or Business ($50/mo)

2. **Get API Access Token**
   - Go to [developer.vimeo.com](https://developer.vimeo.com)
   - Create new app
   - Generate access token with `private` and `video_files` scopes
   - Save token for backend .env

### Phase 0 Checklist
- [ ] Firebase project created
- [ ] Firebase Auth enabled (Email/Password)
- [ ] Firestore database created
- [ ] Firebase Storage enabled
- [ ] GoogleService-Info.plist downloaded
- [ ] Firebase service account JSON downloaded
- [ ] Railway project created
- [ ] Railway service created
- [ ] Apple Developer enrollment started
- [ ] Local repo cloned and dependencies installed
- [ ] Vimeo account set up (can defer if not ready to upload videos)

---

## Phase 1: Backend Foundation
**Duration:** 1 week
**Goal:** API server running with auth middleware and basic endpoints

### 1.1 Backend Project Structure

Create the following structure:

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI app entry
│   ├── config/
│   │   ├── __init__.py
│   │   ├── firebase.py          # Firebase Admin init
│   │   └── settings.py          # Pydantic settings
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth.py              # Firebase token verification
│   │   └── logging.py           # Request logging
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── health.py            # Health check endpoint
│   │   ├── users.py             # User profile endpoints
│   │   └── cycle.py             # Cycle tracking endpoints
│   ├── services/
│   │   ├── __init__.py
│   │   ├── user_service.py      # User CRUD operations
│   │   └── cycle_service.py     # Cycle phase calculations
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py              # Pydantic models
│   │   └── cycle.py
│   └── utils/
│       ├── __init__.py
│       └── cycle_calculations.py # Phase detection logic
├── tests/
│   └── __init__.py
├── pyproject.toml
├── requirements.txt
├── Dockerfile
├── railway.toml
└── .env.example
```

### 1.2 Core Backend Tasks

**Task 1.2.1: FastAPI Server Setup**
- Initialize FastAPI application
- Add CORS middleware
- Create health check endpoint at `GET /api/health`
- Set up exception handlers

**Task 1.2.2: Firebase Admin Integration**
- Initialize Firebase Admin SDK with service account
- Create auth dependency that verifies Firebase ID tokens
- Test with a simple protected endpoint

**Task 1.2.3: User Endpoints**
```
GET  /api/v1/users/me          # Get current user profile
POST /api/v1/users/me          # Create user profile (on first login)
PATCH /api/v1/users/me         # Update user profile
```

**Task 1.2.4: Cycle Endpoints**
```
GET  /api/v1/cycle/current     # Get current phase info
POST /api/v1/cycle/log-period  # Log period start date
GET  /api/v1/cycle/history     # Get past cycles
```

**Task 1.2.5: Cycle Phase Calculation**
- Implement phase detection algorithm
- Calculate: current phase, cycle day, days until next phase
- Handle edge cases (no period logged, irregular cycles)

### 1.3 Deploy to Railway

**Task 1.3.1: Create Dockerfile**
```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Task 1.3.2: Configure Railway**
- Connect GitHub repo to Railway service
- Set environment variables in Railway dashboard
- Verify deployment and health check

### Phase 1 Deliverables
- [ ] FastAPI server running locally
- [ ] Firebase Admin SDK connected
- [ ] Auth dependency working
- [ ] User CRUD endpoints functional
- [ ] Cycle phase calculation working
- [ ] Deployed to Railway
- [ ] Health check passing in production

### Phase 1 API Test Checklist
```bash
# Health check
curl https://your-app.railway.app/api/health

# View API docs (FastAPI auto-generates these)
open https://your-app.railway.app/docs

# Create user (with Firebase token)
curl -X POST https://your-app.railway.app/api/v1/users/me \
  -H "Authorization: Bearer <firebase_token>" \
  -H "Content-Type: application/json" \
  -d '{"display_name": "Test User"}'

# Get current cycle phase
curl https://your-app.railway.app/api/v1/cycle/current \
  -H "Authorization: Bearer <firebase_token>"
```

---

## Phase 2: iOS App Foundation
**Duration:** 1.5 weeks  
**Goal:** iOS app with auth, onboarding, and basic navigation

### 2.1 Xcode Project Setup

**Task 2.1.1: Create Xcode Project**
- File → New → Project → iOS App
- Product Name: `StrengthGraceFlow`
- Organization Identifier: `com.strengthgraceflow`
- Interface: SwiftUI
- Language: Swift
- Include Tests: Yes

**Task 2.1.2: Add Firebase SDK**
- File → Add Package Dependencies
- Enter: `https://github.com/firebase/firebase-ios-sdk`
- Select: FirebaseAuth, FirebaseFirestore, FirebaseStorage, FirebaseAnalytics

**Task 2.1.3: Configure Firebase**
- Drag `GoogleService-Info.plist` into project
- Initialize Firebase in App file:
  ```swift
  import Firebase
  
  @main
  struct StrengthGraceFlowApp: App {
      init() {
          FirebaseApp.configure()
      }
  }
  ```

**Task 2.1.4: Set Up Theme System**
- Create `Theme/` folder
- Add `SGFTheme.swift` with colors, typography, spacing
- Create Color assets in Assets.xcassets

### 2.2 Authentication

**Task 2.2.1: Auth Service**
- Create `AuthService.swift` as ObservableObject
- Implement: signUp, signIn, signOut, resetPassword
- Handle auth state changes

**Task 2.2.2: Auth Views**
- `WelcomeView` — App intro with sign in/sign up buttons
- `SignInView` — Email/password login
- `SignUpView` — Create account form
- `ForgotPasswordView` — Password reset

**Task 2.2.3: Auth State Management**
- Create `AuthViewModel` to manage auth state
- Root view switches between Auth flow and Main app based on auth state

### 2.3 Onboarding Flow

**Task 2.3.1: Onboarding Views**
After sign up, collect:
1. `OnboardingNameView` — Display name
2. `OnboardingGoalsView` — Fitness goals (multi-select)
3. `OnboardingLevelView` — Fitness level (beginner/intermediate/advanced)
4. `OnboardingCycleView` — Last period date, average cycle length
5. `OnboardingNotificationsView` — Push notification permission

**Task 2.3.2: Persist Onboarding Data**
- Save to Firestore via backend API
- Mark profile as complete
- Navigate to main app

### 2.4 Main Navigation Structure

**Task 2.4.1: Tab Bar Setup**
```swift
TabView {
    TodayView()
        .tabItem { Label("Today", systemImage: "sun.horizon.fill") }
    
    WorkoutsView()
        .tabItem { Label("Workouts", systemImage: "figure.pilates") }
    
    CycleView()
        .tabItem { Label("Cycle", systemImage: "moon.circle.fill") }
    
    ProfileView()
        .tabItem { Label("Profile", systemImage: "person.fill") }
}
```

**Task 2.4.2: Placeholder Views**
- Create basic placeholder for each tab
- TodayView shows "Welcome, [Name]" and current phase
- Other views show "Coming soon"

### 2.5 API Service Layer

**Task 2.5.1: Create APIService**
- Base URL configuration (dev vs prod)
- Automatic Firebase token injection
- Generic request/response handling
- Error handling and retry logic

**Task 2.5.2: Connect to Backend**
- Fetch current cycle phase on app launch
- Display phase on Today screen

### Phase 2 Deliverables
- [ ] Xcode project created and configured
- [ ] Firebase SDK integrated
- [ ] Theme system implemented
- [ ] Sign up / Sign in working
- [ ] Onboarding flow complete
- [ ] Main tab navigation working
- [ ] API service connecting to backend
- [ ] Current phase displaying on Today screen

---

## Phase 3: Workout Library
**Duration:** 1.5 weeks  
**Goal:** Browse and play workout videos

### 3.1 Backend: Workout Endpoints

**Task 3.1.1: Workout Data Model**
- Define Firestore schema for workouts
- Seed database with test workout data

**Task 3.1.2: Workout API Endpoints**
```
GET  /api/v1/workouts              # List all (with filters)
GET  /api/v1/workouts/:id          # Get single workout
GET  /api/v1/workouts/featured     # Featured workouts
GET  /api/v1/workouts/phase/:phase # Workouts for specific phase
```

**Task 3.1.3: Filtering & Sorting**
- Filter by: type, duration, intensity, phase, equipment
- Sort by: newest, popular, duration

### 3.2 iOS: Workout Browsing

**Task 3.2.1: Workout List View**
- Fetch workouts from API
- Display as scrollable grid (2 columns)
- Show thumbnail, title, duration, type

**Task 3.2.2: Workout Filtering**
- Filter chips at top (type, duration, intensity)
- Phase-based quick filter

**Task 3.2.3: Workout Detail View**
- Full workout info
- Play button
- Equipment needed
- "Best for" phase badges

### 3.3 Video Playback

**Task 3.3.1: Vimeo Integration**
- Embed Vimeo player in WorkoutPlayerView
- Handle play/pause/seek
- Track watch progress

**Task 3.3.2: Workout Completion**
- Detect when video ends (or user marks complete)
- Log to workout history

### 3.4 Workout History

**Task 3.4.1: Backend History Endpoints**
```
POST /api/v1/history               # Log completed workout
GET  /api/v1/history               # Get user's history
GET  /api/v1/history/stats         # Get stats (streak, total, etc.)
```

**Task 3.4.2: iOS History Tracking**
- Save completed workouts
- Show "Recently Completed" on Today screen

### Phase 3 Deliverables
- [ ] Workout API endpoints working
- [ ] Test workout data in Firestore
- [ ] Workout grid displaying in app
- [ ] Filtering functional
- [ ] Workout detail view complete
- [ ] Video player working
- [ ] Workout completion logging

---

## Phase 4: AI Recommendations
**Duration:** 1 week  
**Goal:** Personalized daily workout recommendations

### 4.1 Backend: Claude Integration

**Task 4.1.1: Anthropic SDK Setup**
- Install `anthropic` Python package
- Create recommendation service

**Task 4.1.2: Recommendation Prompt Engineering**
- Build context: user profile, current phase, history, preferences
- Craft prompt for warm, supportive tone
- Parse Claude response into structured recommendations

**Task 4.1.3: Recommendation Endpoint**
```
GET /api/v1/recommendations/today   # Get today's recommendations
```

### 4.2 iOS: Today Screen Enhancement

**Task 4.2.1: Today View Redesign**
- Current phase card with guidance
- "Recommended for You" section
- Quick access to recommended workouts

**Task 4.2.2: Phase Guidance**
- Display phase-specific tips
- Show recommended intensity level
- Gentle, supportive messaging

### Phase 4 Deliverables
- [ ] Claude API integrated in backend
- [ ] Recommendation prompt refined
- [ ] Today screen showing personalized recommendations
- [ ] Phase-specific guidance displaying

---

## Phase 5: Cycle Tracking UI
**Duration:** 1 week  
**Goal:** Full cycle tracking experience

### 5.1 Cycle Tab Features

**Task 5.1.1: Phase Overview**
- Visual cycle wheel/timeline
- Current position highlighted
- Days until next phase

**Task 5.1.2: Log Period**
- "Log Period Start" button
- Date picker (defaults to today)
- Confirmation and phase recalculation

**Task 5.1.3: Cycle History**
- Past cycles list
- Average cycle length display
- Trend insights (if enough data)

### 5.2 Calendar View

**Task 5.2.1: Monthly Calendar**
- Show current month
- Color-code days by predicted phase
- Mark period days
- Mark workout days

### Phase 5 Deliverables
- [ ] Cycle tab fully functional
- [ ] Period logging working
- [ ] Phase visualization complete
- [ ] Calendar view implemented

---

## Phase 6: Profile & Settings
**Duration:** 0.5 weeks  
**Goal:** User can manage their profile and preferences

### 6.1 Profile Screen

**Task 6.1.1: Profile Display**
- Profile photo (optional)
- Display name
- Member since date
- Workout stats summary

**Task 6.1.2: Edit Profile**
- Update name, photo
- Update fitness level
- Update goals

### 6.2 Settings

**Task 6.2.1: Settings Options**
- Notification preferences
- Cycle settings (average length)
- Account management (email, password)
- Sign out
- Delete account

### Phase 6 Deliverables
- [ ] Profile screen complete
- [ ] Edit profile working
- [ ] Settings functional
- [ ] Sign out working

---

## Phase 7: Subscriptions
**Duration:** 1 week  
**Goal:** Paywall and subscription management

### 7.1 StoreKit Integration

**Task 7.1.1: Configure App Store Connect**
- Create subscription group
- Add products (monthly, yearly)
- Set pricing

**Task 7.1.2: StoreKit 2 Implementation**
- Load products
- Handle purchases
- Restore purchases
- Check entitlements

### 7.2 Paywall

**Task 7.2.1: Paywall View**
- Show when accessing premium content
- Display pricing options
- Benefits list
- Purchase buttons

**Task 7.2.2: Premium Content Gating**
- Mark premium workouts
- Show paywall when tapped
- Unlock after purchase

### 7.3 Backend Subscription Sync

**Task 7.3.1: Validate Receipts**
- Verify purchases server-side
- Sync subscription status to Firestore

### Phase 7 Deliverables
- [ ] StoreKit 2 integrated
- [ ] Products configured in App Store Connect
- [ ] Paywall view complete
- [ ] Purchase flow working
- [ ] Premium content gated

---

## Phase 8: Polish & Testing
**Duration:** 1 week  
**Goal:** App ready for beta testing

### 8.1 UI Polish

- Review all screens with your wife's design eye
- Ensure consistent spacing, colors, typography
- Add loading states everywhere
- Add empty states
- Add error states with retry

### 8.2 Performance

- Image caching and optimization
- API response caching where appropriate
- Smooth scrolling in lists
- Fast app launch

### 8.3 Testing

**Task 8.3.1: Unit Tests**
- Test cycle phase calculations
- Test API service layer

**Task 8.3.2: UI Testing**
- Test critical flows (sign up, complete workout)

**Task 8.3.3: Manual Testing**
- Test on multiple device sizes
- Test with slow network
- Test offline behavior

### 8.4 App Store Preparation

- App icon (all sizes)
- Screenshots for App Store
- App description and keywords
- Privacy policy URL
- Support URL

### Phase 8 Deliverables
- [ ] UI polished and consistent
- [ ] No obvious bugs
- [ ] Performance acceptable
- [ ] App Store assets ready

---

## Phase 9: Beta Launch
**Duration:** 1-2 weeks  
**Goal:** App in TestFlight with real users

### 9.1 TestFlight Setup

**Task 9.1.1: Archive and Upload**
- Product → Archive in Xcode
- Upload to App Store Connect
- Wait for processing

**Task 9.1.2: Internal Testing**
- Add yourself and wife as internal testers
- Test full flow on real devices
- Fix critical issues

**Task 9.1.3: External Beta**
- Submit for Beta App Review
- Once approved, invite founding beta users
- Collect feedback

### 9.2 Iterate on Feedback

- Prioritize feedback
- Fix bugs
- Make UX improvements
- Release updated builds

### Phase 9 Deliverables
- [ ] App on TestFlight
- [ ] Internal testing complete
- [ ] External beta launched
- [ ] Feedback collected and prioritized

---

## Phase 10: App Store Launch
**Duration:** 1-2 weeks  
**Goal:** Live on the App Store

### 10.1 App Store Submission

- Complete all App Store Connect metadata
- Submit for review
- Respond to any reviewer questions

### 10.2 Launch

- App approved and released
- Announce to waitlist
- Monitor for issues

---

## Quick Reference: Key Accounts & URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Firebase Console | console.firebase.google.com | Auth, Firestore, Storage |
| Railway Dashboard | railway.app/dashboard | Backend hosting |
| App Store Connect | appstoreconnect.apple.com | iOS app distribution |
| Apple Developer | developer.apple.com | Certificates, provisioning |
| Vimeo | vimeo.com | Video hosting |
| Anthropic Console | console.anthropic.com | Claude API keys |
| Stripe Dashboard | dashboard.stripe.com | Payments (if using web) |

---

## Environment Variables Checklist

### Backend (.env)
```
# Server
ENVIRONMENT=development
PORT=8000
API_URL=http://localhost:8000

# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
# Or use inline JSON:
# FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# AI
ANTHROPIC_API_KEY=sk-ant-xxx

# Video
VIMEO_ACCESS_TOKEN=xxx

# Payments (if using Stripe)
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### iOS (in Xcode scheme or config)
```
API_BASE_URL=https://your-app.railway.app
```

---

## Estimated Timeline Summary

| Phase | Duration | Milestone |
|-------|----------|-----------|
| Phase 0: Infrastructure | 1-2 days | All accounts ready |
| Phase 1: Backend Foundation | 1 week | API deployed |
| Phase 2: iOS Foundation | 1.5 weeks | Auth + onboarding working |
| Phase 3: Workout Library | 1.5 weeks | Browse + play videos |
| Phase 4: AI Recommendations | 1 week | Personalized suggestions |
| Phase 5: Cycle Tracking | 1 week | Full cycle UI |
| Phase 6: Profile & Settings | 0.5 weeks | User management |
| Phase 7: Subscriptions | 1 week | Paywall working |
| Phase 8: Polish & Testing | 1 week | Beta ready |
| Phase 9: Beta Launch | 1-2 weeks | TestFlight live |
| Phase 10: App Store | 1-2 weeks | Public launch |

**Total: 10-12 weeks to MVP launch**
