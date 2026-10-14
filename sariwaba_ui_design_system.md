# SariwaBa — Frontend UI & Design System (`design.md`)

## 1. Brand Overview & Aesthetic Direction

**SariwaBa** is a modern, approachable Fish Freshness Classification application. Derived from the Version 1 brand identity, the UI strikes a balance between **scientific reliability** (accurate AI classification of gills, eyes, and skin) and **friendly usability** (represented by our peeking fish mascot and soft rounded geometry).

- **Core Aesthetic:** "Deep Sea Glassmorphism" & Clean Aquatic Minimalism.
- **Vibe:** Fresh, trustworthy, modern, tactile, and effortless.
- **Visual Motif:** Frosted sea-glass cards floating over a calm, blurred underwater backdrop (for hero/onboarding screens) paired with high-contrast, clinical-grade clarity on inspection and camera views.

---

## 2. Color Palette

The color system is extracted directly from the Version 1 logo icon, mascot highlights, and underwater environment, plus semantic tokens tailored for freshness classification.

### Primary & Brand Colors (From Version 1 Logo)

| Token Name              | Hex Code  | RGB                  | Usage                                                            |
| :---------------------- | :-------- | :------------------- | :--------------------------------------------------------------- |
| `--color-brand-primary` | `#168077` | `rgb(22, 128, 119)`  | Primary buttons, active states, app icon base teal.              |
| `--color-brand-light`   | `#A5E6DF` | `rgb(165, 230, 223)` | Mascot highlight, secondary badges, subtle borders, hover glows. |
| `--color-brand-glow`    | `#39B5A8` | `rgb(57, 181, 168)`  | Accents, progress bars, scanner laser lines, active toggles.     |

### Background & Surface Colors (From V1 Underwater Backdrop)

| Token Name        | Hex Code                 | Usage                                                                                    |
| :---------------- | :----------------------- | :--------------------------------------------------------------------------------------- |
| `--bg-abyss-dark` | `#0A2229`                | Primary dark mode background / deep ocean shadow.                                        |
| `--bg-lagoon-mid` | `#123C46`                | Elevated card background (dark mode), modal surfaces.                                    |
| `--bg-foam-light` | `#F2F9F9`                | Primary light mode background (clean, clinical ice-white/mint).                          |
| `--surface-glass` | `rgba(18, 60, 70, 0.65)` | Glassmorphic cards over the underwater background image (`backdrop-filter: blur(16px)`). |

### Semantic Colors (Freshness Classification Tiers)

| Classification             | Token Name          | Hex Code  | Badge / UI Meaning                                         |
| :------------------------- | :------------------ | :-------- | :--------------------------------------------------------- |
| **Sariwa (Very Fresh)**    | `--status-fresh`    | `#10B981` | Emerald Green — Clear eyes, bright red gills, firm scales. |
| **Katamtaman (Moderate)**  | `--status-moderate` | `#F59E0B` | Amber Gold — Consume soon, slight cloudiness.              |
| **Hindi Sariwa (Spoiled)** | `--status-spoiled`  | `#EF4444` | Coral Red — Do not consume, sunken eyes, off-color gills.  |
| **Scanning / Info**        | `--status-info`     | `#06B6D4` | Cyan — AI processing or neutral tips.                      |

---

## 3. Typography

To match the bold, friendly, rounded sans-serif lettering in the **SariwaBa** wordmark while keeping data tables and confidence scores crisp, we pair a rounded display font with a clean geometric sans-serif.

- **Heading & Brand Font:** `'Fredoka'`, `'Nunito'`, or `'Plus Jakarta Sans'` (Bold / ExtraBold, `700`–`800`)
  - _Why:_ Echoes the soft, approachable curves of the "SariwaBa" logo text.
- **Body & UI Data Font:** `'Inter'` or `'DM Sans'` (Regular `400`, Medium `500`, SemiBold `600`)
  - _Why:_ High legibility for percentages, fish species names, and freshness metrics.
- **Monospace (Confidence Scores / Metrics):** `'JetBrains Mono'`

### Type Scale (Mobile-First)

- **Display / Hero Title:** `2.25rem` (36px) | Line-height: `1.15` | Weight: `800`
- **H1 (Screen Title):** `1.75rem` (28px) | Line-height: `1.2` | Weight: `700`
- **H2 (Section / Fish Name):** `1.375rem` (22px) | Line-height: `1.3` | Weight: `700`
- **H3 (Card Title):** `1.125rem` (18px) | Line-height: `1.4` | Weight: `600`
- **Body Regular:** `1rem` (16px) | Line-height: `1.5` | Weight: `400`
- **Caption / Metadata:** `0.875rem` (14px) | Line-height: `1.4` | Weight: `500`

---

## 4. Layout, Spacing & Geometry

The Version 1 logo icon uses a generous **squircle (super-ellipse)** border radius. All UI containers should mirror this soft geometry.

- **Border Radius System:**
  - `--radius-sm`: `8px` (Tags, small pills, inner thumbnails)
  - `--radius-md`: `16px` (Buttons, input fields, alert banners)
  - `--radius-lg`: `24px` (Classification result cards, bottom sheets, app icon frame)
  - `--radius-full`: `9999px` (Floating action buttons, status pills)
- **Elevation & Shadows:**
  - `--shadow-soft`: `0 10px 25px -5px rgba(10, 34, 41, 0.25)`
  - `--shadow-glow`: `0 0 20px rgba(57, 181, 168, 0.35)` (Used on the primary "Scan Fish" CTA button)
- **Grid & Spacing:**
  - Base unit: `8px` (`0.5rem`).
  - Standard screen padding: `20px` (`1.25rem`) on mobile, `32px` (`2rem`) on tablet/desktop.

---

## 5. Core UI Components (SariwaBa Specific)

### 5.1. The Underwater Hero / Splash Container

- Uses the **Version 1 separated background** (`background-size: cover; background-position: center`).
- Overlay a subtle radial vignette (`radial-gradient(circle, transparent 40%, rgba(10,34,41,0.7) 100%)`) so white typography (`#FFFFFF`) always passes WCAG AA contrast requirements.

### 5.2. "Scan Fish" Camera Viewfinder

- **Frame:** Rounded rectangle (`24px` radius) with 4 glowing corner brackets in `--color-brand-light` (`#A5E6DF`).
- **Target Guides:** Subtle pill-shaped overlays prompting the user where to align the fish (e.g., _"Align Eye & Gills Here"_).
- **Scanning Animation:** A horizontal gradient line (`#39B5A8` with a soft glow) sweeping gently up and down while the model classifies the image.

### 5.3. Freshness Classification Result Card

- **Header:** Displays the fish species (e.g., _Galunggong / Bangus / Tilapia_) alongside a prominent **Freshness Pill Badge**:
  - **Sariwa (Fresh):** `#10B981` background at 15% opacity, `#34D399` text, with a sparkle icon.
- **Confidence Gauge:** A circular or semi-circular progress arc showing the AI confidence score (e.g., `96.4% Sariwa`).
- **Feature Breakdown Grid (3 Columns):**
  1. **Mata (Eyes):** _Clear & Bulging_
  2. **Hasang (Gills):** _Bright Red_
  3. **Kaliskis (Scales/Skin):** _Firm & Shiny_

### 5.4. Mascot Micro-Interactions ("Peeking Fish")

- Inspired by how the fish peeks out of the lower-left corner of the Version 1 app icon:
  - **Empty States / Onboarding:** The mascot peeks up from the bottom of the card with a helpful tooltip (_"Snap a clear photo of the fish's eye and gills under good lighting!"_).
  - **Loading State:** The mascot's big eyes subtly look left and right while the AI analyzes the photo.

---

## 6. Ready-to-Use CSS Variables (Starter Snippet)

```css
:root {
  /* Brand Colors (Version 1) */
  --color-brand-primary: #168077;
  --color-brand-primary-hover: #126b63;
  --color-brand-light: #a5e6df;
  --color-brand-glow: #39b5a8;

  /* Backgrounds & Surfaces */
  --bg-abyss-dark: #0a2229;
  --bg-lagoon-mid: #123c46;
  --bg-foam-light: #f2f9f9;
  --surface-glass: rgba(18, 60, 70, 0.65);
  --border-glass: rgba(165, 230, 223, 0.22);

  /* Text */
  --text-primary-light: #ffffff;
  --text-secondary-light: #b8dfdc;
  --text-primary-dark: #0a2229;

  /* Freshness Status */
  --status-fresh: #10b981;
  --status-moderate: #f59e0b;
  --status-spoiled: #ef4444;

  /* Geometry */
  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-full: 9999px;
}
```
