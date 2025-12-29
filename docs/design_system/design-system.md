# Strength Grace & Flow — Design System

## Brand Foundation

### Brand Essence
- **Core Idea:** Cyclical strength for feminine bodies
- **Emotional Feel:** Calm, grounded, nurturing, confident
- **Brand Promise:** Support your body through every phase

### Voice & Tone
- Gentle, grounded, supportive
- Educational, never shaming
- Feminine strength over intensity

---

## Color Palette

### Core Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Soft Sand** | `#F6F1EA` | 246, 241, 234 | Backgrounds, cards |
| **Deep Charcoal** | `#2E2E2E` | 46, 46, 46 | Primary text |
| **Deep Terracotta** | `#B35C44` | 179, 92, 68 | Primary accents, buttons, active states |
| **Dusty Blue** | `#6F8F9B` | 111, 143, 155 | Secondary accents, calm elements |
| **Soft Clay Neutral** | `#D8B8A6` | 216, 184, 166 | Tertiary accents, highlights |

### Extended Palette (Derived)

| Name | Hex | Usage |
|------|-----|-------|
| **Terracotta Light** | `#C98F7A` | Hover states, subtle backgrounds |
| **Terracotta Dark** | `#8B4030` | Pressed states, emphasis |
| **Blue Light** | `#9FB5BE` | Secondary hover, calm highlights |
| **Blue Dark** | `#4A6A78` | Pressed states for blue elements |
| **Clay Light** | `#E8D4C5` | Soft backgrounds, cards |
| **Sand Dark** | `#E8E0D5` | Card backgrounds, dividers |
| **Charcoal Light** | `#5A5A5A` | Secondary text |
| **Charcoal Lighter** | `#8A8A8A` | Placeholder text, captions |

### Cycle Phase Colors

Each menstrual phase has a color that fits within the brand palette:

| Phase | Color | Hex | Rationale |
|-------|-------|-----|-----------|
| **Menstrual** | Deep Terracotta | `#B35C44` | Warm, grounding, restful |
| **Follicular** | Dusty Blue | `#6F8F9B` | Growth, calm renewal, rising energy |
| **Ovulatory** | Soft Clay Neutral | `#D8B8A6` | Peak warmth, gentle vitality |
| **Luteal** | Blue-Clay Blend | `#9B9A9A` | Winding down, balanced introspection |

---

## Typography

### Font Stack

**Headlines:** Playfair Display
- Elegant, feminine serif
- Use for: Screen titles, section headers, marketing copy
- Weights: Regular (400), Medium (500), Bold (700)

**Body:** Inter
- Clean, highly readable sans-serif
- Use for: Body text, buttons, labels, UI elements
- Weights: Regular (400), Medium (500), SemiBold (600)

### iOS Implementation

Since Playfair Display isn't a system font, we have two options:

**Option A: Bundle Custom Fonts (Recommended)**
- Download Playfair Display from Google Fonts
- Add to Xcode project and Info.plist
- Better brand consistency

**Option B: System Font Fallback**
- Use `.serif` design for headlines (New York font)
- Use `.rounded` design for a softer feel
- Faster initial development

### Type Scale

| Style | Font | Size | Weight | Line Height | Usage |
|-------|------|------|--------|-------------|-------|
| **Large Title** | Playfair | 34pt | Bold | 41pt | Main screen titles |
| **Title 1** | Playfair | 28pt | Bold | 34pt | Section headers |
| **Title 2** | Playfair | 22pt | Medium | 28pt | Card titles |
| **Title 3** | Inter | 20pt | SemiBold | 25pt | Subsection headers |
| **Headline** | Inter | 17pt | SemiBold | 22pt | List item titles |
| **Body** | Inter | 17pt | Regular | 22pt | Main content |
| **Callout** | Inter | 16pt | Regular | 21pt | Secondary content |
| **Subhead** | Inter | 15pt | Regular | 20pt | Supporting text |
| **Footnote** | Inter | 13pt | Regular | 18pt | Timestamps, metadata |
| **Caption** | Inter | 12pt | Regular | 16pt | Labels, hints |

---

## Spacing System

Using an 8pt grid system:

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4pt | Tight spacing, icon gaps |
| `sm` | 8pt | Related elements |
| `md` | 16pt | Standard padding |
| `lg` | 24pt | Section spacing |
| `xl` | 32pt | Major sections |
| `xxl` | 48pt | Screen margins, hero spacing |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8pt | Small buttons, tags |
| `md` | 12pt | Cards, input fields |
| `lg` | 16pt | Large cards, modals |
| `full` | 9999pt | Pills, avatars |

---

## Shadows

Subtle, warm shadows that don't feel harsh:

| Level | Shadow | Usage |
|-------|--------|-------|
| **Subtle** | 0 1px 2px rgba(46, 46, 46, 0.05) | Cards at rest |
| **Small** | 0 2px 4px rgba(46, 46, 46, 0.08) | Elevated cards |
| **Medium** | 0 4px 12px rgba(46, 46, 46, 0.10) | Modals, dropdowns |
| **Large** | 0 8px 24px rgba(46, 46, 46, 0.12) | Popovers |

---

## Logo Usage

### Primary Logo
The main logo features:
- Feminine figure in a contemplative pose
- Crescent moon arc with botanical leaf element
- Moon phase dots (representing the cycle)
- "Strength Grace & Flow" wordmark
- "Cycle-Synced Movement" tagline

### Logo Variations Needed

| Variation | Usage |
|-----------|-------|
| **Full Logo** | Welcome screen, about page |
| **Logomark Only** | App icon, small spaces |
| **Wordmark Only** | Navigation header, footer |
| **Monochrome** | On colored backgrounds |

### App Icon Requirements

For the App Store, you'll need the logo in these sizes:
- 1024×1024 (App Store)
- 180×180 (@3x iPhone)
- 120×120 (@2x iPhone)
- 167×167 (iPad Pro)
- 152×152 (iPad)

The logomark (figure + moon, no text) will work best at small sizes.

### Clear Space
Maintain padding equal to the height of the "S" in "Strength" on all sides.

### Don'ts
- Don't stretch or distort
- Don't change colors outside the brand palette
- Don't add effects (shadows, gradients)
- Don't place on busy backgrounds

---

## Native Apple Components Strategy

### Philosophy

We use **native SwiftUI components** exclusively, styled with our brand colors and typography. This gives us:

- **Accessibility** built-in (VoiceOver, Dynamic Type, etc.)
- **Performance** optimized by Apple
- **Familiarity** for users
- **Future-proofing** as iOS evolves
- **Less code** to maintain

We do NOT build custom components from scratch. Instead, we apply view modifiers and environment values to style native components.

---

## Native Components Reference

### Buttons

Use SwiftUI's native `Button` with `.buttonStyle()` modifiers.

```swift
// Primary Button - use .borderedProminent
Button("Start Workout") {
    // action
}
.buttonStyle(.borderedProminent)
.tint(SGFTheme.colors.mutedSage)
.controlSize(.large)

// Secondary Button - use .bordered
Button("View Details") {
    // action
}
.buttonStyle(.bordered)
.tint(SGFTheme.colors.mutedSage)

// Tertiary/Text Button - use .plain or .borderless
Button("Skip") {
    // action
}
.buttonStyle(.borderless)
.foregroundColor(SGFTheme.colors.mutedSage)
```

### Navigation

Use native `NavigationStack` and `TabView`:

```swift
// Tab Bar
TabView {
    TodayView()
        .tabItem {
            Label("Today", systemImage: "sun.horizon.fill")
        }
    
    WorkoutsView()
        .tabItem {
            Label("Workouts", systemImage: "figure.pilates")
        }
    
    CycleView()
        .tabItem {
            Label("Cycle", systemImage: "moon.circle.fill")
        }
    
    ProfileView()
        .tabItem {
            Label("Profile", systemImage: "person.fill")
        }
}
.tint(SGFTheme.colors.mutedSage)

// Navigation
NavigationStack {
    ContentView()
        .navigationTitle("Today")
        .toolbarBackground(SGFTheme.colors.softSand, for: .navigationBar)
}
```

### Lists

Use native `List` with styling:

```swift
List {
    ForEach(workouts) { workout in
        WorkoutRow(workout: workout)
    }
}
.listStyle(.insetGrouped)
.scrollContentBackground(.hidden)
.background(SGFTheme.colors.softSand)
```

### Text Fields

Use native `TextField` and `SecureField`:

```swift
TextField("Email", text: $email)
    .textFieldStyle(.roundedBorder)
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)
    .autocapitalization(.none)

SecureField("Password", text: $password)
    .textFieldStyle(.roundedBorder)
    .textContentType(.password)
```

### Pickers & Selection

```swift
// Segmented Picker
Picker("Intensity", selection: $intensity) {
    Text("Low").tag(Intensity.low)
    Text("Medium").tag(Intensity.medium)
    Text("High").tag(Intensity.high)
}
.pickerStyle(.segmented)

// Date Picker for cycle logging
DatePicker(
    "Period Start Date",
    selection: $periodStart,
    displayedComponents: .date
)
.datePickerStyle(.graphical)
.tint(SGFTheme.colors.mutedSage)
```

### Progress & Loading

```swift
// Progress View
ProgressView()
    .tint(SGFTheme.colors.mutedSage)

// Progress Bar
ProgressView(value: progress, total: 1.0)
    .tint(SGFTheme.colors.mutedSage)
```

### Sheets & Alerts

```swift
// Sheet (half-sheet, full-sheet)
.sheet(isPresented: $showingDetail) {
    WorkoutDetailView(workout: workout)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Confirmation Dialog (preferred over custom modals)
.confirmationDialog("Log Workout", isPresented: $showingOptions) {
    Button("Mark as Complete") { }
    Button("Save for Later") { }
    Button("Cancel", role: .cancel) { }
}

// Alert
.alert("Workout Complete!", isPresented: $showingAlert) {
    Button("OK") { }
} message: {
    Text("Great job honoring your body today.")
}
```

### Toggle & Switches

```swift
Toggle("Enable Notifications", isOn: $notificationsEnabled)
    .tint(SGFTheme.colors.mutedSage)
```

### SF Symbols (Icons)

Use Apple's SF Symbols throughout—they're free, scalable, and match iOS:

```swift
// Common icons for this app
Image(systemName: "figure.pilates")           // Pilates
Image(systemName: "figure.yoga")              // Yoga
Image(systemName: "figure.strengthtraining.traditional")  // Strength
Image(systemName: "figure.barre")             // Barre
Image(systemName: "moon.circle.fill")         // Cycle
Image(systemName: "calendar")                 // Calendar
Image(systemName: "play.fill")                // Play workout
Image(systemName: "clock")                    // Duration
Image(systemName: "flame")                    // Intensity
Image(systemName: "heart.fill")               // Favorites
Image(systemName: "sun.horizon.fill")         // Today/Morning
Image(systemName: "leaf.fill")                // Wellness
```

### Scroll Views & Grids

```swift
// Horizontal scroll for workout cards
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: SGFTheme.spacing.md) {
        ForEach(workouts) { workout in
            WorkoutCard(workout: workout)
        }
    }
    .padding(.horizontal)
}

// Grid for workout library
LazyVGrid(columns: [
    GridItem(.flexible()),
    GridItem(.flexible())
], spacing: SGFTheme.spacing.md) {
    ForEach(workouts) { workout in
        WorkoutCard(workout: workout)
    }
}
```

### Video Playback

Use native `AVKit` for video:

```swift
import AVKit

VideoPlayer(player: AVPlayer(url: videoURL))
    .aspectRatio(16/9, contentMode: .fit)
```

---

## Global App Styling

Apply brand colors globally using environment and appearance settings:

```swift
// In your App file
@main
struct StrengthGraceFlowApp: App {
    init() {
        // Global tint color
        UIView.appearance().tintColor = UIColor(SGFTheme.colors.mutedSage)
        
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(SGFTheme.colors.softSand)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(SGFTheme.colors.deepCharcoal)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(SGFTheme.colors.mutedSage)
        }
    }
}
```

---

## Component Styling Summary

| Component | Native SwiftUI | Brand Customization |
|-----------|---------------|---------------------|
| **Buttons** | `Button` + `.buttonStyle()` | `.tint(mutedSage)` |
| **Navigation** | `NavigationStack`, `TabView` | `.tint()`, `.toolbarBackground()` |
| **Lists** | `List` | `.listStyle(.insetGrouped)`, background color |
| **Text Fields** | `TextField` | `.textFieldStyle(.roundedBorder)` |
| **Toggles** | `Toggle` | `.tint(mutedSage)` |
| **Pickers** | `Picker`, `DatePicker` | `.tint()`, `.pickerStyle()` |
| **Progress** | `ProgressView` | `.tint(mutedSage)` |
| **Sheets** | `.sheet()` | `.presentationDetents()` |
| **Alerts** | `.alert()`, `.confirmationDialog()` | Native styling |
| **Icons** | SF Symbols | Color via `.foregroundColor()` |
| **Video** | `AVKit.VideoPlayer` | Native player |

---

## Cards (The One Custom View)

Cards are the one "custom" element, but they're just styled containers:

```swift
struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: SGFTheme.spacing.sm) {
            // Thumbnail
            AsyncImage(url: URL(string: workout.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(SGFTheme.colors.sandDark)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: SGFTheme.radius.md))
            
            // Info
            VStack(alignment: .leading, spacing: SGFTheme.spacing.xs) {
                Text(workout.title)
                    .font(SGFTheme.typography.headline)
                    .foregroundColor(SGFTheme.colors.text)
                
                HStack {
                    Label("\(workout.duration) min", systemImage: "clock")
                    Label(workout.type.displayName, systemImage: "figure.pilates")
                }
                .font(SGFTheme.typography.caption)
                .foregroundColor(SGFTheme.colors.textSecondary)
            }
            .padding(.horizontal, SGFTheme.spacing.sm)
            .padding(.bottom, SGFTheme.spacing.sm)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SGFTheme.radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
```

---

## Accessibility

Native components give us these for free, but ensure they're not disabled:

```swift
// Support Dynamic Type (automatic with native components)
// Just don't use fixed frame heights on text

// VoiceOver labels for custom elements
Image(systemName: "moon.circle.fill")
    .accessibilityLabel("Cycle phase: Follicular")

// Reduce Motion support
@Environment(\.accessibilityReduceMotion) var reduceMotion
```

---

## Iconography

### Style Guidelines
- Line weight: 1.5pt
- Corner radius: Rounded
- Style: Organic, soft, not overly geometric
- Recommended set: SF Symbols (iOS native) or Phosphor Icons

### Key Icons Needed
- Home / Dashboard
- Workouts / Play
- Calendar / Cycle
- Profile / User
- Settings / Gear
- Search
- Filter
- Heart / Favorite
- Clock / Duration
- Flame / Intensity
- Moon phases (custom)

---

## Dark Mode Considerations

For dark mode (future enhancement), invert the palette:

| Light Mode | Dark Mode |
|------------|-----------|
| Soft Sand `#F6F1EA` | Deep Charcoal `#2E2E2E` |
| White (cards) | `#3A3A3A` |
| Deep Charcoal (text) | `#F6F1EA` |
| Muted Sage | Sage Light `#B5CCC3` |

---

## SwiftUI Implementation

```swift
// Theme.swift

import SwiftUI

struct SGFTheme {
    static let colors = SGFColors()
    static let typography = SGFTypography()
    static let spacing = SGFSpacing()
    static let radius = SGFRadius()
}

// MARK: - Colors

struct SGFColors {
    // Core palette
    let softSand = Color(hex: "F6F1EA")
    let mutedSage = Color(hex: "8FAEA3")
    let warmClay = Color(hex: "C7A89A")
    let deepCharcoal = Color(hex: "2E2E2E")
    
    // Extended
    let sageLight = Color(hex: "B5CCC3")
    let sageDark = Color(hex: "6B8F82")
    let clayLight = Color(hex: "DBC7BD")
    let sandDark = Color(hex: "E8E0D5")
    let charcoalLight = Color(hex: "5A5A5A")
    let charcoalLighter = Color(hex: "8A8A8A")
    
    // Semantic
    var background: Color { softSand }
    var surface: Color { .white }
    var primary: Color { mutedSage }
    var secondary: Color { warmClay }
    var text: Color { deepCharcoal }
    var textSecondary: Color { charcoalLight }
    var textTertiary: Color { charcoalLighter }
    
    // Phase colors
    let phaseMenstrual = Color(hex: "C4A4A4")
    let phaseFollicular = Color(hex: "8FAEA3")
    let phaseOvulatory = Color(hex: "D4B896")
    let phaseLuteal = Color(hex: "B8A4B0")
    
    func phaseColor(_ phase: CyclePhase) -> Color {
        switch phase {
        case .menstrual: return phaseMenstrual
        case .follicular: return phaseFollicular
        case .ovulatory: return phaseOvulatory
        case .luteal: return phaseLuteal
        }
    }
}

// MARK: - Typography

struct SGFTypography {
    // Headlines (Playfair Display)
    let largeTitle = Font.custom("PlayfairDisplay-Bold", size: 34)
    let title1 = Font.custom("PlayfairDisplay-Bold", size: 28)
    let title2 = Font.custom("PlayfairDisplay-Medium", size: 22)
    
    // Body (Inter)
    let title3 = Font.custom("Inter-SemiBold", size: 20)
    let headline = Font.custom("Inter-SemiBold", size: 17)
    let body = Font.custom("Inter-Regular", size: 17)
    let callout = Font.custom("Inter-Regular", size: 16)
    let subhead = Font.custom("Inter-Regular", size: 15)
    let footnote = Font.custom("Inter-Regular", size: 13)
    let caption = Font.custom("Inter-Regular", size: 12)
    
    // Fallback using system fonts (for initial development)
    struct SystemFallback {
        let largeTitle = Font.system(size: 34, weight: .bold, design: .serif)
        let title1 = Font.system(size: 28, weight: .bold, design: .serif)
        let title2 = Font.system(size: 22, weight: .medium, design: .serif)
        let title3 = Font.system(size: 20, weight: .semibold)
        let headline = Font.system(size: 17, weight: .semibold)
        let body = Font.system(size: 17, weight: .regular)
        let callout = Font.system(size: 16, weight: .regular)
        let subhead = Font.system(size: 15, weight: .regular)
        let footnote = Font.system(size: 13, weight: .regular)
        let caption = Font.system(size: 12, weight: .regular)
    }
}

// MARK: - Spacing

struct SGFSpacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
}

// MARK: - Border Radius

struct SGFRadius {
    let sm: CGFloat = 8
    let md: CGFloat = 12
    let lg: CGFloat = 16
    let full: CGFloat = 9999
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## Sample UI Mockup Descriptions

### Home Screen ("Today")
- Background: Soft Sand
- Top: Greeting with user's name, current phase badge
- Phase card: Shows current phase with icon, day of cycle, brief guidance
- "Recommended for You" section with horizontal scroll of workout cards
- Quick filters: Strength, Pilates, Yoga, Barre (pill buttons)

### Workout Card
- 16:9 thumbnail with subtle overlay
- Duration badge (top right)
- Title in Headline font
- Type + intensity in Caption
- Subtle shadow, rounded corners

### Phase Indicator
- Circular progress showing position in cycle
- Current phase highlighted
- Moon phase icon in center
- Tap to see phase details

---

## Asset Checklist

### From Logo File
- [ ] Extract logomark (figure + moon only) for app icon
- [ ] Create app icon in all required sizes
- [ ] Create monochrome version
- [ ] Create horizontal lockup for headers

### To Create
- [ ] Phase icons (4 moon phases)
- [ ] Workout type icons
- [ ] Onboarding illustrations
- [ ] Empty state illustrations
- [ ] Loading animation (subtle, on-brand)
