# AI Coach Skill

## Metadata
- **Name**: ai-coach
- **Description**: Claude API-powered cycle-synced workout recommendation engine
- **Allowed Tools**:
  - Bash
  - Read
  - Edit
  - WebSearch
  - Grep
  - Glob

## AI Integration Overview

The AI Coach skill leverages Anthropic's Claude API to generate personalized, cycle-aware workout recommendations. This integration provides a holistic approach to fitness that respects the physiological changes throughout the menstrual cycle.

### Key Components
- **Prompt Engineering**: Sophisticated prompting techniques to generate contextual recommendations
- **Cycle Synchronization**: Recommendations adapt to the user's current menstrual cycle phase
- **Fallback Mechanisms**: Robust error handling with predefined recommendations

## Prompt Engineering Patterns

### System Prompt Strategy
The system prompt establishes the AI coach's persona and core principles:
- Specialized in cycle-synced training for women
- Body-positive and supportive approach
- Deep understanding of hormonal impacts on fitness

### Dynamic Prompt Construction
The `build_recommendation_prompt()` function creates context-rich prompts by:
- Incorporating current cycle phase
- Considering fitness level and goals
- Filtering available workouts
- Avoiding recently completed workouts

### Response Parsing
- Strict JSON response format
- Standardized output structure
  - `daily_message`: Personalized phase-based message
  - `recommendations`: 3 tailored workout suggestions
  - `self_care_tip`: Phase-specific wellness advice

## Cycle Data-Driven Recommendations

### Physiological Insights
Each cycle phase receives specialized recommendations:

1. **Menstrual Phase (Days 1-5)**
   - Focus: Gentle movement, rest
   - Energy Level: Low
   - Recommended Intensity: Low

2. **Follicular Phase (Days 6-13)**
   - Focus: Exploring new workouts, building intensity
   - Energy Level: Rising
   - Recommended Intensity: Moderate

3. **Ovulatory Phase (Days 14-16)**
   - Focus: High-intensity training
   - Energy Level: Peak
   - Recommended Intensity: High

4. **Luteal Phase (Days 17-28)**
   - Focus: Strength, stability
   - Energy Level: Gradually decreasing
   - Recommended Intensity: Moderate to Low

## Recommendation Service Architecture

### Key Components
- **User Profile Integration**: Fitness level, goals
- **Workout Filtering**: Phase-appropriate workouts
- **AI Model Selection**: Claude Sonnet 4
- **Fallback Mechanism**: Predefined recommendations

### AI Interaction Flow
1. Gather user context (phase, cycle day, goals)
2. Select available workouts
3. Construct detailed prompt
4. Call Claude API
5. Parse and validate response
6. Return personalized recommendations

## Development Patterns

### Modifying Prompts
- Edit `/backend/app/ai/prompts/daily_recommendation.py`
- Update `SYSTEM_PROMPT` or `build_recommendation_prompt()`
- Maintain JSON response structure
- Test thoroughly after modifications

### Adding New AI Features
1. Extend prompt engineering techniques
2. Create new prompt construction functions
3. Add fallback mechanisms
4. Implement comprehensive error handling
5. Write extensive test coverage

## Testing AI Features

### Recommended Testing Approaches
- Unit tests for prompt generation
- Mock Claude API responses
- Validate JSON parsing
- Test fallback mechanisms
- Comprehensive edge case coverage

### Test Scenarios
- Empty workout lists
- Invalid cycle phases
- API connection failures
- Unexpected API response formats

## Common Tasks

1. **Generate Recommendations**
   ```bash
   # Get today's recommendations
   /ai-coach today

   # Get recommendations for a specific phase
   /ai-coach phase menstrual
   ```

2. **Modify Prompt Engineering**
   ```bash
   /ai-coach edit-prompt
   ```

3. **Test AI Recommendation Generation**
   ```bash
   /ai-coach test-recommendations
   ```

## When to Use This Skill

- Generating personalized workout recommendations
- Exploring cycle-based fitness strategies
- Debugging AI recommendation logic
- Updating prompt engineering techniques
- Testing AI integration capabilities

## Best Practices

- Always respect the user's physiological state
- Prioritize body-positive language
- Maintain a supportive, encouraging tone
- Adapt recommendations to individual needs
- Continuously refine AI interactions

## Limitations
- Recommendations based on available workout library
- Requires active cycle tracking
- AI suggestions complement, not replace, professional medical advice