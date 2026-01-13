# CLAUDE: Strength Grace & Flow Project Guide

## 1. Project Overview

Strength Grace & Flow is an intelligent, cycle-synced fitness companion designed specifically for women. By leveraging menstrual cycle data and advanced AI, the app provides personalized workout recommendations that adapt to each user's unique physiological rhythms, promoting holistic wellness, performance optimization, and body-aware fitness.

## 2. Tech Stack Summary

- **Backend**:
  - Python FastAPI
  - Firebase Authentication & Realtime Database
  - Deployment: Railway

- **Frontend**:
  - iOS SwiftUI
  - Native mobile experience
  - Tight integration with HealthKit

- **AI/ML**:
  - Cycle tracking intelligence
  - Personalized workout recommendation engine
  - Privacy-first machine learning approaches

- **Infrastructure**:
  - Firebase for authentication & data storage
  - Railway for backend deployment
  - Secure, scalable cloud architecture

## 3. Key Domains

### Cycle Tracking Domain
- Menstrual cycle phase detection
- Physiological rhythm analysis
- Hormonal impact prediction
- Privacy-preserving data modeling

### AI Recommendation Engine
- Adaptive workout generation
- Personalization based on:
  - Cycle phase
  - User fitness goals
  - Historical performance
  - Energy levels
- Machine learning model training

### iOS Application
- SwiftUI-based native interface
- HealthKit integration
- Reactive UI components
- Secure local data management

### Backend API
- RESTful endpoint design
- Authentication middleware
- Data validation & sanitization
- Performance optimized endpoints

## 4. Context Router

### Skills Index
- `/backend`: Python FastAPI development contexts
- `/ios`: SwiftUI application development
- `/ai-coach`: Machine learning recommendation system
- `/cycle-domain`: Menstrual cycle tracking logic
- `/devops`: Deployment and infrastructure management
- `/brand-voice`: Communication and product positioning

### Contextual Documentation
- `architecture.md`: System design and component interactions
- `api-reference.md`: Comprehensive API endpoint documentation
- `design-system.md`: UI/UX guidelines and component specifications

### Agent Specializations
- `backend-tester`: API and integration test automation
- `ios-developer`: Native mobile app development
- `ai-optimizer`: Machine learning model tuning
- `deployment-manager`: Infrastructure and CI/CD workflows
- `full-stack`: Cross-domain problem solving

## 5. Sub-Agent Orchestration Pattern

### Task Tool Usage Guidelines
- Use Task tool for complex, multi-step workflows
- Trigger specialized agents for domain-specific challenges
- Maintain clear communication between sub-agents
- Prioritize modular, composable solutions

#### Orchestration Workflow
1. Define overall objective
2. Decompose into specific sub-tasks
3. Assign to appropriate specialized agents
4. Aggregate and validate results
5. Ensure cross-domain consistency

## 6. Model Selection Guidance

### AI Model Selection Strategy
- **Claude Sonnet 3.5**:
  - Daily development tasks
  - Code reviews
  - Standard implementation work
  - Consistent, reliable performance

- **Claude Opus 4.5**:
  - Complex architectural decisions
  - Machine learning model design
  - Advanced problem solving
  - Strategic system design

- **Claude Haiku**:
  - Quick, lightweight tasks
  - Performance optimization
  - Rapid prototyping
  - Simple script generation

## 7. Common Workflows

### Development Workflows
- `git flow feature start [feature-name]`
- `pytest backend/tests`
- `xcodebuild test -scheme SGFApp`
- `railway deploy backend`

### AI Model Transition
```bash
/model sonnet  # Daily work
/model opus    # Complex reasoning
/model haiku   # Quick tasks
```

### Continuous Integration
1. Push code to feature branch
2. Trigger automated tests
3. Request code review
4. Merge after approval

## Collaboration Principles

- Prioritize clear, modular design
- Maintain strict type safety
- Embrace functional programming paradigms
- Protect user privacy
- Optimize for performance and user experience

---

**Note**: This guide is a living document. Continuously update to reflect project evolution and best practices.