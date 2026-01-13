---
name: ios
description: Expert iOS development for Strength Grace & Flow - cycle-synced fitness app with SwiftUI, MVVM, and Firebase
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

# iOS Development Skill

Expert iOS development for the Strength Grace & Flow app - a cycle-synced fitness application built with SwiftUI, MVVM architecture, and Firebase backend.

## Project Overview

**Strength Grace & Flow** is a women's health and fitness app that provides personalized workout recommendations based on menstrual cycle phases.

**Tech Stack:**
- SwiftUI for declarative UI
- MVVM architecture pattern
- Firebase Auth for authentication
- RESTful API backend (Railway)
- UserNotifications for period reminders
- Combine for reactive programming

**Key Features:**
- Cycle phase tracking (menstrual, follicular, ovulatory, luteal)
- Daily energy logging
- Phase-appropriate workout recommendations
- Period start notifications
- Firebase authentication

## Project Structure

```
StrengthGraceFlow/StrengthGraceFlow/
├── StrengthGraceFlowApp.swift      # App entry point with Firebase config
├── Core/
│   └── Theme/
│       └── SGFTheme.swift           # Design system: colors, typography, spacing
├── Features/                        # Feature-based organization
│   ├── Auth/
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift
│   │   └── Views/
│   │       └── [Auth screens]
│   ├── Today/                       # Main dashboard
│   │   ├── ViewModels/
│   │   │   └── TodayViewModel.swift
│   │   └── Views/
│   │       └── TodayView.swift
│   ├── Cycle/                       # Cycle tracking features
│   ├── Workouts/                    # Workout library
│   └── Onboarding/                  # First-time user flow
├── Services/
│   ├── APIService.swift             # Backend API client
│   ├── AuthService.swift            # Firebase Auth wrapper
│   └── NotificationManager.swift    # Push notifications
└── Models/
    └── [Shared data models]
```

## Architectural Patterns

### MVVM Architecture

**ViewModel Pattern:**
```swift
@MainActor
class FeatureViewModel: ObservableObject {
    @Published var data: DataType?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            data = try await APIService.shared.getData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**View Pattern:**
```swift
struct FeatureView: View {
    @StateObject private var viewModel = FeatureViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                // Content using viewModel.data
            }
            .background(Color.sgfBackground)
            .navigationTitle("Title")
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
}
```

### Service Layer

**APIService Pattern:**
- Singleton instance: `APIService.shared`
- Generic request method with error handling
- Custom date decoder for ISO8601 and date-only formats
- Bearer token auth from Firebase
- Codable request/response models with snake_case mapping

**AuthService Pattern:**
- Firebase Auth wrapper
- `@Published` properties for reactive UI updates
- Auth state listener for automatic sign-in/out
- User-friendly error mapping

## Theme System

The app uses a comprehensive design system defined in `SGFTheme.swift`:

### Colors
```swift
// Core palette
.sgfPrimary         // Deep Terracotta (#B35C44)
.sgfSecondary       // Dusty Blue (#6F8F9B)
.sgfAccent          // Soft Clay (#D8B8A6)

// Backgrounds
.sgfBackground      // Soft Sand (#F6F1EA)
.sgfSurface         // White

// Text
.sgfTextPrimary     // Deep Charcoal
.sgfTextSecondary   // Charcoal Light
.sgfTextTertiary    // Placeholder text

// Cycle phases
.sgfMenstrual       // Deep Terracotta
.sgfFollicular      // Dusty Blue
.sgfOvulatory       // Soft Clay
.sgfLuteal          // Blue-Clay Blend
```

### Typography
```swift
.sgfLargeTitle      // 34pt bold rounded
.sgfTitle           // 28pt bold rounded
.sgfHeadline        // 17pt semibold
.sgfBody            // 17pt regular
.sgfCaption         // 12pt regular
```

### Spacing (8pt grid)
```swift
SGFSpacing.xs       // 4pt
SGFSpacing.sm       // 8pt
SGFSpacing.md       // 16pt (standard padding)
SGFSpacing.lg       // 24pt
SGFSpacing.xl       // 32pt
```

### Corner Radius
```swift
SGFCornerRadius.sm  // 8pt
SGFCornerRadius.md  // 12pt (standard)
SGFCornerRadius.lg  // 16pt
```

## Development Patterns

### Adding a New Feature

1. **Create feature directory structure:**
   ```
   Features/NewFeature/
   ├── ViewModels/
   │   └── NewFeatureViewModel.swift
   └── Views/
       └── NewFeatureView.swift
   ```

2. **Create ViewModel:**
   - Mark with `@MainActor`
   - Inherit from `ObservableObject`
   - Use `@Published` for reactive state
   - Initialize with async data loading in `init()`
   - Handle loading/error states consistently

3. **Create View:**
   - Use `@StateObject` for ViewModel ownership
   - Wrap in `NavigationStack` for navigation
   - Apply `.background(Color.sgfBackground)`
   - Use design system constants for spacing/colors

### Modifying Existing Views

1. **Read the View and ViewModel files first**
2. **Understand the data flow:**
   - ViewModel publishes state
   - View observes and renders
   - User actions call ViewModel methods
3. **Maintain consistency:**
   - Use existing patterns for layout
   - Apply theme constants
   - Follow spacing guidelines

### Creating a New ViewModel

```swift
@MainActor
class NewViewModel: ObservableObject {
    // Published state
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Initialize with data loading
    init() {
        Task {
            await loadItems()
        }
    }

    // Async data operations
    func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await APIService.shared.getItems()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // User actions
    func createItem(name: String) async {
        isLoading = true

        do {
            let newItem = try await APIService.shared.createItem(name: name)
            items.append(newItem)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

### API Integration

1. **Define request/response models in APIService.swift:**
   ```swift
   struct CreateItemRequest: Codable {
       let name: String
       let category: String

       enum CodingKeys: String, CodingKey {
           case name
           case category
       }
   }

   struct ItemResponse: Codable {
       let item: Item
   }
   ```

2. **Add service method:**
   ```swift
   func createItem(name: String, category: String) async throws -> ItemResponse {
       let data = CreateItemRequest(name: name, category: category)
       return try await request(endpoint: "/api/v1/items", method: "POST", body: data)
   }
   ```

3. **Use in ViewModel:**
   ```swift
   func saveItem() async {
       do {
           let response = try await APIService.shared.createItem(
               name: itemName,
               category: selectedCategory
           )
           // Update UI state
       } catch {
           errorMessage = error.localizedDescription
       }
   }
   ```

## Common Tasks

### Reading User Input
```swift
@State private var textInput = ""

TextField("Placeholder", text: $textInput)
    .textFieldStyle(SGFTextFieldStyle())
```

### Displaying Loading State
```swift
if viewModel.isLoading {
    ProgressView()
} else {
    // Content
}
```

### Error Handling
```swift
if let error = viewModel.errorMessage {
    Text(error)
        .font(.sgfCaption)
        .foregroundColor(.sgfError)
}
```

### Navigation
```swift
NavigationStack {
    // Content
    .navigationTitle("Title")
    .navigationBarTitleDisplayMode(.inline)
}
```

### Sheets/Modals
```swift
@State private var showingSheet = false

.sheet(isPresented: $showingSheet) {
    SheetView()
}
```

### Buttons
```swift
Button("Primary Action") {
    // Action
}
.buttonStyle(SGFPrimaryButtonStyle())

Button("Secondary Action") {
    // Action
}
.buttonStyle(SGFSecondaryButtonStyle())
```

### Cards
```swift
VStack {
    // Card content
}
.padding(SGFSpacing.md)
.background(
    RoundedRectangle(cornerRadius: SGFCornerRadius.md)
        .fill(Color.sgfSurface)
)
```

## When to Use This Skill

Invoke the `/ios` skill when:
- Adding new iOS features or screens
- Modifying SwiftUI views or ViewModels
- Integrating new API endpoints
- Working with Firebase Auth
- Implementing UI with the design system
- Debugging iOS-specific issues
- Understanding MVVM architecture patterns
- Working with notifications

The skill provides context on architecture patterns, design system usage, and best practices specific to this SwiftUI + MVVM + Firebase project.
