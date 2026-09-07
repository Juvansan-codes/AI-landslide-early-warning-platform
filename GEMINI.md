# Workspace Instructions: AI Landslide Early Warning Platform

## 🚨 Mandatory Rule: Development Journal Maintenance (`journal.md`)

Every time the user provides a prompt and you complete a task or change code:
1. **Always update [`journal.md`](file:///d:/College%20Files/SIH'26/journal.md)** before concluding your response.
2. **Append a new numbered entry** using the following template:

```markdown
### Entry [XYZ] — YYYY-MM-DD — [Short Title]

- **User Prompt**:
  > *"[Quote or concisely summarize the prompt]"*

- **Objective**:
  - [Bullet points of what needs to be achieved]

- **AI Solution & Strategy**:
  - [Technical approach, rationale, architectural decisions, algorithms or models chosen]

- **Files Created / Modified**:
  - [`filename.ext`](file:///d:/College%20Files/SIH'26/path/to/file) [NEW/MODIFIED/DELETED]: Brief note on what changed

- **Current Status**:
  - [Verification done, working state, tests passed, etc.]

- **Next Steps**:
  - [Immediate next recommendations]
```

3. **Update the Table of Contents** in `journal.md` with the new entry link.
4. **Refer to `journal.md` first** when asked to debug or modify existing features to retain full context of past decisions.

# AI Landslide Early Warning Platform — Workspace Instructions

## 1. Project Identity

**Project:** AI Landslide Early Warning Platform
**Event:** Smart India Hackathon 2026 (SIH'26)
**Problem Statement:** SIH26001
**Organization:** Ministry of Development of North Eastern Region (MDoNER)
**Category:** Software
**Theme:** Disaster Management
**Target Region:** North Eastern Region (NER) of India

---

# 2. Problem Statement

The project aims to develop an AI-powered early warning and landslide risk monitoring system for landslide-prone regions of North Eastern India.

The system should combine multiple sources of information, including:

* Rainfall and weather data
* Soil moisture
* Terrain and slope characteristics
* Historical landslide records
* Satellite imagery
* Ground movement / IoT sensors
* Geo-tagged citizen and field reports
* Images/videos containing visual evidence such as cracks, debris or road blockages

The platform should identify areas with elevated landslide risk, continuously update the risk assessment as new evidence arrives, provide explainable risk information, visualize vulnerable areas using GIS, and support early-warning and emergency-response decisions.

The system should ultimately support:

* Real-time or near-real-time risk monitoring
* GIS-based risk visualization
* AI/ML-based risk assessment
* IoT sensor integration
* Satellite data integration
* Citizen/field reporting
* Automated alerts
* Emergency response prioritization
* Multilingual and low-connectivity capabilities where feasible

---

# 3. Our Proposed Solution

The platform is **not simply a landslide prediction model**.

The central concept is a **multi-source landslide intelligence and risk assessment platform**.

Multiple independent signals are combined:

```text
Weather / Rainfall
        +
Terrain / DEM
        +
Historical Landslides
        +
Soil Moisture
        +
Ground Movement
        +
Satellite Evidence
        +
Citizen / Field Reports
        +
Computer Vision
        ↓
Feature Engineering
        ↓
AI/ML Risk Prediction
        ↓
Risk Fusion Engine
        ↓
Explainable Risk Score (0–100)
        ↓
GIS Visualization
        ↓
Alerts + Impact Analysis
        ↓
Emergency Response Prioritization
```

The key product idea is:

> Detect → Verify → Predict → Explain → Prioritize → Warn

The platform should continuously assess risk for geographic locations/cells rather than claiming that it can perfectly predict the exact location and time of every landslide.

---

# 4. Core Intelligence Model

The system should distinguish between:

### 4.1 Static Susceptibility

This represents how naturally vulnerable a location is to landslides.

Potential features include:

* Slope
* Elevation
* Aspect
* Land cover
* Drainage characteristics
* Historical landslide density
* Terrain characteristics
* Distance to roads/infrastructure where relevant

### 4.2 Dynamic Trigger Risk

This represents how current environmental conditions are changing the risk.

Potential features include:

* Rainfall in the previous 1 hour
* Rainfall in the previous 6 hours
* Rainfall in the previous 24 hours
* Rainfall in the previous 72 hours
* Cumulative rainfall
* Forecast rainfall
* Soil moisture
* Ground movement
* Recent satellite-derived changes

### 4.3 Ground / Field Confirmation

Additional evidence can come from:

* Soil moisture sensors
* Tilt/IMU sensors
* Rain sensors
* Field officer reports
* Citizen reports
* Computer vision analysis of uploaded images

### 4.4 Final Risk

The Risk Fusion Engine combines the available signals and produces a location-specific risk score.

Example:

```text
Risk: 91 / 100
Severity: CRITICAL

Main contributing factors:
- High recent rainfall
- High soil moisture
- Steep slope
- Historical landslide susceptibility
- Detected ground movement
- Field image showing possible debris
```

Risk values and contribution weights must be based on validation and documented assumptions. Do not invent scientific weights simply to produce impressive results.

---

# 5. AI / ML Strategy

The initial primary ML model will be:

**XGBoost**

Supporting tools:

* Pandas
* NumPy
* Scikit-learn
* SHAP

SHAP should be used to explain model predictions.

The initial ML target should focus on **location-specific landslide risk assessment**, rather than claiming exact deterministic prediction.

The model should eventually be evaluated against historical landslide events and appropriate non-event samples.

Never fabricate:

* Accuracy
* Precision
* Recall
* F1 score
* AUC
* Prediction probability
* Historical labels
* Landslide events

If real data is unavailable during development, use clearly labelled mock/demo data.

---

# 6. Computer Vision

Computer vision will initially use:

**Roboflow + Roboflow API**

The model may use a YOLO-based architecture through Roboflow.

Initial potential detection classes:

* Ground cracks
* Landslide/debris
* Road blockage
* Rockfall

The CV module is an evidence source for the larger risk system.

It must NOT become the entire prediction system.

Example:

```text
Uploaded field image
        ↓
Roboflow API
        ↓
Detected:
Road blockage = 0.87 confidence
        ↓
FastAPI
        ↓
Risk Fusion Engine
        ↓
Risk updated
```

If Roboflow is unavailable, the rest of the risk system must remain architecturally functional.

---

# 7. GIS and Satellite

The system will use GIS as a core part of the platform.

Technologies:

* MapLibre GL JS
* PostGIS
* GeoPandas
* Rasterio
* GDAL

Satellite platform:

**Google Earth Engine**

Potential datasets:

* Sentinel-1 SAR
* Sentinel-2
* SRTM DEM

Satellite data should generally be processed periodically and converted into useful derived features.

Do not pretend that satellite imagery provides minute-by-minute live monitoring.

Large raster/satellite files should not be unnecessarily stored inside PostgreSQL.

---

# 8. Weather Data

Primary weather source:

**India Meteorological Department (IMD)**

Additional precipitation source:

**NASA GPM / IMERG**

Weather data should be ingested/cached by the backend rather than repeatedly requesting external APIs whenever a user opens the dashboard.

External API failures must be handled gracefully.

---

# 9. IoT Architecture

Hardware is a supporting component, not the primary product.

Prototype hardware:

* Arduino UNO R4
* ESP32
* Soil moisture sensor
* Tilt/IMU sensor
* Rain sensor

Proposed flow:

```text
Sensors
   ↓
Arduino UNO R4
   ↓
ESP32
   ↓
HTTP/REST
   ↓
FastAPI
   ↓
Database
   ↓
Risk Fusion Engine
   ↓
Dashboard / Alerts
```

Use HTTP/REST initially.

Do not introduce MQTT or complex IoT infrastructure unless there is a clear requirement.

---

# 10. Citizen / Field Reporting

The platform should support geo-tagged reports.

A report may contain:

* Location
* Timestamp
* Description
* Photo
* Video where appropriate
* Report category

Examples:

* Crack
* Landslide
* Blocked road
* Rockfall
* Water accumulation
* Other hazard evidence

The initial citizen interface should be implemented as a **Next.js PWA** rather than creating a separate native mobile application.

Images/videos should be stored in **Supabase Storage**, not directly in PostgreSQL.

---

# 11. Impact and Emergency Response

The platform should not stop at producing a risk score.

When an area becomes high risk, the system should determine potential impact using spatial analysis.

Potential affected assets:

* Villages
* Roads
* Critical infrastructure
* Population / settlements where reliable data is available

Example:

```text
High-risk cell
      ↓
PostGIS spatial query
      ↓
Nearby road + village + infrastructure
      ↓
Impact assessment
      ↓
Response priority
```

The goal is to help authorities answer:

> "Where is the risk highest, and what should we respond to first?"

---

# 12. Technology Stack

## Frontend

* Next.js
* TypeScript
* Tailwind CSS
* shadcn/ui
* MapLibre GL JS
* Recharts

## Backend

* Python
* FastAPI

## Database

* Supabase PostgreSQL
* PostGIS
* Supabase Auth
* Supabase Storage

## Machine Learning

* XGBoost
* Scikit-learn
* Pandas
* NumPy
* SHAP

## Computer Vision

* Roboflow
* Roboflow API
* YOLO-based model through Roboflow

## GIS

* GeoPandas
* Rasterio
* GDAL

## Satellite

* Google Earth Engine
* Sentinel-1
* Sentinel-2
* SRTM

## Weather

* IMD
* NASA GPM / IMERG

## IoT

* Arduino UNO R4
* ESP32
* Soil Moisture Sensor
* Tilt/IMU
* Rain Sensor
* HTTP/REST

## Deployment

* Vercel — frontend
* Render/Railway — backend
* Supabase — database/storage/auth

## Version Control

* Git
* GitHub

## Containerization

Docker is **not required initially**.

Do not introduce Docker unless explicitly requested or there is a demonstrated technical need.

---

# 13. Architecture Principles

### Backend

FastAPI is the main backend/API layer.

Frontend:

```text
Next.js
   ↓
FastAPI
   ↓
Services / Risk Engine
   ↓
Supabase PostgreSQL/PostGIS
```

Do not unnecessarily allow the frontend to bypass the backend for core business logic.

### Risk Engine

Risk calculation must be isolated from API routes.

Conceptually:

```text
Data Sources
     ↓
Feature Engine
     ↓
ML Prediction
     ↓
Risk Fusion Engine
     ↓
Risk Assessment
```

### Database

Supabase PostgreSQL/PostGIS is the main data store.

Use PostgreSQL for structured application data.

Use PostGIS for spatial data.

Use Supabase Storage for large media files.

Do not store large images, videos, satellite rasters, or other large binary files directly inside PostgreSQL unless there is a compelling reason.

---

# 14. Development Philosophy

This is a student-built SIH project, so prioritize:

1. Correctness
2. Feasibility
3. Maintainability
4. Demonstrability
5. Scalability
6. Simplicity

Do not introduce technologies merely because they are popular.

Prefer the simplest architecture that satisfies the requirement.

Do not prematurely build:

* Microservices
* Kubernetes
* Complex message queues
* Native mobile apps
* Complex distributed systems
* Custom ML infrastructure

unless the project genuinely requires them.

---

# 15. MVP Priority

## MUST HAVE

1. Pilot geographic region
2. GIS-based geographic risk cells
3. Historical landslide data
4. Terrain/slope features
5. Rainfall-based dynamic risk
6. XGBoost risk model
7. SHAP explanations
8. Supabase/PostGIS database
9. FastAPI backend
10. Next.js GIS dashboard
11. Arduino/ESP32 sensor prototype
12. Risk visualization

## SHOULD HAVE

13. IMD forecast integration
14. Road impact analysis
15. Citizen reporting
16. Roboflow CV
17. Satellite-derived evidence
18. Automated alerts

## NICE TO HAVE

19. Multilingual alerts
20. SMS/WhatsApp integration
21. Offline-first improvements
22. Advanced route prioritization
23. 3D terrain visualization
24. Advanced satellite deformation analysis

Do not allow NICE-TO-HAVE features to delay the core MVP.

---

# 16. Data Integrity Rules

This is a disaster-management system.

Never fabricate real-world information.

Never present simulated information as real.

Never fabricate:

* Weather data
* Satellite observations
* Government datasets
* Historical landslides
* Sensor measurements
* Model performance
* Prediction accuracy
* API responses
* Emergency alerts

When real data is unavailable:

1. Use clearly labelled mock/demo data.
2. Keep mock data isolated behind an interface.
3. Make replacement with real data straightforward.
4. Clearly indicate that the information is simulated.

---

# 17. AI Agent Development Rules

Before implementing a major feature:

1. Explain what will be built.
2. Explain the architectural approach.
3. Identify files that will be created or modified.
4. Identify dependencies.
5. Identify external services/APIs involved.
6. Identify risks and assumptions.
7. Then implement after approval when the change is architectural or substantial.

For small and obvious fixes, implementation may proceed directly.

Do not make unrelated changes.

Do not rewrite working code unnecessarily.

Do not introduce a new dependency when the existing stack can solve the problem.

Never hardcode API keys, passwords, tokens, or secrets.

Use environment variables.

Never claim a feature is complete unless it has actually been implemented and tested.

---

# 18. Development Journal

`journal.md` is the project's persistent engineering history.

Every meaningful user request or development task must be logged.

Before modifying or debugging an existing feature:

**Read `journal.md` first.**

After completing a meaningful task:

1. Append a new numbered journal entry.
2. Record the user request.
3. Record the objective.
4. Record the AI solution and strategy.
5. Record files created/modified/deleted.
6. Record verification/testing.
7. Record current status.
8. Record next steps.
9. Update the journal table of contents.

Use the existing journal entry format.

Do not fabricate journal information.

If a task was not actually completed, record it as incomplete.

---

# 19. Git Rules

Use meaningful commits.

Preferred format:

```text
feat: add risk cell API
feat: integrate rainfall service
fix: handle missing sensor data
refactor: separate risk engine
docs: update architecture
chore: configure environment
```

Do not make commits that claim functionality that has not been implemented.

Avoid huge unrelated commits.

Before committing, verify the affected functionality.

---

# 20. Current Project State

The project is currently in the initialization stage.

Existing files:

* `GEMINI.md`
* `journal.md`

The Git repository has been initialized and connected to the project's GitHub repository.

No major application features have been implemented yet.

The next objective is to establish and approve the architecture before beginning application development.

---

# 21. Core Product Principle

Always keep the following principle in mind:

> **We are not merely building a landslide prediction model. We are building a multi-source landslide intelligence platform that continuously assesses risk, explains why the risk is changing, identifies what may be affected, and helps authorities prioritize early-warning and emergency-response actions.**

The system should follow:

**Detect → Verify → Predict → Explain → Prioritize → Warn**
