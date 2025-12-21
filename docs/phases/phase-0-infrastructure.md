# Phase 0: Project Infrastructure Setup

**Status:** In Progress
**Started:** 2025-12-21
**Goal:** All accounts, projects, and local development environment ready

---

## Checklist

### Firebase Setup
- [ ] Create Firebase project (`strength-grace-flow`)
- [ ] Enable Authentication (Email/Password)
- [ ] Enable Apple Sign In (requires Apple Developer account)
- [ ] Create Firestore database (test mode)
- [ ] Enable Firebase Storage
- [ ] Download `GoogleService-Info.plist`
- [ ] Generate service account JSON for backend

### Railway Setup
- [ ] Create Railway project
- [ ] Create API service
- [ ] Configure environment variables
- [ ] Generate public domain

### Apple Developer
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Identity verification complete

### Local Environment
- [x] Clone repository
- [x] Set up `.claude/` configuration
- [ ] Create backend project structure
- [ ] Create iOS project in Xcode
- [ ] Configure Firebase CLI

### Vimeo (can defer)
- [ ] Create Vimeo Pro/Business account
- [ ] Generate API access token

---

## Decisions Made

### Backend: FastAPI over Node.js

**Date:** 2025-12-21

**Decision:** Use Python/FastAPI for the backend instead of Node.js/Express.

**Rationale:**
- Team familiarity with Python
- FastAPI auto-generates OpenAPI docs (`/docs` endpoint)
- Excellent async support
- Pydantic for data validation
- Better AI/ML library ecosystem if needed later

**Trade-offs:**
- Slightly smaller ecosystem for web-specific packages
- Need to manage Python virtual environments

---

## Session Notes

### 2025-12-21 — Initial Setup

**Actions taken:**
1. Cloned empty GitHub repo
2. Set up `.claude/` directory with:
   - `settings.json` — default permissions and model settings
   - `commands/` — fast, think, review, test commands
   - `skills/capabilities/` — Claude Code reference
3. Created architecture documentation
4. Updated docs to reflect FastAPI backend choice

**Files created:**
- `strength-grace-flow-architecture.md`
- `implementation-guide.md`
- `design-system.md`
- `docs/devlog.md`
- `docs/phases/phase-0-infrastructure.md`

**Blockers:** None

**Next session should:**
1. Set up Firebase project
2. Create Railway project
3. Scaffold backend with FastAPI
4. Scaffold iOS project with SwiftUI
