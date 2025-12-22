# Strength Grace & Flow — Development Log

> This log tracks project progress and major decisions. Use this to quickly understand the current state of the project.

## Current Status

**Phase:** 4 - AI Recommendations (Basic)
**Last Updated:** 2025-12-21
**Status:** Phases 0-4 complete, ready for TestFlight prep

## Quick Context

Strength Grace & Flow is a **cycle-synced fitness iOS app** for women. It recommends workouts based on menstrual cycle phases (Menstrual, Follicular, Ovulatory, Luteal).

### Tech Stack
| Layer | Technology |
|-------|------------|
| iOS App | SwiftUI |
| Backend | FastAPI (Python) on Railway |
| Database | Firebase (Auth, Firestore, Storage) |
| AI | Claude API |
| Video | Vimeo |
| Payments | StoreKit 2 |

---

## Progress Timeline

### 2025-12-21 — Phase 4: AI Recommendations (Basic)

**What was done:**
- Added basic AI recommendation endpoint using Claude API
- Created prompt templates for cycle-aware recommendations
- Fallback content when API key not configured

**Files created:**
- `backend/app/ai/prompts/daily_recommendation.py` — Prompt templates
- `backend/app/services/recommendation_service.py` — Claude API integration
- `backend/app/routers/recommendations.py` — Recommendation endpoints

**API Endpoint:**
| Method | Path | Purpose |
|--------|------|---------|
| GET | /api/v1/recommendations/today | AI-powered daily recommendations |

**Note:** AI recommendations are intentionally basic for MVP. Future enhancements planned:
- More personalized prompts based on workout history
- Integration with Apple Health data
- Mood/energy input from user
- Progressive difficulty suggestions

---

### 2025-12-21 — Phase 3: Workout Library

**What was done:**
- Added 12 placeholder workouts across all categories
- Created workout list, detail, and completion views
- Workouts tagged by cycle phase and intensity

**Backend:**
- `backend/app/models/workout.py` — Workout models
- `backend/app/services/workout_service.py` — Workout service with placeholders
- `backend/app/routers/workouts.py` — Workout endpoints

**iOS:**
- `WorkoutListView.swift` — Grid with phase/category filters
- `WorkoutDetailView.swift` — Detail with video placeholder
- Workout completion flow with rating

**Categories:** Yoga, Pilates, Strength, HIIT, Cardio, Barre, Dance, Stretching

---

### 2025-12-21 — Phase 2: iOS App Foundation

**What was done:**
- Created complete SwiftUI app structure
- Firebase Auth integration (sign up, sign in, sign out)
- 4-step onboarding flow
- Main tab navigation with Today view

**iOS Files:**
- `Core/Theme/SGFTheme.swift` — Design system (colors, typography, spacing)
- `Services/AuthService.swift` — Firebase Auth wrapper
- `Services/APIService.swift` — Backend API client
- `Features/Auth/*` — Welcome, SignIn, SignUp views
- `Features/Onboarding/*` — Name, goals, level, cycle setup
- `Features/Today/*` — Today view with cycle phase card
- `RootView.swift` — Auth-based navigation

---

### 2025-12-21 — Phase 1 Complete: Backend Foundation

**What was done:**
- Implemented complete backend with Firebase Auth integration
- Created all Phase 1 API endpoints, deployed to Railway
- Auth middleware protecting all user/cycle endpoints

**Files created:**
- `backend/app/config/settings.py` — Pydantic settings management
- `backend/app/config/firebase.py` — Firebase Admin SDK init & token verification
- `backend/app/middleware/auth.py` — JWT auth middleware with CurrentUser dependency
- `backend/app/models/user.py` — User Pydantic models (FitnessLevel, FitnessGoal enums)
- `backend/app/models/cycle.py` — Cycle models (CyclePhase, CycleInfo, predictions)
- `backend/app/utils/cycle_calculations.py` — Core phase detection algorithm
- `backend/app/services/user_service.py` — Firestore CRUD for user profiles
- `backend/app/services/cycle_service.py` — Cycle tracking & predictions
- `backend/app/routers/users.py` — User profile REST endpoints
- `backend/app/routers/cycle.py` — Cycle tracking REST endpoints

**API Endpoints (all protected):**
| Method | Path | Purpose |
|--------|------|---------|
| GET | /api/v1/users/me | Get user profile |
| POST | /api/v1/users/me | Create user profile |
| PATCH | /api/v1/users/me | Update user profile |
| DELETE | /api/v1/users/me | Delete user & data |
| GET | /api/v1/cycle/current | Current phase info |
| POST | /api/v1/cycle/log-period | Log period start |
| GET | /api/v1/cycle/history | Cycle history |
| GET | /api/v1/cycle/predictions | Future phase predictions |

**Deployment verified:**
- Health: `https://strength-gace-flow-production.up.railway.app/api/health`
- Docs: `https://strength-gace-flow-production.up.railway.app/docs`

**Next Steps:**
- [ ] Add `FIREBASE_SERVICE_ACCOUNT_JSON` to Railway environment variables
- [ ] Create Xcode project (Phase 0 remaining step)
- [ ] Begin Phase 2: iOS app foundation

---

### 2025-12-21 — Project Initialization

**What was done:**
- Created GitHub repo: `gusmar2017/strength-gace-flow`
- Initialized local git repo and linked to remote
- Set up `.claude/` directory with commands and settings
- Created core documentation:
  - `strength-grace-flow-architecture.md` — Full technical architecture
  - `implementation-guide.md` — Phase-by-phase implementation plan
  - `design-system.md` — UI/UX design tokens and patterns

**Key Decisions:**
- [x] Backend: **FastAPI (Python)** over Node.js/Express
  - Rationale: Team preference, better async support, auto-generated API docs
- [x] iOS: **SwiftUI** with native components
  - Rationale: Modern, declarative, built-in accessibility
- [x] Video hosting: **Vimeo** (Pro/Business)
  - Rationale: Privacy controls, embeddable player, no YouTube branding

**Next Steps:**
- [ ] Phase 0: Set up Firebase project
- [ ] Phase 0: Set up Railway project
- [x] Phase 0: Create initial backend project structure
- [ ] Phase 0: Create initial iOS project in Xcode

### 2025-12-21 — Backend Structure & Planning

**What was done:**
- Completed implementation planning session
- Created backend project structure with FastAPI
- Set up Docker and Railway configuration
- Created health check endpoint

**Backend files created:**
- `backend/app/main.py` — FastAPI entry point
- `backend/app/routers/health.py` — Health check endpoint
- `backend/requirements.txt` — Python dependencies
- `backend/Dockerfile` — Container configuration
- `backend/railway.toml` — Railway deployment config
- `backend/.env.example` — Environment template

**Key Decisions:**
- [x] Defer Vimeo setup — Use placeholder videos initially
- [x] Learn iOS as we build — No separate tutorial phase
- [x] Apple Developer already enrolled — No wait time needed

**Pending (requires browser):**
- [ ] Create Firebase project at console.firebase.google.com
- [ ] Create Railway project at railway.app
- [ ] Create Xcode project (requires Xcode GUI)

---

## Decision Log

| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|------------------------|
| 2025-12-21 | Use FastAPI for backend | Python ecosystem, auto docs, async support | Node.js/Express |
| 2025-12-21 | Native SwiftUI components | Accessibility, performance, iOS-native feel | Custom UI components |
| 2025-12-21 | Vimeo for video hosting | Privacy controls, clean player | YouTube, self-hosted |

---

## File Reference

| File | Purpose |
|------|---------|
| `strength-grace-flow-architecture.md` | Technical architecture, data models, API design |
| `implementation-guide.md` | Phase-by-phase implementation tasks |
| `design-system.md` | Colors, typography, component patterns |
| `docs/phases/` | Detailed logs per implementation phase |
| `docs/devlog.md` | This file — progress summary |
| `docs/cli-setup.md` | Firebase and Railway CLI setup guide |
