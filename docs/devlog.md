# Strength Grace & Flow — Development Log

> This log tracks project progress and major decisions. Use this to quickly understand the current state of the project.

## Current Status

**Phase:** 1 - Backend Foundation (Complete)
**Last Updated:** 2025-12-21
**Status:** Phase 1 deployed to Railway

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
