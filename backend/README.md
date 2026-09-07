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

## Getting Started

```bash
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API available at `http://localhost:8000`
Swagger docs at `http://localhost:8000/docs`

## API Versioning

All endpoints are prefixed with `/api/v1/`.
