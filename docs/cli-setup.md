# CLI Tools Setup

This document covers the CLI tools used for development and deployment.

---

## Firebase CLI

### Installation

```bash
npm install -g firebase-tools
```

### Authentication

```bash
firebase login
```

### Project Setup

This repo is already configured via `.firebaserc`. To verify:

```bash
firebase use
# Should output: strength-grace-flow
```

### Common Commands

```bash
# List projects
firebase projects:list

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules

# Deploy all rules
firebase deploy --only firestore,storage

# Open Firebase console
firebase open
```

### Files

| File | Purpose |
|------|---------|
| `.firebaserc` | Project alias configuration |
| `firebase.json` | Firebase services configuration |
| `firestore.rules` | Firestore security rules |
| `firestore.indexes.json` | Firestore composite indexes |
| `storage.rules` | Cloud Storage security rules |

---

## Railway CLI

### Installation

```bash
npm install -g @railway/cli
```

Or on macOS with Homebrew:

```bash
brew install railway
```

### Authentication

```bash
railway login
```

### Project Setup

Link to the project (run from repo root):

```bash
railway link
# Select: strength-grace-flow project
# Select: api service
```

### Common Commands

```bash
# Check current project/service
railway status

# View logs
railway logs

# Open dashboard
railway open

# Deploy manually (usually auto-deploys from git)
railway up

# Run command in Railway environment
railway run <command>

# Set environment variable
railway variables set KEY=value

# List environment variables
railway variables
```

### Environment Variables

Set these in Railway dashboard or via CLI:

```bash
railway variables set PORT=8000
railway variables set ENVIRONMENT=production
railway variables set ANTHROPIC_API_KEY=sk-ant-xxx
# For Firebase, paste the entire JSON:
railway variables set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

### Deployment

Railway auto-deploys when you push to the `main` branch.

**Important:** Set Root Directory to `backend` in Railway Settings.

### Files

| File | Purpose |
|------|---------|
| `backend/Dockerfile` | Container build instructions |
| `backend/railway.toml` | Railway-specific configuration |
| `backend/.env.example` | Environment variable template |

---

## Quick Reference

| Task | Firebase | Railway |
|------|----------|---------|
| Login | `firebase login` | `railway login` |
| Check project | `firebase use` | `railway status` |
| View logs | `firebase functions:log` | `railway logs` |
| Open dashboard | `firebase open` | `railway open` |
| Deploy | `firebase deploy` | `railway up` or git push |
