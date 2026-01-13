# Strength Grace & Flow - Design System Context

## Brand Foundation

### Brand Essence
- **Core Idea:** Cyclical strength for feminine bodies
- **Emotional Feel:** Calm, grounded, nurturing, confident
- **Brand Promise:** Support your body through every phase

### Voice & Tone
- Gentle, grounded, supportive
- Educational, never shaming
- Feminine strength over intensity

## Color Palette

### Core Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Soft Sand** | `#F6F1EA` | Backgrounds, cards |
| **Deep Charcoal** | `#2E2E2E` | Primary text |
| **Deep Terracotta** | `#B35C44` | Primary accents, buttons, active states |
| **Dusty Blue** | `#6F8F9B` | Secondary accents, calm elements |
| **Soft Clay Neutral** | `#D8B8A6` | Tertiary accents, highlights |

### Extended Palette

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

| Phase | Color | Hex | Rationale |
|-------|-------|-----|-----------|
| **Menstrual** | Deep Terracotta | `#B35C44` | Warm, grounding, restful |
| **Follicular** | Dusty Blue | `#6F8F9B` | Growth, calm renewal, rising energy |
| **Ovulatory** | Soft Clay Neutral | `#D8B8A6` | Peak warmth, gentle vitality |
| **Luteal** | Blue-Clay Blend | `#9B9A9A` | Winding down, balanced introspection |

## Typography

### Font Stack

**Headlines:** Playfair Display
- Elegant, feminine serif
- Use for: Screen titles, section headers
- Weights: Regular (400), Medium (500), Bold (700)

**Body:** Inter
- Clean, highly readable sans-serif
- Use for: Body text, buttons, labels, UI elements
- Weights: Regular (400), Medium (500), SemiBold (600)

### Type Scale

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| **Large Title** | Playfair | 34pt | Bold | Main screen titles |
| **Title 1** | Playfair | 28pt | Bold | Section headers |
| **Title 2** | Playfair | 22pt | Medium | Card titles |
| **Title 3** | Inter | 20pt | SemiBold | Subsection headers |
| **Headline** | Inter | 17pt | SemiBold | List item titles |
| **Body** | Inter | 17pt | Regular | Main content |
| **Callout** | Inter | 16pt | Regular | Secondary content |
| **Subhead** | Inter | 15pt | Regular | Supporting text |
| **Footnote** | Inter | 13pt | Regular | Timestamps, metadata |
| **Caption** | Inter | 12pt | Regular | Labels, hints |

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

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8pt | Small buttons, tags |
| `md` | 12pt | Cards, input fields |
| `lg` | 16pt | Large cards, modals |
| `full` | 9999pt | Pills, avatars |

## Shadows

Subtle, warm shadows that don't feel harsh:

| Level | Shadow | Usage |
|-------|--------|-------|
| **Subtle** | 0 1px 2px rgba(46, 46, 46, 0.05) | Cards at rest |
| **Small** | 0 2px 4px rgba(46, 46, 46, 0.08) | Elevated cards |
| **Medium** | 0 4px 12px rgba(46, 46, 46, 0.10) | Modals, dropdowns |
| **Large** | 0 8px 24px rgba(46, 46, 46, 0.12) | Popovers |

## Native Components Strategy

### Philosophy

Use **native SwiftUI components exclusively**, styled with brand colors and typography:

- Built-in accessibility (VoiceOver, Dynamic Type)
- Optimized performance
- User familiarity
- Future-proof as iOS evolves
- Less code to maintain

DO NOT build custom components from scratch. Instead, apply view modifiers and environment values to native components.

### Component Reference

#### Buttons

```swift
// Primary Button
Button("Start Workout") { }
    .buttonStyle(.borderedProminent)
    .tint(SGFTheme.colors.deepTerracotta)
    .controlSize(.large)

// Secondary Button
Button("View Details") { }
    .buttonStyle(.bordered)
    .tint(SGFTheme.colors.deepTerracotta)

// Text Button
Button("Skip") { }
    .buttonStyle(.borderless)
    .foregroundColor(SGFTheme.colors.deepTerracotta)
```

#### Navigation

```swift
// Tab Bar
TabView {
    TodayView()
        .tabItem { Label("Today", systemImage: "sun.horizon.fill") }
    WorkoutsView()
        .tabItem { Label("Workouts", systemImage: "figure.pilates") }
    CycleView()
        .tabItem { Label("Cycle", systemImage: "moon.circle.fill") }
    ProfileView()
        .tabItem { Label("Profile", systemImage: "person.fill") }
}
.tint(SGFTheme.colors.deepTerracotta)

// Navigation Stack
NavigationStack {
    ContentView()
        .navigationTitle("Today")
        .toolbarBackground(SGFTheme.colors.softSand, for: .navigationBar)
}
```

#### Lists

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

#### Text Fields

```swift
TextField("Email", text: $email)
    .textFieldStyle(.roundedBorder)
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)

SecureField("Password", text: $password)
    .textFieldStyle(.roundedBorder)
    .textContentType(.password)
```

#### Pickers

```swift
// Segmented Picker
Picker("Intensity", selection: $intensity) {
    Text("Low").tag(Intensity.low)
    Text("Medium").tag(Intensity.medium)
    Text("High").tag(Intensity.high)
}
.pickerStyle(.segmented)

// Date Picker
DatePicker("Period Start", selection: $periodStart, displayedComponents: .date)
    .datePickerStyle(.graphical)
    .tint(SGFTheme.colors.deepTerracotta)
```

#### Progress Indicators

```swift
ProgressView()
    .tint(SGFTheme.colors.deepTerracotta)

ProgressView(value: progress, total: 1.0)
    .tint(SGFTheme.colors.deepTerracotta)
```

#### Sheets & Alerts

```swift
// Sheet (half-sheet or full)
.sheet(isPresented: $showingDetail) {
    WorkoutDetailView(workout: workout)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Confirmation Dialog
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

#### Toggle

```swift
Toggle("Enable Notifications", isOn: $notificationsEnabled)
    .tint(SGFTheme.colors.deepTerracotta)
```

#### SF Symbols (Icons)

```swift
// Common icons for this app
Image(systemName: "figure.pilates")           // Pilates
Image(systemName: "figure.yoga")              // Yoga
Image(systemName: "figure.strengthtraining.traditional")  // Strength
Image(systemName: "moon.circle.fill")         // Cycle
Image(systemName: "calendar")                 // Calendar
Image(systemName: "play.fill")                // Play workout
Image(systemName: "clock")                    // Duration
Image(systemName: "flame")                    // Intensity
Image(systemName: "heart.fill")               // Favorites
Image(systemName: "sun.horizon.fill")         // Today/Morning
Image(systemName: "leaf.fill")                // Wellness
```

## Voice & Tone Guidelines

### Voice Pillars

**Strength** - Empowering, confident, supportive
**Grace** - Gentle, elegant, respectful
**Flow** - Natural, rhythmic, harmonious

### Tone Characteristics

#### What We Are
- Gentle - soft, warm, caring
- Reflective - thoughtful, mindful, present
- Natural - organic language, not clinical
- Wise - knowledgeable without being preachy
- Minimal - clear and concise, not over-explaining
- Neutral - inclusive of all life stages and goals

#### What We're Not
- Clinical or medical-sounding
- Overly cheerful or enthusiastic
- Cutesy or using slang
- Assumptive about reproductive goals
- Anxious or fear-based
- Rushed or transactional

### Core Vocabulary

Words that align with our brand:
- balance, harmony, rhythm, alignment, flow
- cycle, energy, patterns, awareness, wisdom

### Universal & Inclusive Terms

- "Your cycle" (not "fertility window" unless contextually appropriate)
- "Energy levels" (neutral, universally relevant)
- "Your body's rhythm" (inclusive, empowering)
- "Day 1" or "start of your cycle" (clear, neutral)

### Writing Style Examples

#### ❌ Too Clinical
"Did your menstrual period begin today?"

#### ✅ Gentle & Natural
"Is today day 1 of your cycle?"

---

#### ❌ Assumptive
"You're in your fertile window - time to conceive!"

#### ✅ Neutral & Informative
"You're in your mid-cycle phase"

---

### Context-Specific Guidance

**Onboarding & Education**
- Keep explanations minimal and grounded
- Focus on awareness over optimization
- "Your cycle has four phases, each with its own energy"

**Daily Check-ins**
- Gentle, present-moment language
- "How's your energy today?"
- "Notice any changes?"

**Data & Insights**
- Reflective, observational tone
- "You tend to feel more energized during this phase"

**Errors & Empty States**
- Supportive, never scolding
- "When you're ready, log your first entry"

**Notifications**
- Soft reminders, never demanding
- "Time for your evening reflection"
- "Your cycle may begin in the next few days"

## User Persona

### Demographics
- Age: 22-45 years old
- Life stages: Pre-pregnancy, TTC, postpartum, hormonal changes
- All navigating different phases of their hormonal journey

### What They Need
- A tranquil space to achieve physiological goals
- Respectful language that honors their journey
- Empowerment through clarity, not overwhelming data
- Universal inclusivity regardless of reproductive goals

### How They Want to Feel
- Supported - like they have a wise friend
- Peaceful - this is a calm, gentle space
- Empowered - learning about their own body
- Seen - their unique journey is valid
- Balanced - in harmony with natural rhythms

## Accessibility

Native components provide accessibility for free:

```swift
// Support Dynamic Type (automatic with native components)
// Just don't use fixed frame heights on text

// VoiceOver labels for custom elements
Image(systemName: "moon.circle.fill")
    .accessibilityLabel("Cycle phase: Follicular")

// Reduce Motion support
@Environment(\.accessibilityReduceMotion) var reduceMotion
```

## SwiftUI Theme Implementation

```swift
struct SGFTheme {
    static let colors = SGFColors()
    static let typography = SGFTypography()
    static let spacing = SGFSpacing()
    static let radius = SGFRadius()
}

struct SGFColors {
    let softSand = Color(hex: "F6F1EA")
    let deepCharcoal = Color(hex: "2E2E2E")
    let deepTerracotta = Color(hex: "B35C44")
    let dustyBlue = Color(hex: "6F8F9B")
    let softClayNeutral = Color(hex: "D8B8A6")

    // Semantic colors
    var background: Color { softSand }
    var surface: Color { .white }
    var primary: Color { deepTerracotta }
    var secondary: Color { dustyBlue }
    var text: Color { deepCharcoal }

    // Phase colors
    func phaseColor(_ phase: CyclePhase) -> Color {
        switch phase {
        case .menstrual: return deepTerracotta
        case .follicular: return dustyBlue
        case .ovulatory: return softClayNeutral
        case .luteal: return Color(hex: "9B9A9A")
        }
    }
}

struct SGFSpacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
}

struct SGFRadius {
    let sm: CGFloat = 8
    let md: CGFloat = 12
    let lg: CGFloat = 16
    let full: CGFloat = 9999
}
```

## Component Styling Summary

| Component | Native SwiftUI | Brand Customization |
|-----------|---------------|---------------------|
| **Buttons** | `Button` + `.buttonStyle()` | `.tint(deepTerracotta)` |
| **Navigation** | `NavigationStack`, `TabView` | `.tint()`, `.toolbarBackground()` |
| **Lists** | `List` | `.listStyle(.insetGrouped)`, background |
| **Text Fields** | `TextField` | `.textFieldStyle(.roundedBorder)` |
| **Toggles** | `Toggle` | `.tint(deepTerracotta)` |
| **Pickers** | `Picker`, `DatePicker` | `.tint()`, `.pickerStyle()` |
| **Progress** | `ProgressView` | `.tint(deepTerracotta)` |
| **Sheets** | `.sheet()` | `.presentationDetents()` |
| **Icons** | SF Symbols | `.foregroundColor()` |

## Cards (Custom View Example)

Cards are the one custom element, but they're just styled containers:

```swift
struct WorkoutCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: SGFTheme.spacing.sm) {
            AsyncImage(url: URL(string: workout.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle().fill(SGFTheme.colors.softSand)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: SGFTheme.radius.md))

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
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SGFTheme.radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
```

## Testing Copy Against Brand Voice

Before finalizing user-facing text, ask:

1. Does this sound like a wise friend? (not a doctor, not an app)
2. Is it gentle and reflective? (not rushed or clinical)
3. Does it work for all users? (regardless of age or reproductive goals)
4. Does it use our core vocabulary? (balance, rhythm, harmony)
5. Is it minimal? (could we say it in fewer words?)

If the answer to any is "no," revise.
