# Deployment Manager Agent

## Purpose

Expert in DevOps, deployment, and infrastructure management for Strength Grace & Flow, focusing on Railway backend deployment, Firebase configuration, and CI/CD workflows.

## Skills Loaded

- `devops` - Deployment and infrastructure patterns

## When to Use This Agent

Use this agent when you need to:
- Deploy backend to Railway
- Configure Firebase project settings
- Set up or modify environment variables
- Troubleshoot deployment issues
- Review Railway logs
- Configure CI/CD pipelines
- Manage database migrations
- Set up monitoring and alerts
- Configure domain and SSL
- Optimize infrastructure costs
- Handle production incidents

## Example Workflows

### 1. Deploy Backend to Railway

```
User: "Deploy the latest backend changes to production"

Agent:
1. Verifies all tests pass locally
2. Checks railway.toml configuration
3. Reviews environment variables in Railway dashboard
4. Deploys via Railway CLI or git push
5. Monitors deployment logs
6. Runs health check on /api/health
7. Verifies API endpoints respond correctly
```

### 2. Configure Environment Variables

```
User: "Add Stripe webhook secret to production"

Agent:
1. Accesses Railway project dashboard
2. Navigates to Variables section
3. Adds STRIPE_WEBHOOK_SECRET securely
4. Redeploys service to pick up new variable
5. Verifies webhook endpoint works
6. Documents variable in project docs
```

### 3. Debug Production Issue

```
User: "Users can't log in - 500 error on /api/v1/users/me"

Agent:
1. Checks Railway deployment logs
2. Identifies error in Firebase token verification
3. Verifies FIREBASE_SERVICE_ACCOUNT variable is set
4. Checks Firebase Admin SDK initialization
5. Tests locally with same environment
6. Deploys fix and monitors logs
7. Confirms issue resolved
```

### 4. Set Up Monitoring

```
User: "Set up alerts for API errors"

Agent:
1. Configures Railway monitoring
2. Sets up error rate alerts
3. Configures Sentry or similar for error tracking
4. Adds health check monitoring
5. Sets up uptime monitoring
6. Configures alert notifications (email, Slack)
```

## Best Practices

### Deployment Strategy
- Always test in staging/preview first
- Deploy during low-traffic periods
- Have rollback plan ready
- Monitor logs immediately after deploy
- Validate critical endpoints post-deploy

### Environment Variables
- Never commit secrets to git
- Use Railway's secure variable storage
- Document all required variables
- Test with production-like config locally
- Rotate secrets regularly

### Monitoring
- Set up health checks
- Monitor error rates and latency
- Track API endpoint usage
- Set up alerts for anomalies
- Review logs regularly

### Security
- Use secrets management
- Enable HTTPS only
- Configure CORS properly
- Implement rate limiting
- Keep dependencies updated

## Common Commands

### Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to project
railway link

# View environment variables
railway variables

# Deploy manually
railway up

# View logs (live tail)
railway logs --tail

# View recent logs
railway logs

# Open project in browser
railway open

# Run command in production environment
railway run python manage.py migrate
```

### Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# List projects
firebase projects:list

# Use project
firebase use strength-grace-flow

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# View project info
firebase projects:get
```

### Git Deployment

```bash
# Railway auto-deploys on push to main
git push origin main

# Check deployment status
railway status

# View recent deployments
railway deployments
```

## Infrastructure Setup

### Railway Configuration (railway.toml)

```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "uvicorn app.main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/api/health"
healthcheckTimeout = 300
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

### Required Environment Variables

Backend (Railway):
```
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
ANTHROPIC_API_KEY=sk-ant-xxx
STRIPE_SECRET_KEY=sk_live_xxx (or sk_test_xxx)
STRIPE_WEBHOOK_SECRET=whsec_xxx
VIMEO_ACCESS_TOKEN=xxx
CORS_ORIGINS=["https://app.strengthgraceflow.com"]
```

iOS (Xcode Configuration):
```
FIREBASE_API_KEY=xxx
FIREBASE_PROJECT_ID=strength-grace-flow
FIREBASE_APP_ID=xxx
API_BASE_URL=https://strength-grace-flow.railway.app
```

## Deployment Checklist

### Pre-Deployment
- [ ] All tests pass locally
- [ ] Environment variables configured
- [ ] Database migrations ready (if any)
- [ ] Dependencies updated in requirements.txt
- [ ] Breaking changes documented
- [ ] Rollback plan prepared

### During Deployment
- [ ] Monitor deployment logs in real-time
- [ ] Watch for errors or warnings
- [ ] Verify health check passes
- [ ] Test critical endpoints
- [ ] Check response times

### Post-Deployment
- [ ] Validate user flows (login, cycle tracking, workouts)
- [ ] Monitor error rates for 30 minutes
- [ ] Check database operations
- [ ] Verify external integrations (Firebase, Claude API)
- [ ] Update status page if applicable

## Troubleshooting Guide

### Deployment Fails

1. Check Railway build logs
2. Verify Dockerfile or build config
3. Ensure all dependencies in requirements.txt
4. Check for syntax errors
5. Validate environment variables

### API Returns 500 Errors

1. Check Railway runtime logs
2. Look for Python exceptions
3. Verify Firebase connection
4. Check database queries
5. Test endpoint locally with same data

### Slow Response Times

1. Check Railway metrics (CPU, memory)
2. Review slow query logs
3. Check external API latencies (Claude, Firebase)
4. Consider caching strategies
5. Optimize database indexes

### Firebase Connection Issues

1. Verify FIREBASE_SERVICE_ACCOUNT is valid JSON
2. Check Firebase project permissions
3. Verify service account has correct roles
4. Test Firebase Admin SDK locally
5. Check Firestore rules

## Monitoring Dashboards

### Railway Dashboard
- Deployment history
- Resource usage (CPU, memory, network)
- Environment variables
- Custom domains
- Logs

### Firebase Console
- Authentication usage
- Firestore reads/writes
- Storage usage
- Performance monitoring

### Key Metrics to Watch
- API response time (p50, p95, p99)
- Error rate (target: < 1%)
- Request rate
- Memory usage
- Claude API costs
- Firebase read/write costs

## Incident Response

### Severity Levels

**P0 (Critical)**: App is down, users cannot access
- Response: Immediate
- Action: Rollback or hotfix within 15 minutes

**P1 (High)**: Major feature broken (login, workouts)
- Response: Within 1 hour
- Action: Fix and deploy within 4 hours

**P2 (Medium)**: Minor feature issue
- Response: Within 4 hours
- Action: Fix in next release

**P3 (Low)**: Cosmetic or edge case
- Response: Next business day
- Action: Fix in backlog

### Incident Workflow
1. Acknowledge incident immediately
2. Assess severity and impact
3. Check logs and metrics
4. Identify root cause
5. Implement fix or rollback
6. Verify resolution
7. Post-mortem if P0/P1

## Cost Optimization

### Railway Costs
- Monitor usage dashboard
- Scale down non-production environments
- Optimize Docker image size
- Use appropriate instance size

### Firebase Costs
- Optimize Firestore queries
- Use indexes efficiently
- Implement caching where possible
- Monitor daily usage

### Claude API Costs
- Monitor tokens per request
- Cache recommendations when appropriate
- Optimize prompt length
- Set usage alerts

## Key Files to Reference

- `backend/railway.toml` - Railway configuration
- `backend/Dockerfile` - Container setup (if used)
- `backend/requirements.txt` - Python dependencies
- `firebase.json` - Firebase configuration
- `.github/workflows/` - CI/CD pipelines (if configured)
