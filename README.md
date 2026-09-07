# AI Landslide Early Warning Platform

> **Smart India Hackathon 2026 (SIH'26) — Problem Statement SIH26001**
> Ministry of Development of North Eastern Region (MDoNER)

A multi-source AI-powered landslide intelligence platform for real-time risk monitoring, early warning, and emergency response prioritization in the North Eastern Region of India.

**Detect → Verify → Predict → Explain → Prioritize → Warn**

---

## Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Frontend** | Next.js, TypeScript, Tailwind CSS, shadcn/ui, MapLibre GL JS, Recharts |
| **Backend** | Python, FastAPI, Uvicorn |
| **Database** | Supabase PostgreSQL, PostGIS, Supabase Auth, Supabase Storage |
| **ML** | XGBoost, Scikit-learn, Pandas, NumPy, SHAP |
| **Computer Vision** | Roboflow, YOLO-based model |
| **GIS / Satellite** | GeoPandas, Rasterio, GDAL, Google Earth Engine |
| **Weather** | IMD, NASA GPM / IMERG |
| **IoT** | Arduino UNO R4, ESP32, HTTP/REST |
| **Deployment** | Vercel (frontend), Render/Railway (backend), Supabase (DB/Auth/Storage) |

---

## Repository Structure

```
├── frontend/          # Next.js web application
├── backend/           # FastAPI REST API
├── ml/                # Machine learning models and training
├── gis/               # GIS data processing and scripts
├── iot/               # Arduino/ESP32 sensor firmware
├── docs/              # Architecture and design documentation
├── journal.md         # Development journal (AI tracking log)
├── GEMINI.md          # AI workspace instructions
├── .env.example       # Environment variable template
└── .gitignore
```

---

## Getting Started

### Prerequisites

- Python 3.12+
- Node.js 22 LTS
- Git

### Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # macOS/Linux
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`. Swagger docs at `http://localhost:8000/docs`.

### Frontend

```bash
cd frontend
npm install
npm run dev
```

The application will be available at `http://localhost:3000`.

### Environment Variables

Copy `.env.example` to `.env` and fill in the required values:

```bash
cp .env.example .env
```

---

## Development Journal

All development decisions, prompts, and changes are tracked in [`journal.md`](journal.md).

---

## License

TBD
