# Strength Grace & Flow — Development Log

> This log tracks project progress and major decisions. Use this to quickly understand the current state of the project.

## Current Status

**Phase:** 5 - TestFlight (Ready for Upload)
**Last Updated:** 2025-12-24
**Status:** All features merged to main, backend deployed, ready for TestFlight upload once Apple Developer Program is approved

---

## What's Been Accomplished

### ✅ Phase 0: Infrastructure
- [x] Firebase project created and configured
- [x] Firebase Auth enabled (Email/Password)
- [x] Railway project deployed
- [x] Xcode project created with Firebase SDK
- [x] App icon added (cropped logo, 1024x1024)

### ✅ Phase 1: Backend Foundation
- [x] FastAPI backend on Railway
- [x] Firebase Admin SDK integration
- [x] JWT authentication middleware
- [x] User profile CRUD endpoints
- [x] Cycle tracking endpoints
- [x] Phase calculation algorithm

### ✅ Phase 2: iOS App Foundation
- [x] SwiftUI app structure
- [x] Design system (SGFTheme)
- [x] Firebase Auth (sign up, sign in, sign out)
- [x] 4-step onboarding flow
- [x] Tab navigation (Today, Workouts, Calendar, Profile)
- [x] Today view with cycle phase card

### ✅ Phase 3: Workout Library
- [x] 12 placeholder workouts (no videos yet)
- [x] Workout list with phase/category filters
- [x] Workout detail view
- [x] Workout completion flow

### ✅ Phase 4: AI Recommendations (Basic)
- [x] Claude API integration
- [x] Cycle-aware prompts
- [x] Fallback recommendations
- [x] `/api/v1/recommendations/today` endpoint

### ✅ Phase 4.5: Enhanced Cycle Tracking (Date-Based History)
- [x] Date-based cycle tracking (replaces generic averages)
- [x] Onboarding collects 1-3 historical cycle dates
- [x] Backend stores full cycle history with automatic calibration
- [x] Median-based calculations (robust to outliers)
- [x] Smart period logging banner on Today view
- [x] Cycle history management (view, delete, manual logging)
- [x] PATCH/DELETE endpoints for cycle management
- [x] Auto-recalculation of averages on data changes

### 🔄 Phase 5: TestFlight (Waiting for Apple Developer Approval)
- [x] App icon ready
- [x] Applied for Apple Developer Program ($99/year)
- [ ] Wait for Apple Developer Program approval (24-48 hours typically)
- [ ] Create app in App Store Connect
- [ ] Archive and upload from Xcode
- [ ] TestFlight internal testing

---

## What's Remaining Before Polish

### Must Do for TestFlight — Detailed Steps

#### Step 1: Create App in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click **Apps** → **+** (blue plus button) → **New App**
3. Fill in the form:
   - **Platform**: iOS
   - **Name**: `Strength Grace & Flow`
   - **Primary Language**: English (US)
   - **Bundle ID**: Select `com.strengthgraceflow.StrengthGraceFlow`
   - **SKU**: `strengthgraceflow-001`
   - **User Access**: Full Access
4. Click **Create**

#### Step 2: Archive in Xcode
1. Open `/Users/gustavomarquez/Documents/strength-grace-flow/StrengthGraceFlow/StrengthGraceFlow.xcodeproj`
2. In the toolbar, select **Any iOS Device (arm64)** as the build destination (NOT a simulator)
3. Go to menu: **Product** → **Archive**
4. Wait for build to complete (may take a few minutes)
5. The **Organizer** window opens automatically when done

#### Step 3: Upload to App Store Connect
1. In the Organizer window, select your new archive
2. Click **Distribute App**
3. Select **App Store Connect** → Click **Next**
4. Select **Upload** → Click **Next**
5. Keep default options (automatic signing, etc.) → Click **Next**
6. Review and click **Upload**
7. Wait for upload to complete

#### Step 4: Wait for Apple Processing
- Apple processes the build (10-30 minutes typically)
- You'll get an email when it's ready
- Check status in App Store Connect → TestFlight

#### Step 5: Configure TestFlight
1. In App Store Connect, go to **TestFlight** tab
2. Your build should appear under **iOS Builds**
3. Click on the build version
4. Under **Internal Testing**, click **+** to add testers
5. Add yourself and any team members
6. Testers receive email invitation to download TestFlight app and install

#### Common Issues & Fixes
- **"No accounts with App Store Connect access"**: Sign in to Xcode with Apple Developer account (Xcode → Settings → Accounts)
- **"Bundle ID not found"**: Create the app in App Store Connect first (Step 1)
- **Code signing errors**: In Xcode project settings, set Team to your Apple Developer team
- **"Missing compliance"**: In TestFlight, answer the export compliance question (usually "No" for encryption)

### Known Limitations (OK for MVP)
- Workouts use placeholder content (no real videos)
- AI recommendations are basic (will expand later)
- Calendar tab is placeholder
- Profile tab is minimal (just sign out)
- Cycle History view needs navigation integration (not added to main tabs yet)

### Post-TestFlight Polish (Future)
- Real workout videos (Vimeo integration)
- Enhanced AI recommendations with history
- Full calendar with cycle tracking
- Profile settings and preferences
- Push notifications
- Apple Health integration
- Subscription/payments (StoreKit 2)

---

## Quick Reference

### Live URLs
| Service | URL |
|---------|-----|
| API Health | https://strength-gace-flow-production.up.railway.app/api/health |
| API Docs | https://strength-gace-flow-production.up.railway.app/docs |
| Firebase Console | https://console.firebase.google.com (project: strength-grace-flow) |
| Railway Dashboard | https://railway.app |
| App Store Connect | https://appstoreconnect.apple.com |

### API Endpoints
| Method | Path | Purpose |
|--------|------|---------|
| GET | /api/health | Health check |
| GET | /api/v1/users/me | Get user profile |
| POST | /api/v1/users/me | Create profile (with initial_cycle_dates) |
| PATCH | /api/v1/users/me | Update profile |
| DELETE | /api/v1/users/me | Delete user |
| GET | /api/v1/cycle/current | Current phase |
| POST | /api/v1/cycle/log-period | Log period |
| GET | /api/v1/cycle/history | Cycle history |
| PATCH | /api/v1/cycle/history/{id} | Update cycle entry |
| DELETE | /api/v1/cycle/history/{id} | Delete cycle entry |
| GET | /api/v1/cycle/predictions | Predictions |
| GET | /api/v1/workouts | List workouts |
| GET | /api/v1/workouts/{id} | Workout detail |
| GET | /api/v1/workouts/recommended | Phase recommendations |
| POST | /api/v1/workouts/history | Log completion |
| GET | /api/v1/recommendations/today | AI recommendations |

### Environment Variables (Railway)
- `FIREBASE_SERVICE_ACCOUNT_JSON` - ✅ Configured
- `ANTHROPIC_API_KEY` - ✅ Configured
- `PORT` - Auto-set by Railway

### Project Structure
```
strength-grace-flow/
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── ai/prompts/        # AI prompt templates
│   │   ├── config/            # Settings, Firebase
│   │   ├── middleware/        # Auth
│   │   ├── models/            # Pydantic models
│   │   ├── routers/           # API endpoints
│   │   ├── services/          # Business logic
│   │   └── utils/             # Cycle calculations
│   ├── Dockerfile
│   └── requirements.txt
├── StrengthGraceFlow/          # iOS app
│   └── StrengthGraceFlow/
│       ├── Core/Theme/        # Design system
│       ├── Features/
│       │   ├── Auth/          # Sign in/up
│       │   ├── Onboarding/    # Setup flow (with date pickers)
│       │   ├── Today/         # Main tab (with period logging)
│       │   │   └── ViewModels/ # TodayViewModel
│       │   ├── Cycle/         # Cycle history management
│       │   │   ├── Views/     # CycleHistoryView
│       │   │   └── ViewModels/ # CycleHistoryViewModel
│       │   └── Workouts/      # Workout library
│       ├── Services/          # API, Auth
│       └── Assets.xcassets/   # App icon
├── docs/
│   ├── devlog.md              # This file
│   └── cli-setup.md           # Firebase/Railway CLI
└── *.md                       # Architecture docs
```

---

## Progress Timeline

### 2025-12-21 — Full MVP Development Day

**Session Summary:**
Single-day sprint completing Phases 0-4 of the MVP.

**Accomplishments:**
- Set up complete infrastructure (Firebase, Railway, Xcode)
- Built full FastAPI backend with auth and all endpoints
- Created SwiftUI iOS app with auth, onboarding, and main UI
- Added 12 placeholder workouts with filtering
- Integrated Claude API for recommendations
- Tested app on physical iPhone device
- Prepared app icon for TestFlight

**Issues Resolved:**
- Railway PORT configuration (use $PORT env var)
- Firebase Auth not enabled (enabled Email/Password)
- Developer Mode on iPhone (enabled in Privacy & Security)
- Untrusted Developer (trusted in VPN & Device Management)

**Stopping Point:**
Ready for TestFlight upload. Next session: App Store Connect setup and archive upload.

### 2025-12-22 — Apple Developer Program Enrollment

**Session Summary:**
Started TestFlight upload process, discovered need for Apple Developer Program membership.

**Accomplishments:**
- Applied for Apple Developer Program ($99/year)
- Updated documentation to reflect waiting period

**Stopping Point:**
Waiting for Apple Developer Program approval (typically 24-48 hours). Once approved, will proceed with App Store Connect setup and Xcode archive upload.

### 2025-12-24 — Enhanced Cycle Tracking Implementation

**Session Summary:**
Major upgrade to cycle tracking system, transforming from generic averages to date-based history with full CRUD management.

**Accomplishments:**

*Backend (Python/FastAPI):*
- Added `UpdateCycleRequest` model for editing cycle entries
- Added `initial_cycle_dates` field to `UserCreate` for onboarding (accepts 1-3 dates)
- Implemented median-based average calculation (more robust to outliers than mean)
- Created `initialize_cycle_tracking()` to create cycle entries from onboarding dates
- Created `recalculate_and_update_averages()` for automatic recalculation
- Created `update_cycle_entry()` for editing existing cycles
- Created `delete_cycle_entry()` with validation (can't delete last cycle)
- Updated `create_user_profile()` to initialize cycle tracking on onboarding
- Added PATCH `/api/v1/cycle/history/{id}` endpoint
- Added DELETE `/api/v1/cycle/history/{id}` endpoint

*iOS (SwiftUI):*
- Redesigned `OnboardingCycleView` with date pickers (replaces +/- buttons)
  - Users can add 1-3 cycle dates or skip
  - Dates displayed in list with remove functionality
- Implemented `completeOnboarding()` with full backend integration
- Updated `APIService` with all necessary methods and models
- Created `TodayViewModel` for cycle data and period logging
- Added `LogPeriodBanner` to Today view (appears when appropriate)
- Added `LogPeriodSheet` for quick period logging with date picker
- Created `CycleHistoryView` with stats, list, edit, and delete
- Created `CycleHistoryViewModel` for history data management

**Key Features:**
- Onboarding collects actual cycle dates instead of generic numbers
- Backend automatically calculates average from historical data
- Smart banner on Today view prompts logging when cycle day > 20
- Full cycle history management with delete capability
- Median calculation prevents outliers from skewing averages
- Automatic recalculation when data changes

**Technical Decisions:**
- Median > Mean: More robust to irregular cycles (stress, travel, etc.)
- Skip option in onboarding: Don't force data entry, encourage later
- Banner logic: Show when late in cycle OR no data exists
- Delete validation: Prevent deleting last cycle (need at least one)

**Files Modified/Created:**
- Backend: 6 files modified (models, services, routers, utils)
- iOS: 3 files modified, 3 new files created
- 14 files total, +1014 lines, -127 lines

**Stopping Point:**
Core cycle tracking feature complete and committed. Pending deployment and navigation integration.

### 2025-12-24 (Later) — Deployment and Merge to Main

**Session Summary:**
Completed navigation integration, deployed backend to Railway, and merged all MVP features to main branch.

**Accomplishments:**
- Integrated Cycle History navigation into Calendar tab (replaced placeholder)
- Merged `feature/mvp-implementation` branch to `main` (6 commits, 18 files changed)
- Pushed to GitHub, triggering Railway auto-deployment
- Verified all new cycle endpoints deployed successfully:
  - GET `/api/v1/cycle/history` - List cycle history
  - PATCH `/api/v1/cycle/history/{id}` - Update cycle entry
  - DELETE `/api/v1/cycle/history/{id}` - Delete cycle entry

**Technical Details:**
- MainTabView Calendar tab now shows CycleHistoryView
- Users can access full cycle tracking from main navigation
- Backend auto-deployed via Railway GitHub integration
- All API endpoints verified via OpenAPI spec

**Stopping Point:**
✅ All MVP features complete and deployed! Ready for TestFlight upload once Apple Developer Program is approved.

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-12-21 | FastAPI backend | Python ecosystem, auto docs, team preference |
| 2025-12-21 | SwiftUI native | Modern, accessible, iOS-native feel |
| 2025-12-21 | Placeholder workouts | Ship MVP fast, add real content later |
| 2025-12-21 | Basic AI recommendations | Intentionally simple for MVP, expand later |
| 2025-12-21 | TestFlight before polish | Validate pipeline, get early feedback |
| 2025-12-24 | Date-based cycle tracking | Better accuracy than averages, enables future features |
| 2025-12-24 | Median over mean | Robust to irregular cycles, better UX |

---

## File Reference

| File | Purpose |
|------|---------|
| `strength-grace-flow-architecture.md` | Technical architecture, data models |
| `implementation-guide.md` | Phase-by-phase tasks |
| `design-system.md` | Colors, typography, components |
| `docs/devlog.md` | This file — progress summary |
| `docs/cli-setup.md` | Firebase and Railway CLI guide |
