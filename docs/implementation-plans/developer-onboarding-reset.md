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

### 1. Add Reset Function and State Flag to AuthViewModel
**File**: `StrengthGraceFlow/Features/Auth/ViewModels/AuthViewModel.swift`

Add a private flag to track developer onboarding reset mode:
```swift
#if DEBUG
// Flag to prevent auth listener from overriding during developer onboarding reset
private var isDeveloperOnboardingReset = false
#endif
```

Update the auth state listener to respect the flag:
```swift
private func setupAuthStateListener() {
    authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
        Task { @MainActor in
            #if DEBUG
            // Don't override state during developer onboarding reset
            guard self?.isDeveloperOnboardingReset != true else { return }
            #endif

            if user != nil {
                self?.authState = .authenticated
            } else {
                self?.authState = .unauthenticated
            }
        }
    }
}
```

Add the reset function:
```swift
// MARK: - Developer Tools

#if DEBUG
func resetToOnboarding() {
    isDeveloperOnboardingReset = true
    authState = .onboarding
}
#endif
```

Update the completeOnboarding function to clear the flag:
```swift
func completeOnboarding() {
    #if DEBUG
    isDeveloperOnboardingReset = false
    #endif
    authState = .authenticated
}
```

**Critical Bug Fix**: The Firebase auth state listener continuously monitors auth state and automatically sets `authState = .authenticated` when a user is logged in. Without the `isDeveloperOnboardingReset` flag, the listener would immediately override the `.onboarding` state set by the reset function, preventing developers from actually going through the onboarding flow.

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

### 3. Fix OnboardingContainerView to Support Both New and Existing Users
**File**: `StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`

Add state variables for loading and error handling:
```swift
@State private var isLoading = false
@State private var errorMessage: String?
```

Update the `completeOnboarding()` function to try UPDATE first, then CREATE:
```swift
private func completeOnboarding() {
    Task {
        isLoading = true
        errorMessage = nil

        do {
            // ... prepare data ...

            // Try to update profile first (for existing users during developer reset)
            // If that fails, create a new profile (for new users)
            do {
                let updateRequest = UpdateUserRequest(...)
                _ = try await APIService.shared.updateUserProfile(data: updateRequest)
            } catch let error as APIError {
                // If update fails with 404 (user profile doesn't exist), create it
                if case .notFound = error {
                    let createRequest = CreateUserRequest(...)
                    _ = try await APIService.shared.createUserProfile(data: createRequest)
                } else {
                    throw error
                }
            }

            // Complete onboarding in auth view model
            await MainActor.run {
                authViewModel.completeOnboarding()
                isLoading = false
            }
        } catch let error as APIError {
            await MainActor.run {
                errorMessage = error.errorDescription
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Something went wrong. Please try again."
                isLoading = false
            }
        }
    }
}
```

Update OnboardingCycleView to accept and display error state:
```swift
struct OnboardingCycleView: View {
    @Binding var cycleDates: [Date]
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onComplete: () -> Void

    // ... in body ...

    // Error message
    if let errorMessage = errorMessage {
        Text(errorMessage)
            .font(.sgfCaption)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, SGFSpacing.lg)
    }

    Button(cycleDates.isEmpty ? "Skip for Now" : "Continue") {
        onComplete()
    }
    .buttonStyle(SGFPrimaryButtonStyle(isDisabled: isLoading))
    .disabled(isLoading)
}
```

**Critical Bug Fix**: The original implementation always called `createUserProfile` (POST), which fails for existing users who are replaying onboarding via the developer reset tool. The backend returns an error (profile already exists), but this was silently caught and only printed to console. Users saw nothing and couldn't complete onboarding. The solution tries UPDATE first, then falls back to CREATE for genuinely new users.

### 4. Alternative: Hidden Gesture (Optional)
If we want to keep UI cleaner, add a triple-tap gesture on the version number or app logo in Settings.

## Files to Modify

1. `StrengthGraceFlow/Features/Auth/ViewModels/AuthViewModel.swift`
   - Add `isDeveloperOnboardingReset` private flag
   - Update `setupAuthStateListener()` to check flag before overriding state
   - Add `resetToOnboarding()` function that sets the flag
   - Update `completeOnboarding()` to clear the flag

2. `StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`
   - Add `isLoading` and `errorMessage` state variables
   - Update `completeOnboarding()` to try UPDATE first, then CREATE
   - Add proper error handling with user feedback
   - Pass error state to OnboardingCycleView

3. `StrengthGraceFlow/Features/Profile/Views/ProfileView.swift` (already implemented)
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
- Onboarding data is updated (not duplicated) when completed again via PATCH endpoint

## Bugs Discovered and Fixed

### Bug #1: Auth State Listener Override (Race Condition)
**Symptom**: After tapping "Reset to Onboarding", users were immediately snapped back to the authenticated state, unable to go through onboarding.

**Root Cause**: The Firebase auth state listener (`setupAuthStateListener`) continuously monitors authentication state. When it detects a logged-in user, it automatically sets `authState = .authenticated`, overriding the `.onboarding` state set by the reset function.

**Solution**: Added `isDeveloperOnboardingReset` flag that prevents the auth listener from overriding the state while a developer is testing the onboarding flow.

**Location**: `AuthViewModel.swift:41-47`

### Bug #2: API Call Fails for Existing Users
**Symptom**: When existing users tried to complete onboarding during developer reset, the completion silently failed with no feedback.

**Root Cause**: The `completeOnboarding()` function always called `createUserProfile` (POST), which returns an error for existing users (profile already exists). The error was caught but only printed to console - users had no idea why onboarding wouldn't complete.

**Solution**: Changed to try `updateUserProfile` (PATCH) first, then fall back to `createUserProfile` (POST) if the update returns 404. This handles both existing users (developer reset) and new users (first-time signup).

**Location**: `OnboardingContainerView.swift:63-133`

### Bug #3: Silent Error Handling
**Symptom**: When errors occurred during onboarding completion, users saw no feedback and were left confused.

**Root Cause**: Errors were caught but only logged to console with `print()`. No UI feedback was provided.

**Solution**: Added `isLoading` and `errorMessage` state variables, proper error handling in the catch blocks, and error message display in the UI. The completion button is disabled during loading.

**Location**: `OnboardingContainerView.swift:18-19, 509-516, 521-522`

## Estimated Effort
- **Initial Implementation** (simple version): 5-10 minutes
- **Bug Discovery & Fixes**: 30-45 minutes
- **Testing**: 5-10 minutes
- **Total**: ~50-65 minutes

**Note**: The initial "simple" implementation appeared to work but had critical bugs that prevented the feature from functioning correctly. The extra time was spent debugging race conditions and API error handling.

## Follow-up Considerations
- Could extend to reset other app states (clear cycle data, reset preferences, etc.)
- Could add other developer tools (view logs, toggle feature flags, etc.)
