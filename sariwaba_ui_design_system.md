# SariwaBa — Flutter UI & Design System (`design.md`)

## 1. Brand Overview & Aesthetic Direction

**SariwaBa** is a cross-platform (Flutter Mobile & Web) Fish Freshness Classification application. Derived from the Version 1 brand identity, the UI strikes a balance between **scientific reliability** (accurate AI classification of gills, eyes, and skin) and **friendly usability** (represented by our peeking fish mascot and soft squircle geometry).

* **Target Platforms:** Flutter iOS, Android, and Flutter Web (Responsive).
* **Core Aesthetic:** "Deep Sea Glassmorphism" & Clean Aquatic Minimalism.
* **Vibe:** Fresh, trustworthy, modern, tactile, and effortless.
* **Visual Motif:** Frosted sea-glass cards (`BackdropFilter` + `ImageFilter.blur`) floating over our crisp Version 1 underwater illustration (or blurred dynamically in-app), paired with high-contrast, clinical-grade clarity on camera and inspection views.

---

## 2. Color Palette (`SariwaColors`)

The color system is extracted directly from the Version 1 logo icon, mascot highlights, and underwater environment, plus semantic tokens tailored for freshness classification.

### Primary & Brand Colors (From Version 1 Logo)

| Dart Constant | Hex Code | Flutter `Color` | Usage |
| :--- | :--- | :--- | :--- |
| `brandPrimary` | `#168077` | `Color(0xFF168077)` | Primary `FilledButton`, active states, app icon base teal. |
| `brandPrimaryDark` | `#126B63` | `Color(0xFF126B63)` | Pressed/hover states on primary buttons. |
| `brandLight` | `#A5E6DF` | `Color(0xFFA5E6DF)` | Mascot highlight, secondary badges, subtle borders, hover glows. |
| `brandGlow` | `#39B5A8` | `Color(0xFF39B5A8)` | Accents, `LinearProgressIndicator`, scanner laser line, active switches. |

### Background & Surface Colors (From V1 Underwater Backdrop)

| Dart Constant | Hex Code | Flutter `Color` | Usage |
| :--- | :--- | :--- | :--- |
| `bgAbyssDark` | `#0A2229` | `Color(0xFF0A2229)` | `Scaffold.backgroundColor` (Dark Mode) / deep ocean shadow. |
| `bgLagoonMid` | `#123C46` | `Color(0xFF123C46)` | Elevated `Card` color, `BottomSheet` surface. |
| `bgFoamLight` | `#F2F9F9` | `Color(0xFFF2F9F9)` | `Scaffold.backgroundColor` (Light Mode — clinical ice-mint). |
| `surfaceGlass` | `#123C46` (65%) | `Color(0xA6123C46)` | Glassmorphic container fill over the underwater background asset. |
| `borderGlass` | `#A5E6DF` (22%) | `Color(0x38A5E6DF)` | `1.5` logical pixel `Border.all()` on frosted glass cards. |

### Semantic Colors (Freshness Classification Tiers)

| Classification | Dart Constant | Flutter `Color` | Badge / UI Meaning |
| :--- | :--- | :--- | :--- |
| **Sariwa (Very Fresh)** | `statusFresh` | `Color(0xFF10B981)` | Emerald Green — Clear eyes, bright red gills, firm scales. |
| **Katamtaman (Moderate)** | `statusModerate` | `Color(0xFFF59E0B)` | Amber Gold — Consume soon, slight cloudiness. |
| **Hindi Sariwa (Spoiled)** | `statusSpoiled` | `Color(0xFFEF4444)` | Coral Red — Do not consume, sunken eyes, off-color gills. |
| **Scanning / Info** | `statusInfo` | `Color(0xFF06B6D4)` | Cyan — TFLite / API processing or neutral tips. |

---

## 3. Typography (`google_fonts` Package)

To match the bold, friendly, rounded sans-serif lettering in the **SariwaBa** wordmark while keeping data tables and confidence scores crisp, use the `google_fonts` Flutter package.

* **Heading & Brand Font:** `GoogleFonts.fredoka()` or `GoogleFonts.nunito()` (`FontWeight.w700` – `FontWeight.w800`)
  * *Why:* Echoes the soft, approachable curves of the "SariwaBa" logo text.
* **Body & UI Data Font:** `GoogleFonts.plusJakartaSans()` or `GoogleFonts.inter()` (`w400`, `w500`, `w600`)
  * *Why:* High legibility for percentages, fish species names, and freshness metrics across mobile and web.
* **Monospace (Confidence Scores / Metrics):** `GoogleFonts.jetBrainsMono()`

### Flutter `TextTheme` Scale (Logical Pixels `sp`/`dp`)

| Material 3 Role | Size | Height | Weight | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `displayLarge` | `36.0` | `1.15` | `FontWeight.w800` | Web Hero title / Splash screen header. |
| `headlineLarge` | `28.0` | `1.20` | `FontWeight.w700` | Main Screen AppBar / Header title. |
| `titleLarge` | `22.0` | `1.30` | `FontWeight.w700` | Fish Species Name (e.g., *Bangus*, *Galunggong*). |
| `titleMedium` | `18.0` | `1.40` | `FontWeight.w600` | Card Titles & Modal Headers. |
| `bodyLarge` | `16.0` | `1.50` | `FontWeight.w400` | Primary descriptions & inspection instructions. |
| `labelMedium` | `14.0` | `1.40` | `FontWeight.w600` | Metadata, pill badges, and sensor confidence labels. |

---

## 4. Layout, Responsive Breakpoints & Squircle Geometry

The Version 1 logo icon uses a smooth **squircle (super-ellipse)** corner shape. In Flutter, standard `BorderRadius.circular` can look slightly harsh compared to our icon, so we use `ContinuousRectangleBorder` or standard `BorderRadius` tokens where appropriate.

### Geometry & Shape Tokens

* **Small Elements (`radiusSm`):** `BorderRadius.circular(8.0)` — Tags, small pills, inner thumbnails.
* **Buttons & Inputs (`radiusMd`):** `BorderRadius.circular(16.0)` — `FilledButton`, `TextField`, alert banners.
* **Cards & Modals (`radiusLg`):** `BorderRadius.circular(24.0)` or `ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0))` — Classification result cards, bottom sheets, app icon frame.
* **Pills & FAB (`radiusFull`):** `StadiumBorder()` — Floating action buttons, status pills.

### Responsive Breakpoints (`LayoutBuilder` / `MediaQuery`)

Since SariwaBa targets both **Flutter Mobile** and **Flutter Web**:
* **Mobile (`< 600px`):** Single-column portrait layout, bottom navigation bar (`NavigationBar`), full-screen camera preview, draggable bottom sheet for results.
* **Tablet (`600px – 1024px`):** Centered constrained content (`ConstrainedBox(maxWidth: 720)`), 2-column grid for recent scans.
* **Web / Desktop (`> 1024px`):** Split-view dashboard (`Row` with `NavigationRail` on the left, live camera/upload dropzone on the center-left, and real-time classification breakdown card on the right).

---

## 5. Core Flutter Widgets (SariwaBa Specific)

### 5.1. The Underwater Hero / Background `Stack`

* Uses the **Version 1 unblurred background** (`assets/images/bg_underwater_v1.jpg`) inside a `Stack`.
* **Dynamic Blur:** Wrap foreground screens in a `BackdropFilter` with `ImageFilter.blur(sigmaX: 12, sigmaY: 12)` when transitioning from the splash/home screen into the inspection dashboard so you only need to bundle **one** background image asset.
* **Readability Overlay:** Place a `DecoratedBox` with a `RadialGradient` (`Colors.transparent` to `Color(0xB30A2229)`) so white text always passes contrast checks.

### 5.2. "Scan Fish" Camera Viewfinder (`CameraPreview` + `CustomPaint`)

* **Frame:** A `CustomPainter` drawing 4 glowing corner brackets in `SariwaColors.brandLight` (`#A5E6DF`) with `StrokeCap.round` and a `MaskFilter.blur(BlurStyle.outer, 6)`.
* **Target Guides:** Semi-transparent `Chip` widgets prompting the user where to align the fish (*"Align Eye & Gills Here"*).
* **Scanning Animation:** An `AnimatedBuilder` driven by a repeating `AnimationController` moving a horizontal gradient `Container` (`#39B5A8` with `BoxShadow` glow) smoothly up and down over the fish image during inference.

### 5.3. Freshness Classification Result Card (`SariwaGlassCard`)

* **Header:** `Row` displaying the detected fish species alongside a custom `FreshnessBadge` widget:
  * **Sariwa (Fresh):** `Color(0xFF10B981).withValues(alpha: 0.15)` fill, `Color(0xFF34D399)` text, and `Icons.auto_awesome_rounded`.
* **Confidence Gauge:** `TweenAnimationBuilder<double>` animating a custom circular arc (`CustomPainter` or `CircularProgressIndicator`) showing the AI confidence score (e.g., `96.4% Sariwa`).
* **Feature Breakdown Grid:** Responsive `Wrap` or 3-column `Row` of mini metric cards:
  1. **Mata (Eyes):** *Clear & Bulging*
  2. **Hasang (Gills):** *Bright Red*
  3. **Kaliskis (Scales/Skin):** *Firm & Shiny*

### 5.4. Mascot Micro-Interactions ("Peeking Fish")

* **Empty States / Onboarding:** Position the isolated mascot inside a `Stack` using `Positioned(bottom: -8, left: 20)` with `ClipRRect` so the fish peeks up from the bottom edge of instruction cards.
* **Loading State:** Use `AnimatedSlide` or `rive` / `flutter_animate` to gently bob the mascot while the model classifies the fish photo.

---

## 6. Ready-to-Use Flutter Theme & Glass Widget (`sariwa_theme.dart`)

Drop this directly into your Flutter project's `lib/theme/sariwa_theme.dart` file:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SariwaColors {
  // Brand Colors (Version 1)
  static const Color brandPrimary = Color(0xFF168077);
  static const Color brandPrimaryHover = Color(0xFF126B63);
  static const Color brandLight = Color(0xFFA5E6DF);
  static const Color brandGlow = Color(0xFF39B5A8);

  // Backgrounds & Surfaces
  static const Color bgAbyssDark = Color(0xFF0A2229);
  static const Color bgLagoonMid = Color(0xFF123C46);
  static const Color bgFoamLight = Color(0xFFF2F9F9);
  static const Color surfaceGlass = Color(0xA6123C46); // 65% opacity
  static const Color borderGlass = Color(0x38A5E6DF);  // 22% opacity

  // Text
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFFB8DFDC);
  static const Color textPrimaryDark = Color(0xFF0A2229);

  // Freshness Classification Tiers
  static const Color statusFresh = Color(0xFF10B981);
  static const Color statusModerate = Color(0xFFF59E0B);
  static const Color statusSpoiled = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF06B6D4);
}

class SariwaTheme {
  static ThemeData get darkOceanTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SariwaColors.bgAbyssDark,
      colorScheme: const ColorScheme.dark(
        primary: SariwaColors.brandPrimary,
        secondary: SariwaColors.brandGlow,
        surface: SariwaColors.bgLagoonMid,
        error: SariwaColors.statusSpoiled,
        onPrimary: Colors.white,
        onSecondary: SariwaColors.bgAbyssDark,
        onSurface: SariwaColors.textPrimaryLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: SariwaColors.textPrimaryLight,
          height: 1.15,
        ),
        headlineLarge: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SariwaColors.textPrimaryLight,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: SariwaColors.textPrimaryLight,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: SariwaColors.textPrimaryLight,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: SariwaColors.textSecondaryLight,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SariwaColors.brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SariwaColors.bgLagoonMid,
        elevation: 0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Smooth squircle
          side: const BorderSide(color: SariwaColors.borderGlass, width: 1.5),
        ),
      ),
    );
  }
}

/// Reusable Frosted Sea-Glass Container for SariwaBa Web & Mobile
class SariwaGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const SariwaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: SariwaColors.surfaceGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: SariwaColors.borderGlass,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: SariwaColors.bgAbyssDark.withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```