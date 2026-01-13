---
name: devops
description: Deployment and infrastructure management for Strength Grace Flow
allowed-tools:
  - Bash
  - WebSearch
  - WebFetch
version: 1.0.0
last-updated: 2026-01-12
---

# DevOps Skill: Deployment and Infrastructure Management

## 1. Infrastructure Overview

### Deployment Architecture
- **Backend Hosting**: Railway
  - Containerized deployment via Dockerfile
  - Automatic build and deploy pipeline
- **Database & Authentication**: Firebase
  - Firestore for NoSQL document storage
  - Firebase Authentication
  - Cloud Storage for file uploads

### Deployment Environments
- Development
- Staging
- Production

## 2. Railway Deployment Procedures

### Prerequisites
- Railway CLI v4.16.1 installed
- Docker installed
- Project repository cloned
- Valid Railway account connected

### Deployment Workflow
```bash
# Login to Railway
railway login

# Link project to Railway
railway link

# Deploy to current linked environment
railway up

# List available environments
railway environments

# Switch deployment environment
railway environment set [environment-name]
```

### Configuration Management
Refer to `backend/railway.toml` for deployment configuration:
- Uses Dockerfile for building
- Health check endpoint: `/api/health`
- Health check timeout: 300 seconds
- Restart policy: On failure

### Deployment Best Practices
1. Always use environment-specific configurations
2. Validate health check before marking deployment successful
3. Monitor deployment logs for potential issues
4. Use Railway's rollback feature for quick reversal

## 3. Firebase Configuration & Deployment

### Firebase CLI Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init
```

### Firestore Security Rules
Location: `firestore.rules`

#### Current Rule Strategy
- Development: Authenticated users can access their own data
- Workouts & Programs: Read-only for authenticated users
- Write access restricted to backend/admin

#### Deployment
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules
```

### Recommended Rule Hardening
- Implement more granular role-based access control
- Add validation for document schema
- Use custom claims for admin roles

## 4. Environment Variables Management

### Best Practices
- Never commit secrets to version control
- Use Railway and Firebase environment variables
- Rotate secrets regularly
- Limit variable access by environment

### Variable Types
1. Database connection strings
2. Authentication credentials
3. API keys
4. Feature flags
5. Deployment-specific configurations

### Managing Secrets
```bash
# Railway: Set environment variable
railway variables set KEY_NAME=value

# Firebase: Configure environment configs
firebase functions:config:set service.key="value"
```

## 5. Health Checks & Monitoring

### Backend Health Endpoint
- Path: `/api/health`
- Checks:
  1. Database connectivity
  2. Basic system resources
  3. Critical service dependencies

### Monitoring Tools
- Railway built-in logs
- Firebase Performance Monitoring
- External uptime monitors (Pingdom, Statuspage)

### Logging Strategy
- Structured logging
- Log rotation
- Sensitive data masking
- Environment-based log levels

## 6. Common Deployment Tasks

### Rollback Procedure
```bash
# Railway rollback to previous deployment
railway rollback

# Firebase rollback rules/functions
firebase deploy --version [version-id]
```

### Maintenance Mode
- Implement backend endpoint for maintenance status
- Configure Railway to serve maintenance page
- Gracefully handle ongoing requests

## 7. Troubleshooting Patterns

### Deployment Failure Diagnostics
1. Check Railway deployment logs
2. Verify Dockerfile build steps
3. Validate environment configurations
4. Test local docker build
5. Review recent code changes

### Common Issues
- Dependency conflicts
- Runtime environment mismatches
- Misconfigured environment variables
- Firestore rule syntax errors

## 8. When to Use This Skill

### Ideal Scenarios
- Deploying new application version
- Configuring new environment
- Performing system maintenance
- Debugging deployment issues
- Implementing infrastructure changes

### Avoid Using For
- Local development setup
- Code-level debugging
- Feature implementation

## 9. Security Considerations

### Deployment Checklist
- ✓ Remove development/test credentials
- ✓ Enable all security rules
- ✓ Validate HTTPS configurations
- ✓ Review access permissions
- ✓ Enable multi-factor authentication
- ✓ Use principle of least privilege

## Appendix: Version Compatibility

- Railway CLI: v4.16.1
- Firebase CLI: v15.1.0
- Recommended Node.js: v20.x LTS