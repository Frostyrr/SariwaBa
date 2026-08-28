# 🌐 SariwaBa? Web Application

The modern web client for the **SariwaBa? Fish Freshness Classification System**, built with **React 19**, **TypeScript**, **Tailwind CSS v4**, and **Vite**.

---

## ⚡ Features

- **Symph-Inspired Visual Interface:** Clean graph grid paper texture (`#fbfbfb`), bold grotesque typography (`Plus Jakarta Sans`), and vibrant electric blue accents (`#0066ff`).
- **Landing Page Experience:**
  - 2-Column Hero section with camera & image upload viewfinder scaffold.
  - Interactive Features showcase highlighting AI capabilities.
  - 3-Step "How It Works" workflow guide.
  - Interactive Scan History log cards with sensory indicator breakdowns.
- **Direct Social Authentication:**
  - Direct 1-click **Google OAuth** & **GitHub OAuth** sign-in and sign-up flows.
  - Value callout for lifetime scan history preservation over temporary guest logs.
- **Interactive Admin Dashboard (`/admin`):**
  - **Overview:** Real-time KPI cards, live inference feed, and GPU/latency telemetry.
  - **Analytics:** Weekly scan volume visualizer, freshness distribution metrics, sensory model precision, and species breakdown.
  - **Classifications:** Searchable database with grade filters and deep inspection modal.
  - **Users Directory:** Role-based identity management (Inspectors, Vendors, Consumers, Admins).

---

## 📦 Scripts

| Command | Description |
| :--- | :--- |
| `npm run dev` | Starts the Vite development server with Hot Module Replacement (HMR) |
| `npm run build` | Compiles TypeScript and builds production-ready bundles in `dist/` |
| `npm run lint` | Runs ESLint over all `.ts` and `.tsx` source files |
| `npm run preview` | Locally serves the production `dist/` build |

---

## 📂 Project Structure

```text
web/
├── public/
│   └── SariwaBaLogo.png
├── src/
│   ├── admin/
│   │   └── dashboard/
│   │       └── pages/
│   │           ├── Dashboard.tsx        # Admin shell & sidebar
│   │           └── sections/
│   │               ├── Overview.tsx     # KPI metrics & live feed
│   │               ├── Analytics.tsx    # Charts & sensory precision
│   │               ├── Classifications.tsx # Scan database & inspector modal
│   │               └── Users.tsx        # User directory
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Navbar.tsx               # Header with section links & auth CTAs
│   │   │   └── Footer.tsx               # Footer with brand & navigation
│   │   └── ui/
│   │       └── Button.tsx               # Reusable styled button component
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── Login.tsx                # Social login page
│   │   │   └── Register.tsx             # Social signup page
│   │   └── home/
│   │       ├── Home.tsx                 # Landing container
│   │       └── sections/
│   │           ├── Hero.tsx             # 2-column hero & viewfinder
│   │           ├── Features.tsx         # Capabilities grid
│   │           ├── HowItWorks.tsx       # 3-step process guide
│   │           └── History.tsx          # Scan session logs
│   ├── App.tsx                          # React Router routes configuration
│   ├── index.css                        # Tailwind CSS v4 & theme definitions
│   └── main.tsx                         # App bootstrap
├── package.json
└── vite.config.ts
```
