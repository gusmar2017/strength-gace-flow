# Cycle Domain Skill

## Metadata
- **Name**: cycle-domain
- **Description**: Menstrual cycle tracking domain skill for comprehensive cycle management
- **Allowed Tools**: Grep, Read, WebSearch, Skill

## Domain Overview: Menstrual Cycle Tracking

### Core Phases of the Menstrual Cycle
1. **Menstrual Phase** (Days 1-5)
   - Bleeding occurs
   - Low energy period
   - Focus on rest and gentle movement
   - Recommended Intensity: Low

2. **Follicular Phase** (Days 6-13)
   - Energy rising
   - Hormones preparing for ovulation
   - Optimal for trying new activities
   - Recommended Intensity: Medium

3. **Ovulatory Phase** (Days 14-16)
   - Peak energy window
   - Highest hormone levels
   - Best for challenging workouts
   - Recommended Intensity: High

4. **Luteal Phase** (Days 17-28)
   - Winding down before next period
   - Energy gradually decreasing
   - Focus on steady, grounding practices
   - Recommended Intensity: Medium

### Cycle Calculation Principles
- Average cycle length: 28 days (can vary 21-35 days)
- Phases determined by last period start date
- Calculated dynamically based on:
  - Last period start date
  - Average cycle length
  - Average period length
  - Current reference date

### Data Models

#### Cycle Tracking Models
- **CyclePhase** (Enum): Represents current cycle phase
  - Possible values: MENSTRUAL, FOLLICULAR, OVULATORY, LUTEAL
  - Methods:
    - `display_name`: Human-readable phase name
    - `description`: Phase-specific guidance
    - `recommended_intensity`: Workout intensity recommendation

- **CycleInfo**: Comprehensive phase information
  - Current phase
  - Cycle day
  - Days until next phase
  - Next phase
  - Confidence level
  - Phase display name
  - Phase description
  - Recommended workout intensity

- **CycleData**: Historical cycle entry
  - Unique ID
  - User ID
  - Start date
  - End date
  - Cycle length
  - Notes
  - Creation timestamp

#### Confidence Calculation
Confidence levels determined by:
- Number of logged cycles
- Cycle length consistency
- Recency of last logged period
- Levels: High, Medium, Low

### Business Logic Patterns

#### Cycle Phase Calculation
1. Calculate days since last period start
2. Determine current cycle day
3. Map cycle day to appropriate phase
4. Calculate days until next phase
5. Estimate confidence based on data quality

#### Prediction Mechanisms
- Predict future cycle phases
- Estimate next period start date
- Generate historical and future predictions
- Use median for robust average calculations

### Recommendations Logic
- Phase-based workout intensity guidance
- Holistic approach considering:
  - Hormonal changes
  - Energy levels
  - Physical capabilities

### Calendar and Visualization Patterns
- Date-based phase tracking
- Predictions spanning historical and future dates
- Support for multiple visualization needs
- Flexible date range handling

### Development Patterns

#### Modifying Cycle Calculations
1. Review existing calculation methods
2. Update phase boundaries or prediction logic
3. Validate against multiple user scenarios
4. Maintain backward compatibility
5. Add comprehensive test cases

#### Adding New Cycle Features
1. Extend existing data models
2. Create new calculation methods
3. Update service layer
4. Implement API endpoints
5. Add client-side view models
6. Write comprehensive tests

### Common Tasks

1. **Log Period Start**
   - Normalize date to UTC midnight
   - Update user's cycle history
   - Recalculate cycle averages
   - Schedule period start notifications

2. **Get Current Cycle Info**
   - Retrieve last period start date
   - Calculate current phase
   - Generate phase-specific recommendations

3. **Predict Future Cycles**
   - Generate phase predictions
   - Estimate next period start
   - Provide confidence indicators

### When to Use This Skill

Use cycle-domain skill when you need to:
- Implement or modify menstrual cycle tracking features
- Calculate cycle phases and predictions
- Generate phase-based recommendations
- Develop personalized health tracking functionality
- Create UI components for cycle visualization
- Perform complex cycle-related calculations

## Best Practices
- Always use UTC dates for consistency
- Respect user privacy and data sensitivity
- Provide clear, compassionate guidance
- Support variations in individual cycle patterns
- Maintain a holistic, supportive approach to cycle tracking

## Warning
This skill involves sensitive personal health data. Always prioritize:
- Data privacy
- Secure storage
- User consent
- Accurate, supportive information