# 🐟 SariwaBa? — Fish Freshness Classification System

> **SariwaBa?** (_"Is it fresh?"_) is an intelligent seafood quality assessment platform powered by deep learning and computer vision. The system provides instantaneous, standardized freshness ratings by analyzing visual cues such as eye cornea clarity, branchial gill pigmentation, and body surface texture.

---

## System Highlights

- **Instant AI Inference:** Rapid image evaluation
- **Sensory Detection:** Multi-feature inspection assessing eye cloudiness, gill redness, and scale sheen.
- **Standardized Grading:** Clear, objective classification metrics:
  - 🟢 **Grade A (Fresh)**
  - 🟡 **Grade B (Moderate)**
  - 🔴 **Grade C (Spoiled)**
- **Direct Social Authentication:** 1-click authentication with Google
- **Permanent Scan Archive:** Account holders maintain complete lifetime scan histories, quality trends, and exportable audit logs (with instant guest access for trial evaluations).
- **Admin Dashboard:** Full monitoring suite featuring live telemetry, volume analytics, sensory precision benchmarks, and a user directory.

---

## How to Run the Project

You can run the backend either using **Docker** (recommended for quick team onboarding) or **manually via Python virtualenv**.

### Option A: Using Docker (Recommended for Teammates)

With Docker Desktop installed, you do not need to install Python, PostgreSQL, or any dependencies manually.

```bash
# 1. Start both PostgreSQL and Django Backend
docker compose up --build

# (Optional) Run in background / detached mode:
docker compose up -d

# Stop containers:
docker compose down
```
> For full Docker commands, administrative tasks, and troubleshooting, refer to [DOCKER_README.md](DOCKER_README.md).

---

### Option B: Running Locally (Manual Setup)

#### 1. Backend (Django + PostgreSQL):
```bash
# Navigate to backend directory
cd backend

# Activate virtual environment (Windows PowerShell)
.\.venv\Scripts\Activate

# Apply database migrations to PostgreSQL
python manage.py migrate

# Run Django development server
python manage.py runserver
```

#### 2. Frontend (Flutter Web):
```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Chrome with standard port
flutter run -d chrome --web-port 7357
```

## Technology Stack

| Layer              | Technologies                                                     |
| :----------------- | :--------------------------------------------------------------- |
| **Web Frontend**   | Flutter Dart                                                     |
| **Mobile App**     | Flutter, Dart                                                    |
| **Authentication** | Google OAuth                                                     |
| **Backend & ML**   | Django, Computer Vision, Deep Learning (Eye/Gill Classification) |

---
