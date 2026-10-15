# 🐳 SariwaBa Docker Guide

This guide explains how Docker and Docker Compose work in the **SariwaBa** project, how the containers are structured, and how to run, inspect, and manage them.

---

## 🏗️ Architecture Overview

When you run Docker, Docker Compose orchestrates **two separate containers** connected over an internal Docker network:

```
                      ┌────────────────────────────────────────┐
                      │             Docker Network             │
                      │                                        │
  Flutter Frontend    │   ┌────────────────────────────────┐   │
  (http://localhost) ───► │  sariwaba_backend              │   │
     Port: 7357       │   │  (Django REST Framework, Py3.12)│  │
                      │   │  Port: 8000                    │   │
                      │   └───────────────┬────────────────┘   │
                      │                   │ Internal           │
                      │                   │ Hostname: "db"     │
                      │                   ▼                    │
                      │   ┌────────────────────────────────┐   │
                      │   │  sariwaba_db                   │   │
                      │   │  (PostgreSQL 16)               │   │
                      │   │  Port: 5432                    │   │
                      │   └────────────────────────────────┘   │
                      └────────────────────────────────────────┘
```

1. **`sariwaba_db` (Database Container)**:
   - Official `postgres:16-alpine` lightweight image.
   - Automatically initializes the database `sariwaba_db` with user `postgres` and password `admin`.
   - Data is stored in a persistent Docker volume (`postgres_data`), so your tables and users survive restarts.
   - Has a built-in health check (`pg_isready`) ensuring the database is fully ready before Django starts.

2. **`sariwaba_backend` (API Application Container)**:
   - Built from [`backend/Dockerfile`](backend/Dockerfile) using `python:3.12-slim`.
   - Includes system dependencies for OpenCV and Pillow image decoding (`libgl1`, `libglib2.0-0`, `libpq-dev`).
   - Automatically runs `python manage.py migrate` on startup.
   - Code is mounted live (`./backend:/app`), meaning any changes you make in VS Code / IDE **instantly hot-reload inside the container** without rebuilding!

---

## 🚀 How to Run with Docker

### ⚠️ Note on Port 5432 (Local PostgreSQL vs Docker)
If you already have a Windows PostgreSQL service running on your machine (like `postgresql-x64-18`), port `5432` is already in use by Windows.

* **To run PostgreSQL via Docker**: Stop the Windows service first:
  ```powershell
  Stop-Service postgresql-x64-18
  ```
* **Or to run only the Django backend in Docker connecting to your local Windows PostgreSQL**: Change `DB_HOST: host.docker.internal` in `docker-compose.yml`.

---

### Basic Commands

#### 1. Build and Start the Containers
From the root of the project (`d:\Projects\SariwaBa`):
```bash
docker compose up --build
```
> Add `-d` to run in the background (detached mode):
> ```bash
> docker compose up -d
> ```

#### 2. View Live Logs
```bash
docker compose logs -f backend
```

#### 3. Stop the Containers
```bash
docker compose down
```
*(Your database data is safely preserved in the `postgres_data` volume).*

#### 4. Stop and Wipe Database (Fresh Reset)
```bash
docker compose down -v
```

---

## 🛠️ Common Administrative Tasks in Docker

### Create a Django Admin Superuser
```bash
docker compose exec backend python manage.py createsuperuser
```

### Run Migrations Manually
```bash
docker compose exec backend python manage.py migrate
```

### Run Backend Tests inside Container
```bash
docker compose exec backend python manage.py test
```

### Open a Bash Shell inside the Backend Container
```bash
docker compose exec backend bash
```

---

## 🔄 Two Ways to Develop (Choose What Suits You)

You now have the flexibility to run the backend in either way:

| Workflow | When to Use | How to Run |
| :--- | :--- | :--- |
| **Local Virtualenv (`.venv`)** | Fastest iteration; training Machine Learning models with direct access to host GPU/CPU. | `cd backend`<br>`.\.venv\Scripts\Activate`<br>`python manage.py runserver` |
| **Full Docker (`docker compose`)** | Testing production parity; onboarding team members without manual Postgres setup; deployment to cloud (Render). | `docker compose up` |
