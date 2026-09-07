# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA SOURCES                                   │
├──────────┬──────────┬──────────┬──────────┬──────────┬─────────────────┤
│ Weather  │ Satellite│ Terrain  │ IoT      │ Citizen  │ Historical      │
│ IMD/GPM  │ GEE/SAR  │ DEM      │ Sensors  │ Reports  │ Landslide Data  │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬────────────┘
     │          │          │          │          │          │
     ▼          ▼          ▼          ▼          ▼          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     FastAPI Backend (Python)                             │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐ │
│  │ API Layer   │  │ Services    │  │ Feature     │  │ Risk Fusion   │ │
│  │ /api/v1/    │  │ Weather,    │  │ Engineering │  │ Engine        │ │
│  │ Endpoints   │  │ Satellite,  │  │ Pipeline    │  │ Multi-source  │ │
│  │             │  │ IoT, CV     │  │             │  │ Risk Scoring  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────────┘ │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                    │
│  │ ML Model    │  │ Computer    │  │ Alert       │                    │
│  │ XGBoost +   │  │ Vision      │  │ Engine      │                    │
│  │ SHAP        │  │ Roboflow    │  │ Notifications│                   │
│  └─────────────┘  └─────────────┘  └─────────────┘                    │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   Supabase PostgreSQL + PostGIS                         │
│                   Supabase Auth + Supabase Storage                      │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     Next.js Frontend (TypeScript)                       │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐ │
│  │ GIS Map     │  │ Risk        │  │ Citizen     │  │ Admin         │ │
│  │ MapLibre GL │  │ Dashboard   │  │ Reporting   │  │ Dashboard     │ │
│  │             │  │ Recharts    │  │ PWA         │  │               │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## API Architecture

```
Next.js Frontend
       ↓
FastAPI Backend (/api/v1/)
       ↓
Service Layer (Weather, Satellite, IoT, CV, Risk)
       ↓
Supabase PostgreSQL / PostGIS
```

All business logic is handled by the backend. The frontend does not bypass the backend for core operations.

## Risk Assessment Pipeline

```
Static Susceptibility        Dynamic Trigger Risk       Ground Confirmation
(Slope, Elevation,          (Rainfall, Soil Moisture,   (IoT Sensors,
 Aspect, Land Cover,         Forecast, Ground Movement,  Field Reports,
 Historical Data)            Satellite Changes)          CV Analysis)
        ↓                          ↓                          ↓
        └──────────────────────────┼──────────────────────────┘
                                   ↓
                          Feature Engineering
                                   ↓
                         XGBoost ML Prediction
                                   ↓
                         Risk Fusion Engine
                                   ↓
                    Explainable Risk Score (0-100)
                    SHAP Feature Contributions
                                   ↓
                         GIS Visualization
                                   ↓
                    Alerts + Impact Analysis
                                   ↓
                Emergency Response Prioritization
```

## Module Responsibilities

| Module | Path | Responsibility |
|--------|------|---------------|
| Frontend | `frontend/` | Next.js web UI, GIS map, dashboards, citizen reporting |
| Backend | `backend/` | FastAPI REST API, service orchestration, risk engine |
| ML | `ml/` | Model training, feature engineering, inference |
| GIS | `gis/` | Geospatial processing, satellite analysis, DEM processing |
| IoT | `iot/` | Arduino/ESP32 sensor firmware |
| Docs | `docs/` | Architecture, design, and operational documentation |
