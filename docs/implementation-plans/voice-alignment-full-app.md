# Implementation Plan: Full App Voice Alignment

## Overview
Systematically review and update all user-facing language in the Strength Grace Flow iOS app to align with our established voice guidelines: gentle, reflective, wise friend tone using natural language with core vocabulary (balance, harmony, rhythm, alignment).

## Reference Documents
- `docs/user-voice/user-persona.md` - Target user definition
- `docs/user-voice/voice-guidelines.md` - Complete voice and tone guidelines
- `docs/user-voice/copy-changes-summary.md` - Changes already completed

## Completion Status

### ✅ Already Completed
The following areas have been updated and align with voice guidelines:
- Period tracking language (TodayView, CycleHistoryView)
- Onboarding cycle questions (OnboardingContainerView)
- Phase descriptions (TodayView)
- Welcome and signup taglines (WelcomeView, SignUpView)
- Calendar description (MainTabView)

### 🔄 Needs Review & Update
The following areas require review and potential updates:

## Implementation Plan by Feature Area

---

## 1. Authentication Flow

### SignInView
**Current Text:**
- "Welcome Back"
- "Sign in to continue your journey"
- Form labels: "Email", "Password"
- Button: "Sign In"

**Review Needed:**
- ❓ "Sign in to continue your journey" - feels slightly transactional/marketing
- ✅ Form labels are functional, appropriate as-is
- ❓ Error messages need review (dynamic)

**Recommended Changes:**
```
Before: "Sign in to continue your journey"
After: "Welcome back to your practice"
```

**Rationale:** "Your practice" feels more grounded and aligned with mindful movement vs "journey" which is overused marketing language.

---

## 2. Onboarding Flow

### Goal Selection
**Current Text:**
- "What are your goals?"
- "Select all that apply"

**Review Needed:**
- ❓ "What are your goals?" - direct question is okay, but could be softer
- ❓ Goal names from enum need review

**Recommended Changes:**
```
Before: "What are your goals?"
After: "What brings you here?"

Before: "Select all that apply"
After: "Choose what resonates with you"
```

**Rationale:** More invitational language, less transactional.

### Fitness Level
**Current Text:**
- "What's your fitness level?"
- "We'll personalize workouts for you"

**Review Needed:**
- ❓ "fitness level" - functional but clinical
- ❓ "personalize workouts for you" - transactional

**Recommended Changes:**
```
Before: "What's your fitness level?"
After: "How would you describe your current practice?"

Before: "We'll personalize workouts for you"
After: "We'll suggest movement that feels right for you"
```

**Rationale:** "Practice" is more holistic, "feels right" is more body-aware than "personalize."

### Name Collection
**Current Text:**
- "What should we call you?"
- "This is how we'll greet you in the app"

**Review Needed:**
- ✅ These are already gentle and friendly

**Status:** No changes needed ✓

---

## 3. Today View / Energy Tracking

### Energy Level Prompts
**Current Text:**
- "How's your energy today?"
- Energy levels: "Low", "High"
- Buttons: "Log Energy", "Update"

**Review Needed:**
- ✅ "How's your energy today?" - already gentle ✓
- ❓ "Low" / "High" - might be too simple, consider more nuanced language
- ❓ "Log Energy" - functional but could be softer

**Recommended Changes:**
```
Energy Level Labels:
Before: "Low" / "High"
After: "Resting" / "Energized"
  OR: "Gentle" / "Vibrant"
  OR: Keep as-is (simple is often best)

Button Text:
Before: "Log Energy"
After: "Check In"

Before: "Update"
After: "Update" (keep - clear and concise)
```

**Rationale:** "Check in" is more mindful than "log." Energy labels could be more descriptive but "Low/High" is clear - user testing recommended.

### Phase Tips Section
**Current Text:**
- "Phase Tips"
- Dynamic content based on phase

**Review Needed:**
- ❓ "Phase Tips" - functional but could be more inviting
- ❓ Dynamic tips content needs review

**Recommended Changes:**
```
Before: "Phase Tips"
After: "For This Phase"
  OR: "Supporting Your [Phase Name] Phase"
```

**Status:** Requires reviewing dynamic tip content (needs code inspection)

---

## 4. Workout Features

### WorkoutListView
**Current Text:**
- "Workouts" (tab label)
- "Coming in Phase 3" (placeholder)
- Dynamic: workout titles, intensity labels

**Review Needed:**
- ❓ Individual workout titles need review
- ❓ Intensity display names

**Recommended Changes:**
```
Tab Label:
"Workouts" → "Movement"
  OR keep "Workouts" (clear and expected)

Intensity Labels:
Before: "Low", "Medium", "High"
After: "Gentle", "Moderate", "Vigorous"
  OR: "Restorative", "Balanced", "Energizing"
```

**Rationale:** Consider whether "Movement" better aligns with brand, but "Workouts" is clear and searchable in App Store.

### WorkoutDetailView
**Current Text:**
- "Video coming soon"
- "About this workout"
- "Best for"
- "Equipment needed"
- "Start Workout"
- Completion: "Great job!", "You completed [workout]", "How was it?"

**Review Needed:**
- ❓ "Video coming soon" - placeholder is fine
- ✅ "About this workout", "Best for", "Equipment needed" - clear and functional ✓
- ❓ Completion messages need softening

**Recommended Changes:**
```
Completion Messages:
Before: "Great job!"
After: "Well done"
  OR: "You did it"
  OR: "Beautiful work"

Before: "You completed [workout]"
After: "You completed [workout]" (keep - clear statement)

Before: "How was it?"
After: "How did that feel?"
  OR: "How are you feeling?"
```

**Rationale:** "Great job!" with exclamation feels too enthusiastic. "How did that feel?" is more body-aware.

### Workout Descriptions
**Current Text:**
- Example found: "Flow through gentle poses designed to stretch and strengthen your body while calming your mind. Perfect for any time you need to reset."

**Review Needed:**
- ✅ This description is already aligned! Uses "flow", "gentle", "calming" - great ✓
- ❓ Need to review ALL workout descriptions for consistency

**Status:** Audit all workout descriptions in code

---

## 5. Cycle Tracking

### Cycle History Labels
**Current Text:**
- "Avg Cycle"
- "Cycles Logged"
- "Current cycle"

**Review Needed:**
- ❓ "Avg Cycle" - abbreviated, could be clearer
- ❓ "Cycles Logged" - "logged" is transactional

**Recommended Changes:**
```
Before: "Avg Cycle"
After: "Average Length"
  OR: "Your Average"

Before: "Cycles Logged"
After: "Cycles Tracked"
  OR: "Your History"
```

**Rationale:** "Tracked" is softer than "logged." Consider clarity vs brevity for labels.

---

## 6. Navigation & Tabs

### Main Tab Labels
**Current Text:**
- "Today" (implicit from TodayView)
- "Workouts"
- "Cycle" (in tab label)
- "Calendar" (navigation title)
- "Profile"

**Review Needed:**
- ✅ All tab labels are clear and functional ✓
- ❓ Could consider "Movement" instead of "Workouts"

**Status:** Keep as-is (prioritize clarity) ✓

---

## 7. Error Messages & Alerts

### Current Status
**Review Needed:**
- ❌ Error messages are dynamically generated - need code review
- ❌ No current inventory of error states

**Action Required:**
1. Audit all error handling in:
   - AuthViewModel
   - TodayViewModel
   - CycleHistoryViewModel
   - WorkoutViewModel
2. Create gentle, supportive error messages
3. Avoid blame or negative language

**Error Message Principles:**
```
❌ Avoid: "Error: Invalid password"
✅ Use: "That password doesn't look quite right"

❌ Avoid: "Failed to load data"
✅ Use: "We're having trouble loading your data. Please try again"

❌ Avoid: "You must enter a valid email"
✅ Use: "Please enter your email address"
```

---

## 8. Form Fields & Placeholders

### Current Text
**Review Needed:**
- Email, Password fields use standard labels
- TextEditor for notes uses "Notes (Optional)"

**Recommended Changes:**
```
Before: "Notes (Optional)"
After: "Add a note (optional)"
  OR: "Reflections (optional)"
```

**Rationale:** "Reflections" might be too flowery, but "Add a note" is more invitational.

---

## 9. Dynamic Content Requiring Review

### Items Needing Code Inspection:
1. **Goal names** (enum in onboarding)
2. **Fitness level descriptions** (enum in onboarding)
3. **Energy level descriptions** (dynamic based on selection)
4. **Phase tips content** (varies by phase)
5. **All workout titles** (hardcoded or from backend?)
6. **All workout descriptions** (need full audit)
7. **Error messages** (across all ViewModels)
8. **Success/confirmation messages**
9. **Placeholder text** for empty states not yet seen

---

## Implementation Steps

### Phase 1: Audit & Document (1-2 hours)
- [ ] Review all ViewModels for error message handling
- [ ] Extract all enum values (goals, fitness levels, etc.)
- [ ] List all workout titles and descriptions from code
- [ ] Document all placeholder and empty state messages
- [ ] Identify all form field placeholders

### Phase 2: Prioritize Changes (30 mins)
- [ ] Categorize changes as: Must Fix, Should Consider, Nice to Have
- [ ] Identify quick wins (simple text replacements)
- [ ] Flag items requiring user input/decisions

### Phase 3: Update High-Priority Items (2-3 hours)
**Must Fix:**
- [ ] Error messages (all ViewModels)
- [ ] Workout completion messages
- [ ] Form placeholders

**Should Consider:**
- [ ] Onboarding questions
- [ ] Energy level labels
- [ ] Cycle history labels

**Nice to Have:**
- [ ] Tab labels (if changing "Workouts" to "Movement")
- [ ] Phase tips headers

### Phase 4: Update Enums & Dynamic Content (1-2 hours)
- [ ] Update goal names if they exist as enum
- [ ] Update fitness level names/descriptions
- [ ] Update energy level descriptions
- [ ] Update phase tips content

### Phase 5: Audit Workout Content (1-2 hours)
- [ ] Review all workout titles
- [ ] Review all workout descriptions
- [ ] Ensure intensity labels are consistent
- [ ] Update any that don't align with voice

### Phase 6: Testing & Refinement (1 hour)
- [ ] Build and run app
- [ ] Navigate through all screens
- [ ] Trigger error states to see messages
- [ ] Read all text in context
- [ ] Make final adjustments for flow

### Phase 7: Documentation (30 mins)
- [ ] Update copy-changes-summary.md with all new changes
- [ ] Note any decisions made about language choices
- [ ] Document any areas that need future review

---

## Success Criteria

### Voice Alignment Checklist
All user-facing text should:
- ✅ Use natural language (not clinical or overly formal)
- ✅ Feel gentle and reflective (not pushy or enthusiastic)
- ✅ Sound like a wise friend (supportive without being preachy)
- ✅ Use core vocabulary where appropriate (balance, harmony, rhythm, alignment)
- ✅ Be neutral and inclusive (work for all life stages and goals)
- ✅ Avoid exclamation points unless genuinely celebratory
- ✅ Use "you" and "your" to feel personal
- ✅ Be concise and clear (minimal without being cold)

### Testing Questions
For each piece of text, ask:
1. Does this sound like a wise friend?
2. Is it gentle and reflective?
3. Does it work for all our users (ages 22-45, various life stages)?
4. Does it use our core vocabulary where natural?
5. Is it minimal but warm?

---

## Files to Modify

Based on current inventory:

### Confirmed Files:
1. `/Features/Auth/Views/SignInView.swift`
2. `/Features/Auth/Views/SignUpView.swift`
3. `/Features/Onboarding/Views/OnboardingContainerView.swift`
4. `/Features/Today/Views/TodayView.swift`
5. `/Features/Today/ViewModels/TodayViewModel.swift`
6. `/Features/Workouts/Views/WorkoutListView.swift`
7. `/Features/Workouts/Views/WorkoutDetailView.swift`
8. `/Features/Cycle/Views/CycleHistoryView.swift`
9. `/Features/Cycle/ViewModels/CycleHistoryViewModel.swift`

### Potentially:
10. Error handling utilities (if centralized)
11. Any localization files (if they exist)
12. Workout model/data files (for titles & descriptions)

---

## Decision Points Requiring User Input

Before implementing, confirm:

1. **Energy Level Labels:** Keep "Low/High" or change to "Resting/Energized"?
2. **Tab Label:** Keep "Workouts" or change to "Movement"?
3. **Intensity Labels:** Keep "Low/Medium/High" or use "Gentle/Moderate/Vigorous"?
4. **"Avg Cycle":** Keep abbreviated or spell out "Average Length"?
5. **Sign-In Tagline:** Update "continue your journey" to "your practice"?
6. **Completion Message:** "Great job!" → "Well done" or "Beautiful work" or keep?

---

## Estimated Time
- **Phase 1 (Audit):** 1-2 hours
- **Phase 2 (Prioritize):** 30 minutes
- **Phase 3 (High Priority):** 2-3 hours
- **Phase 4 (Enums):** 1-2 hours
- **Phase 5 (Workouts):** 1-2 hours
- **Phase 6 (Testing):** 1 hour
- **Phase 7 (Documentation):** 30 minutes

**Total:** 7-11 hours

Can be broken into smaller sessions:
- Session 1: Phases 1-2 (audit and prioritize)
- Session 2: Phase 3 (high-priority updates)
- Session 3: Phases 4-5 (dynamic content and workouts)
- Session 4: Phases 6-7 (testing and documentation)

---

## Notes

- Some changes are subjective - when in doubt, test with target users
- Prioritize clarity over cleverness
- Remember: the goal is gentle and supportive, not flowery or overly soft
- Consistency matters more than perfection
- Can always iterate based on user feedback after TestFlight

---

## Post-Implementation

After completing this plan:
- [ ] Update voice-guidelines.md with any new examples learned
- [ ] Create a checklist for reviewing new features before adding them
- [ ] Consider creating a style guide for developers
- [ ] Document any patterns for error messages, success messages, etc.
