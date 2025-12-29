# Implementation Plan: Developer Onboarding Reset Feature

## Overview
Add a hidden developer feature that allows resetting the app to onboarding state without creating new accounts, enabling rapid testing of the onboarding flow.

## Problem
Currently, to test the onboarding flow repeatedly, developers must:
- Create new accounts with different emails, OR
- Delete users from Firebase Console, OR
- Use Gmail "+" trick for multiple test accounts

This is time-consuming and inefficient during active development.

## Solution
Add a hidden "Reset to Onboarding" button in the Settings/Profile screen that:
1. Resets the app's auth state to `.onboarding`
2. Allows developers to replay the onboarding flow with their existing account
3. Only appears in debug/development builds (or behind a hidden gesture)

## Implementation Steps

### 1. Add Reset Function to AuthViewModel
**File**: `StrengthGraceFlow/Features/Auth/ViewModels/AuthViewModel.swift`

Add a new public function:
```swift
// MARK: - Developer Tools

#if DEBUG
func resetToOnboarding() {
    authState = .onboarding
}
#endif
```

### 2. Create Developer Settings Section
**File**: `StrengthGraceFlow/Features/Profile/Views/ProfileView.swift` (or create if doesn't exist)

Add a developer section at the bottom of settings:
```swift
#if DEBUG
Section {
    Button(action: {
        authViewModel.resetToOnboarding()
    }) {
        HStack {
            Image(systemName: "arrow.counterclockwise")
                .foregroundColor(.sgfSecondary)
            Text("Reset to Onboarding")
                .foregroundColor(.sgfTextPrimary)
        }
    }
} header: {
    Text("Developer Tools")
        .foregroundColor(.sgfTextSecondary)
}
#endif
```

### 3. Alternative: Hidden Gesture (Optional)
If we want to keep UI cleaner, add a triple-tap gesture on the version number or app logo in Settings.

## Files to Modify

1. `StrengthGraceFlow/Features/Auth/ViewModels/AuthViewModel.swift`
   - Add `resetToOnboarding()` function

2. `StrengthGraceFlow/Features/Profile/Views/ProfileView.swift`
   - Add developer section with reset button
   - Ensure it has access to `@EnvironmentObject var authViewModel: AuthViewModel`

## Testing

1. Build app in Debug mode
2. Complete onboarding flow (reach main app)
3. Navigate to Settings/Profile
4. Tap "Reset to Onboarding" button
5. Verify app returns to onboarding screens
6. Complete onboarding again
7. Verify app returns to authenticated state

## Notes

- Feature is wrapped in `#if DEBUG` so it won't appear in TestFlight or production builds
- No data is deleted - only the UI state changes
- User remains authenticated to Firebase
- Onboarding data will be re-submitted to backend when completed again (may create duplicate records - acceptable for testing)

## Estimated Effort
- **Implementation**: 5-10 minutes
- **Testing**: 2-3 minutes
- **Total**: ~15 minutes

## Follow-up Considerations
- Could extend to reset other app states (clear cycle data, reset preferences, etc.)
- Could add other developer tools (view logs, toggle feature flags, etc.)
