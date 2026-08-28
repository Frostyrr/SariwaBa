# 🐟 SariwaBa? — Fish Freshness Classification System

[![React](https://img.shields.io/badge/React-19.x-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-v4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![Vite](https://img.shields.io/badge/Vite-8.x-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)

> **SariwaBa?** (*"Is it fresh?"*) is an intelligent seafood quality assessment platform powered by deep learning and computer vision. The system provides instantaneous, standardized freshness ratings by analyzing visual cues such as eye cornea clarity, branchial gill pigmentation, and body surface texture.

---

## 📸 System Highlights

- **⚡ Instant AI Inference:** Rapid image evaluation in under 300ms.
- **👁️ Sensory Detection:** Multi-feature inspection assessing eye cloudiness, gill redness, and scale sheen.
- **📊 Standardized Grading:** Clear, objective classification metrics:
  - 🟢 **Grade A (Fresh)**
  - 🟡 **Grade B (Moderate)**
  - 🔴 **Grade C (Spoiled)**
- **🔐 Direct Social Authentication:** 1-click authentication with Google and GitHub OAuth.
- **🗃️ Permanent Scan Archive:** Account holders maintain complete lifetime scan histories, quality trends, and exportable audit logs (with instant guest access for trial evaluations).
- **🎛️ Mock Admin Dashboard:** Full monitoring suite featuring live telemetry, volume analytics, sensory precision benchmarks, and a user directory.

---

## 🏗️ Repository Architecture

This repository is organized into three main component workspaces:

```text
SariwaBa/
├── web/                   # Web platform (React 19, TypeScript, Tailwind CSS v4, Vite)
│   ├── src/
│   │   ├── admin/         # Admin dashboard (Overview, Analytics, Classifications, Users)
│   │   ├── components/    # Reusable UI widgets, Navbar, and Footer
│   │   ├── pages/         # Public routes: Landing Page, Login, Register
│   │   └── index.css      # Tailwind CSS v4 styling with geometric graph grid
│   └── vite.config.ts
├── mobile/                # Mobile application (Flutter / Dart)
└── backend/               # Machine learning inference API & Python pipeline
```

---

## 🌐 Web Application Routes

| Route | Description |
| :--- | :--- |
| **`/`** | Public landing page featuring the Hero camera viewfinder scaffold, Features, How It Works, and Scan Logs. |
| **`/login`** | Direct Google and GitHub sign-in page with scan history preservation benefits. |
| **`/register`** | Account creation page with social signup options. |
| **`/admin`** | Interactive Admin Dashboard with live telemetry, analytics visualizers, scan database, and user management. |

---

## 🚀 Getting Started (Web Platform)

### Prerequisites
- **Node.js** (v18.0 or higher recommended)
- **npm** (v9.0 or higher)

### 1. Installation
Navigate to the web workspace and install the dependencies:
```bash
cd web
npm install
```

### 2. Development Server
Start the local Vite development server:
```bash
npm run dev
```
Open your browser at `http://localhost:5173`.

### 3. Production Build & Linting
```bash
# Type check and build production bundle
npm run build

# Run ESLint validation
npm run lint

# Preview production build
npm run preview
```

---

## 🎨 UI/UX Design System

- **Aesthetic:** Minimalist, high-contrast, technical grid aesthetic inspired by modern creative tech studios.
- **Color Palette:**
  - **Electric Blue:** `#0066ff` (Primary actions, active highlights, key metrics)
  - **Deep Charcoal / Black:** `#090a0f` / `#0c0d0e` (Typography, dark cards, badges)
  - **Paper Background:** `#fbfbfb` with delicate geometric 32px line grid
  - **Grade Badges:** Emerald (`#10b981`), Amber (`#f59e0b`), Rose (`#f43f5e`)
- **Typography:**
  - **Headings:** Grotesque ultra-bold display (`Plus Jakarta Sans`, heavy uppercase tracking)
  - **Interface & Body:** `Inter` for clean legibility and micro-copy

---

## 🛠️ Technology Stack

| Layer | Technologies |
| :--- | :--- |
| **Web Frontend** | React 19, TypeScript, Tailwind CSS v4, Vite 8, React Router v7, Lucide Icons |
| **Mobile App** | Flutter, Dart |
| **Backend & ML** | Python, Computer Vision, Deep Learning (Eye/Gill Classification) |
| **Tooling** | ESLint, Vite, TypeScript Compiler |

---

## 📄 License

This project is licensed under the MIT License.