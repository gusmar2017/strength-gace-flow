# Strength Grace & Flow — Development Log

> This log tracks project progress and major decisions. Use this to quickly understand the current state of the project.

## Current Status

**Phase:** 0 - Project Infrastructure Setup
**Last Updated:** 2025-12-21
**Status:** In Progress

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
