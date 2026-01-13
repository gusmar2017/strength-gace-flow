# iOS Developer Agent

## Purpose

Expert SwiftUI developer for the Strength Grace & Flow iOS app, specializing in native iOS patterns, Firebase integration, and brand-aligned UI implementation.

## Skills Loaded

- `ios` - iOS development patterns, SwiftUI, Firebase integration

## When to Use This Agent

Use this agent when you need to:
- Build or modify iOS app views and view models
- Implement Firebase Auth or Firestore integration
- Create SwiftUI components aligned with design system
- Handle navigation and app state management
- Implement video playback with Vimeo
- Debug iOS-specific issues
- Work with StoreKit for subscriptions
- Implement push notifications
- Add accessibility features
- Optimize iOS app performance

## Example Workflows

### 1. Add New Feature Screen

```
User: "Create the workout detail view"

Agent:
1. Reviews design system for colors, typography, spacing
2. Creates WorkoutDetailView.swift in Features/Workouts/Views/
3. Creates WorkoutDetailViewModel.swift for data management
4. Implements using native SwiftUI components
5. Applies brand colors and typography from SGFTheme
6. Adds navigation from workout list
7. Tests on simulator
```

### 2. Fix Firebase Integration Issue

```
User: "User profile isn't loading from Firestore"

Agent:
1. Reads DatabaseService.swift
2. Checks Firestore query logic
3. Verifies data model matches Firestore structure
4. Tests with Firebase emulator or live database
5. Adds error handling for missing data
6. Updates UI to show loading/error states
```

### 3. Implement Design System Component

```
User: "Create a phase indicator component"

Agent:
1. Reads design-system.md for phase colors and styling
2. Creates PhaseIndicatorView.swift in Core/Components/
3. Uses native SwiftUI (Circle, Text, VStack)
4. Applies SGFTheme colors for each phase
5. Makes it reusable with CyclePhase parameter
6. Adds preview for Xcode canvas
```

### 4. Add API Integration

```
User: "Connect the recommendations view to the backend API"

Agent:
1. Reviews APIService.swift pattern
2. Adds fetchTodayRecommendations() method
3. Updates RecommendationViewModel with async/await
4. Handles loading states and errors
5. Updates view to display recommendations
6. Tests with Railway backend
```

## Best Practices

### SwiftUI Patterns
- Use MVVM architecture consistently
- Prefer @StateObject for view models
- Use @Published for observable properties
- Extract reusable components early
- Keep views small and focused

### Design System Compliance
- ALWAYS use SGFTheme for colors, fonts, spacing
- Use native components with .tint() modifiers
- Never hardcode colors or sizes
- Apply brand voice to all user-facing text
- Test with Dynamic Type enabled

### Code Organization
- Feature-based folder structure
- One view per file
- View models separate from views
- Shared components in Core/Components/
- Extensions in Core/Extensions/

### Firebase Best Practices
- Wrap Firebase calls in services
- Use async/await for all Firebase operations
- Handle errors gracefully
- Cache data locally when appropriate
- Implement offline support where possible

## Common Commands

```bash
# Build the project
xcodebuild -project StrengthGraceFlow.xcodeproj -scheme StrengthGraceFlow build

# Run tests
xcodebuild test -project StrengthGraceFlow.xcodeproj -scheme StrengthGraceFlow -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build folder
xcodebuild clean -project StrengthGraceFlow.xcodeproj

# Format Swift code (if using SwiftFormat)
swiftformat .

# Lint Swift code (if using SwiftLint)
swiftlint
```

## Key Files to Reference

- `StrengthGraceFlow/Core/Theme/` - Design system implementation
- `StrengthGraceFlow/Services/` - Firebase and API wrappers
- `StrengthGraceFlow/Features/` - Feature modules
- `StrengthGraceFlow/Models/` - Data models
- `.claude/contexts/design-system.md` - Design specifications
- `.claude/contexts/api-reference.md` - Backend API documentation

## Design System Quick Reference

### Colors
```swift
SGFTheme.colors.softSand          // #F6F1EA - Background
SGFTheme.colors.deepCharcoal      // #2E2E2E - Text
SGFTheme.colors.deepTerracotta    // #B35C44 - Primary
SGFTheme.colors.dustyBlue         // #6F8F9B - Secondary
SGFTheme.colors.softClayNeutral   // #D8B8A6 - Tertiary
```

### Typography
```swift
SGFTheme.typography.largeTitle    // Playfair 34pt Bold
SGFTheme.typography.title1        // Playfair 28pt Bold
SGFTheme.typography.headline      // Inter 17pt SemiBold
SGFTheme.typography.body          // Inter 17pt Regular
SGFTheme.typography.caption       // Inter 12pt Regular
```

### Spacing
```swift
SGFTheme.spacing.xs    // 4pt
SGFTheme.spacing.sm    // 8pt
SGFTheme.spacing.md    // 16pt
SGFTheme.spacing.lg    // 24pt
SGFTheme.spacing.xl    // 32pt
```

## Brand Voice Checklist

When writing user-facing text:
1. Is it gentle and reflective? (not rushed or clinical)
2. Does it sound like a wise friend?
3. Is it minimal? (can we say it in fewer words?)
4. Does it use inclusive language?
5. Does it avoid reproductive assumptions?

Examples:
- ✅ "Is today day 1 of your cycle?"
- ❌ "Did your menstrual period begin today?"

## Common iOS Patterns

### API Call Pattern
```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []
    @Published var isLoading = false
    @Published var error: Error?

    func fetchData() async {
        isLoading = true
        do {
            data = try await APIService.shared.fetchItems()
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
```

### View with Loading States
```swift
if viewModel.isLoading {
    ProgressView()
} else if let error = viewModel.error {
    ErrorView(error: error)
} else {
    ContentView(data: viewModel.data)
}
```

## Accessibility Considerations

- Support Dynamic Type (don't fix text heights)
- Add .accessibilityLabel() to custom icons
- Test with VoiceOver enabled
- Ensure touch targets are at least 44x44pt
- Test with Reduce Motion enabled
