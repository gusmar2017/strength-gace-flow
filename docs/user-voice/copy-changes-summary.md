# Copy Changes Summary

## Overview
Updated all user-facing copy to align with the Strength, Grace and Flow voice guidelines: gentle, reflective, wise friend tone using natural language with words like balance, harmony, rhythm, and alignment.

## Documentation Created

### New Files
1. **docs/user-voice/user-persona.md** - Complete user persona documentation
2. **docs/user-voice/voice-guidelines.md** - Comprehensive voice and tone guidelines with examples

## Language Updates

### TodayView.swift
**Period Tracking Banner:**
- ❌ "Did your period start?"
- ✅ "Is today day 1 of your cycle?"

- ❌ "Tap to log for better predictions"
- ✅ "Tap to log when you're ready"

**Navigation Title:**
- ❌ "Log Period Start"
- ✅ "Day 1"

**Phase Descriptions:**
- ❌ Menstrual: "Rest and recover. Focus on gentle movement."
- ✅ Menstrual: "A time for rest and gentle movement."

- ❌ Follicular: "Energy rising! Great time to try new things."
- ✅ Follicular: "Your energy is building. A good time to try new things."

- ❌ Ovulatory: "Peak energy! Push yourself with high intensity."
- ✅ Ovulatory: "You may feel your energy is at its fullest."

- ❌ Luteal: "Wind down. Focus on strength and stability."
- ✅ Luteal: "A time to honor your need for balance and stability."

### CycleHistoryView.swift
**Empty State:**
- ❌ "No Cycle History Yet"
- ✅ "Your Cycle History"

- ❌ "Start tracking by logging your period start dates"
- ✅ "Your insights will appear here as you track"

**Button:**
- ❌ "Log First Period"
- ✅ "Begin Tracking"

**Navigation Title:**
- ❌ "Log Period"
- ✅ "Day 1"

### OnboardingContainerView.swift
**Onboarding Question:**
- ❌ "When did your last few periods start?"
- ✅ "When did your last few cycles begin?"

**Subtitle:**
- ❌ "Add 1-3 recent start dates for better predictions"
- ✅ "Add 1-3 recent dates to help us understand your rhythm"

**Button:**
- ❌ "Add period start date"
- ✅ "Add cycle start date"

**Skip Message:**
- ❌ "You can skip this and log your next period when it starts"
- ✅ "You can skip this and begin tracking whenever you're ready"

**Form Field:**
- ❌ "Period Start Date"
- ✅ "Cycle Start Date"

### MainTabView.swift
**Calendar Description:**
- ❌ "Track your cycle history"
- ✅ "Your cycle history and patterns"

### WelcomeView.swift
**Tagline:**
- ❌ "Workouts synced to your cycle"
- ✅ "Movement in harmony with your cycle"

### SignUpView.swift
**Subtitle:**
- ❌ "Start your cycle-synced fitness journey"
- ✅ "Movement in harmony with your body's rhythm"

## Key Voice Improvements

### Removed
- Exclamation points (too enthusiastic)
- Directive language ("Push yourself", "Focus on")
- Transactional phrases ("for better predictions")
- Clinical terms ("menstrual period")

### Added
- Gentle questions instead of demands
- Acknowledgment of individual experience ("You may feel")
- Language of honor and awareness ("A time to honor")
- Core brand words (harmony, rhythm, balance)
- Present, grounded language
- Neutral terminology that works for all life stages

## Voice Alignment

All changes now reflect:
- ✅ **Natural language** - cycle, period, flow (not clinical terms)
- ✅ **Minimal and reflective** - calm companion, not over-explaining
- ✅ **Neutral terms** - works for everyone regardless of reproductive goals
- ✅ **Wise friend tone** - supportive without being preachy
- ✅ **Core vocabulary** - balance, harmony, rhythm, alignment
- ✅ **Context-appropriate mix** - questions for check-ins, statements for information

## Files Modified

1. `/StrengthGraceFlow/Features/Today/Views/TodayView.swift`
2. `/StrengthGraceFlow/Features/Cycle/Views/CycleHistoryView.swift`
3. `/StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`
4. `/StrengthGraceFlow/Features/Today/Views/MainTabView.swift`
5. `/StrengthGraceFlow/Features/Auth/Views/WelcomeView.swift`
6. `/StrengthGraceFlow/Features/Auth/Views/SignUpView.swift`

## Next Steps

Review the voice guidelines in `docs/user-voice/voice-guidelines.md` when:
- Adding new features
- Writing notifications
- Creating error messages
- Drafting educational content
- Designing onboarding flows

The voice guidelines include a quick reference card and examples for all common scenarios.
