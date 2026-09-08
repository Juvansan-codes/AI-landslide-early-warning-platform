# Backend — FastAPI API Server

The FastAPI backend for the AI Landslide Early Warning Platform.

## Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI application factory
│   ├── config.py            # Environment/settings configuration
│   ├── api/
│   │   └── v1/
│   │       ├── router.py    # v1 API router
│   │       └── endpoints/
│   │           └── health.py
│   ├── core/                # Core utilities (DB, auth — future)
│   ├── models/              # Database models (future)
│   ├── schemas/             # Pydantic request/response schemas
│   │   └── health.py
│   └── services/            # Business logic services (future)
├── tests/
│   └── test_health.py
├── requirements.txt
├── .env.example
└── README.md
```

## Setup Instructions

### 1. Supabase Configuration

This backend requires a connection to a Supabase project (PostgreSQL + PostGIS).

1. Create a project at [Supabase](https://supabase.com).
2. Apply the SQL migrations in `migrations/` via the Supabase SQL Editor.
3. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
4. Fill in your credentials in `.env`:
   - `SUPABASE_URL`: Your project URL.
   - `SUPABASE_ANON_KEY`: Your publishable anon key.
   - `SUPABASE_SERVICE_ROLE_KEY`: Your service role secret (found in Project Settings > API). **Never expose this key to the frontend.**

### 2. Local Development

1. Ensure you have Python 3.12+ installed.
2. Create and activate a virtual environment:
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API available at `http://localhost:8000`
Swagger docs at `http://localhost:8000/docs`

## API Versioning

All endpoints are prefixed with `/api/v1/`.
