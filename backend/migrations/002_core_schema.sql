-- =============================================================================
-- Migration 002: Core Database Schema
-- =============================================================================
-- AI Landslide Early Warning Platform (SIH'26)
--
-- Creates all core tables, ENUM types, indexes, constraints, triggers,
-- and Row Level Security policies.
--
-- Depends on: 001_enable_postgis.sql
--
-- Spatial design:
--   - All spatial data uses SRID 4326 (WGS 84)
--   - Point locations: geography(Point, 4326) for accurate distance queries
--   - Polygons/lines: geometry(Polygon/LineString/Geometry, 4326) for fast spatial joins
--   - GiST indexes on all spatial columns used in queries
-- =============================================================================


-- =============================================================================
-- ENUM TYPES
-- =============================================================================

-- User roles
CREATE TYPE user_role AS ENUM ('citizen', 'field_officer', 'admin');

-- Risk severity levels
CREATE TYPE severity_level AS ENUM ('low', 'moderate', 'high', 'very_high', 'critical');

-- Sensor types
CREATE TYPE sensor_type AS ENUM ('soil_moisture', 'tilt_imu', 'rain_gauge');

-- Sensor deployment status
CREATE TYPE sensor_status AS ENUM ('active', 'inactive', 'maintenance');

-- Sensor reading quality
CREATE TYPE reading_quality AS ENUM ('good', 'degraded', 'error');

-- Weather observation type
CREATE TYPE observation_type AS ENUM ('observed', 'forecast');

-- Citizen report types
CREATE TYPE report_type AS ENUM (
    'ground_crack', 'landslide', 'road_blockage',
    'rockfall', 'water_accumulation', 'other'
);

-- Report verification status
CREATE TYPE verification_status AS ENUM ('pending', 'verified', 'rejected');

-- Report media type
CREATE TYPE media_type AS ENUM ('image', 'video');

-- Alert status
CREATE TYPE alert_status AS ENUM ('active', 'acknowledged', 'resolved', 'expired');

-- Infrastructure asset types
CREATE TYPE asset_type AS ENUM ('village', 'road', 'bridge', 'school', 'hospital', 'other');


-- =============================================================================
-- TABLE 1: user_profiles
-- =============================================================================
-- Extends Supabase Auth. Each row links to auth.users via the id column.
-- Do NOT duplicate authentication — only store application-specific profile data.
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role        user_role NOT NULL DEFAULT 'citizen',
    full_name   TEXT,
    phone       TEXT,
    organization TEXT,
    state       TEXT,
    district    TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE user_profiles IS 'Application user profiles extending Supabase Auth';
COMMENT ON COLUMN user_profiles.id IS 'References auth.users(id) — same UUID';
COMMENT ON COLUMN user_profiles.role IS 'Application role: citizen, field_officer, or admin';


-- =============================================================================
-- TABLE 2: risk_cells
-- =============================================================================
-- Geographic grid cells for risk assessment.
-- Resolution-agnostic: the polygon geometry defines the cell area.
-- Can be regular lat/lng grids, H3 hexagons, or irregular boundaries.
-- =============================================================================

CREATE TABLE IF NOT EXISTS risk_cells (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cell_code               TEXT NOT NULL UNIQUE,
    geom                    geometry(Polygon, 4326) NOT NULL,
    state                   TEXT,
    district                TEXT,
    -- Static terrain/susceptibility features
    elevation_mean          DOUBLE PRECISION,
    slope_mean              DOUBLE PRECISION,
    aspect_mean             DOUBLE PRECISION,
    land_cover              TEXT,
    susceptibility_score    DOUBLE PRECISION CHECK (susceptibility_score >= 0 AND susceptibility_score <= 100),
    -- Latest dynamic risk (denormalized for fast dashboard queries)
    latest_risk_score       DOUBLE PRECISION CHECK (latest_risk_score >= 0 AND latest_risk_score <= 100),
    latest_severity         severity_level,
    latest_risk_updated_at  TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_risk_cells_geom ON risk_cells USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_risk_cells_state_district ON risk_cells (state, district);
CREATE INDEX IF NOT EXISTS idx_risk_cells_severity ON risk_cells (latest_severity) WHERE latest_severity IS NOT NULL;

CREATE TRIGGER trg_risk_cells_updated_at
    BEFORE UPDATE ON risk_cells
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE risk_cells IS 'Geographic grid cells for landslide risk assessment. Resolution-agnostic.';
COMMENT ON COLUMN risk_cells.cell_code IS 'Human-readable cell identifier, e.g. NER-ML-001';
COMMENT ON COLUMN risk_cells.geom IS 'Cell boundary polygon in WGS 84 (SRID 4326)';
COMMENT ON COLUMN risk_cells.susceptibility_score IS 'Static susceptibility score (0-100) from terrain analysis';
COMMENT ON COLUMN risk_cells.latest_risk_score IS 'Most recent dynamic risk score (0-100), denormalized for fast queries';


-- =============================================================================
-- TABLE 3: historical_landslides
-- =============================================================================
-- Landslide inventory records from ISRO/NRSC, GSI, and other sources.
-- No fabricated events — only real data from verified sources.
-- =============================================================================

CREATE TABLE IF NOT EXISTS historical_landslides (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id        TEXT UNIQUE,
    location        geography(Point, 4326) NOT NULL,
    event_date      DATE,
    source          TEXT NOT NULL,
    severity        severity_level,
    landslide_type  TEXT,
    state           TEXT,
    district        TEXT,
    description     TEXT,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_historical_landslides_location ON historical_landslides USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_historical_landslides_event_date ON historical_landslides (event_date);
CREATE INDEX IF NOT EXISTS idx_historical_landslides_source ON historical_landslides (source);

CREATE TRIGGER trg_historical_landslides_updated_at
    BEFORE UPDATE ON historical_landslides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE historical_landslides IS 'Historical landslide inventory from ISRO/NRSC, GSI, and other verified sources';
COMMENT ON COLUMN historical_landslides.event_id IS 'Source-specific event identifier for deduplication';
COMMENT ON COLUMN historical_landslides.location IS 'Event location as WGS 84 geography point for accurate distance queries';


-- =============================================================================
-- TABLE 4: weather_observations
-- =============================================================================
-- Rainfall and weather data from IMD, NASA GPM/IMERG.
-- Supports both observed measurements and forecast data.
-- =============================================================================

CREATE TABLE IF NOT EXISTS weather_observations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location            geography(Point, 4326) NOT NULL,
    observed_at         TIMESTAMPTZ NOT NULL,
    source              TEXT NOT NULL,
    observation_type    observation_type NOT NULL DEFAULT 'observed',
    rainfall_mm         DOUBLE PRECISION,
    temperature_c       DOUBLE PRECISION,
    humidity_pct        DOUBLE PRECISION CHECK (humidity_pct >= 0 AND humidity_pct <= 100),
    wind_speed_ms       DOUBLE PRECISION CHECK (wind_speed_ms >= 0),
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_weather_observations_location ON weather_observations USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_weather_observations_source_time ON weather_observations (source, observed_at DESC);
CREATE INDEX IF NOT EXISTS idx_weather_observations_time ON weather_observations (observed_at DESC);

COMMENT ON TABLE weather_observations IS 'Weather and rainfall data from IMD, NASA GPM/IMERG, and other sources';
COMMENT ON COLUMN weather_observations.observation_type IS 'Whether this is an observed measurement or a forecast';
COMMENT ON COLUMN weather_observations.rainfall_mm IS 'Rainfall measurement in millimeters';


-- =============================================================================
-- TABLE 5: sensors
-- =============================================================================
-- IoT sensor deployment registry.
-- Tracks sensor location, type, and operational status.
-- =============================================================================

CREATE TABLE IF NOT EXISTS sensors (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sensor_code     TEXT NOT NULL UNIQUE,
    sensor_type     sensor_type NOT NULL,
    location        geography(Point, 4326) NOT NULL,
    state           TEXT,
    district        TEXT,
    status          sensor_status NOT NULL DEFAULT 'active',
    installed_at    TIMESTAMPTZ,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sensors_location ON sensors USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_sensors_type_status ON sensors (sensor_type, status);

CREATE TRIGGER trg_sensors_updated_at
    BEFORE UPDATE ON sensors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sensors IS 'IoT sensor deployment registry (soil moisture, tilt/IMU, rain gauge)';
COMMENT ON COLUMN sensors.sensor_code IS 'Unique human-readable sensor identifier, e.g. SM-ML-001';


-- =============================================================================
-- TABLE 6: sensor_readings
-- =============================================================================
-- Time-series sensor measurements.
-- High-volume table — indexed for latest-reading queries.
-- =============================================================================

CREATE TABLE IF NOT EXISTS sensor_readings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sensor_id       UUID NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,
    recorded_at     TIMESTAMPTZ NOT NULL,
    value           DOUBLE PRECISION NOT NULL,
    unit            TEXT NOT NULL,
    quality         reading_quality NOT NULL DEFAULT 'good',
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sensor_readings_sensor_time ON sensor_readings (sensor_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_time ON sensor_readings (recorded_at DESC);

COMMENT ON TABLE sensor_readings IS 'Time-series IoT sensor measurements';
COMMENT ON COLUMN sensor_readings.value IS 'Measured value (unit specified in the unit column)';
COMMENT ON COLUMN sensor_readings.unit IS 'Measurement unit, e.g. "%%" for moisture, "deg" for tilt, "mm" for rain';


-- =============================================================================
-- TABLE 7: risk_assessments
-- =============================================================================
-- Generated risk assessment records with explainability data.
-- Links to risk_cells. Stores SHAP values in contributing_factors JSONB.
-- =============================================================================

CREATE TABLE IF NOT EXISTS risk_assessments (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    risk_cell_id            UUID NOT NULL REFERENCES risk_cells(id) ON DELETE CASCADE,
    risk_score              DOUBLE PRECISION NOT NULL CHECK (risk_score >= 0 AND risk_score <= 100),
    severity                severity_level NOT NULL,
    model_name              TEXT,
    model_version           TEXT,
    contributing_factors    JSONB DEFAULT '{}',
    assessment_source       TEXT NOT NULL DEFAULT 'model',
    assessed_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_cell_time ON risk_assessments (risk_cell_id, assessed_at DESC);
CREATE INDEX IF NOT EXISTS idx_risk_assessments_severity ON risk_assessments (severity) WHERE severity IN ('high', 'very_high', 'critical');

COMMENT ON TABLE risk_assessments IS 'Generated risk assessment records with SHAP explainability data';
COMMENT ON COLUMN risk_assessments.contributing_factors IS 'JSONB storing SHAP feature contributions, e.g. {"rainfall_24h": 0.35, "slope": 0.25}';
COMMENT ON COLUMN risk_assessments.assessment_source IS 'How the assessment was generated: model, manual, or composite';


-- =============================================================================
-- TABLE 8: citizen_reports
-- =============================================================================
-- Geo-tagged citizen and field officer reports.
-- Media files are stored in Supabase Storage, referenced via report_media.
-- =============================================================================

CREATE TABLE IF NOT EXISTS citizen_reports (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    location                geography(Point, 4326) NOT NULL,
    report_type             report_type NOT NULL,
    description             TEXT,
    severity                severity_level DEFAULT 'moderate',
    verification_status     verification_status NOT NULL DEFAULT 'pending',
    verified_by             UUID REFERENCES user_profiles(id),
    verified_at             TIMESTAMPTZ,
    metadata                JSONB DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_citizen_reports_location ON citizen_reports USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_citizen_reports_user ON citizen_reports (user_id);
CREATE INDEX IF NOT EXISTS idx_citizen_reports_status ON citizen_reports (verification_status);
CREATE INDEX IF NOT EXISTS idx_citizen_reports_type ON citizen_reports (report_type);

CREATE TRIGGER trg_citizen_reports_updated_at
    BEFORE UPDATE ON citizen_reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE citizen_reports IS 'Geo-tagged citizen and field officer hazard reports';
COMMENT ON COLUMN citizen_reports.verification_status IS 'Report verification: pending, verified, or rejected';


-- =============================================================================
-- TABLE 9: report_media
-- =============================================================================
-- Media file references for citizen reports.
-- Actual files are stored in Supabase Storage, NOT in PostgreSQL.
-- =============================================================================

CREATE TABLE IF NOT EXISTS report_media (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id       UUID NOT NULL REFERENCES citizen_reports(id) ON DELETE CASCADE,
    storage_path    TEXT NOT NULL,
    media_type      media_type NOT NULL,
    file_size_bytes BIGINT,
    mime_type       TEXT,
    cv_processed    BOOLEAN NOT NULL DEFAULT FALSE,
    cv_results      JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_report_media_report ON report_media (report_id);
CREATE INDEX IF NOT EXISTS idx_report_media_unprocessed ON report_media (cv_processed) WHERE cv_processed = FALSE;

COMMENT ON TABLE report_media IS 'Media file references for citizen reports. Files stored in Supabase Storage.';
COMMENT ON COLUMN report_media.storage_path IS 'Path within Supabase Storage bucket';
COMMENT ON COLUMN report_media.cv_results IS 'Computer vision detection results from Roboflow (JSONB)';


-- =============================================================================
-- TABLE 10: alerts
-- =============================================================================
-- Alert/notification records for the warning system.
-- Notification delivery is NOT implemented yet — only the data structure.
-- =============================================================================

CREATE TABLE IF NOT EXISTS alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    risk_cell_id    UUID REFERENCES risk_cells(id) ON DELETE SET NULL,
    severity        severity_level NOT NULL,
    title           TEXT NOT NULL,
    message         TEXT,
    alert_status    alert_status NOT NULL DEFAULT 'active',
    target_roles    TEXT[] DEFAULT '{}',
    issued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ,
    resolved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts (alert_status) WHERE alert_status = 'active';
CREATE INDEX IF NOT EXISTS idx_alerts_cell ON alerts (risk_cell_id) WHERE risk_cell_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts (severity);

CREATE TRIGGER trg_alerts_updated_at
    BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE alerts IS 'Alert records for the early warning system. Delivery not yet implemented.';
COMMENT ON COLUMN alerts.target_roles IS 'Array of roles that should receive this alert';


-- =============================================================================
-- TABLE 11: infrastructure_assets
-- =============================================================================
-- Villages, roads, bridges, schools, hospitals for impact analysis.
-- Uses generic geometry type to support points, lines, and polygons.
-- =============================================================================

CREATE TABLE IF NOT EXISTS infrastructure_assets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_type      asset_type NOT NULL,
    name            TEXT NOT NULL,
    geom            geometry(Geometry, 4326) NOT NULL,
    state           TEXT,
    district        TEXT,
    population      INTEGER,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_infrastructure_assets_geom ON infrastructure_assets USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_infrastructure_assets_type ON infrastructure_assets (asset_type);
CREATE INDEX IF NOT EXISTS idx_infrastructure_assets_state_district ON infrastructure_assets (state, district);

CREATE TRIGGER trg_infrastructure_assets_updated_at
    BEFORE UPDATE ON infrastructure_assets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE infrastructure_assets IS 'Villages, roads, and critical infrastructure for spatial impact analysis';
COMMENT ON COLUMN infrastructure_assets.geom IS 'Generic geometry: points for villages, lines for roads, polygons for areas';


-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================
-- RLS policies control access when queries use Supabase client with user JWTs.
-- The FastAPI backend uses the service role key, which bypasses RLS.
--
-- Policy naming convention: {table}_{action}_{who}
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_cells ENABLE ROW LEVEL SECURITY;
ALTER TABLE historical_landslides ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensors ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE citizen_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE infrastructure_assets ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- user_profiles: Users can read their own profile. Admins can read all.
-- ---------------------------------------------------------------------------
CREATE POLICY user_profiles_select_own ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY user_profiles_select_admin ON user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid() AND up.role = 'admin'
        )
    );

CREATE POLICY user_profiles_update_own ON user_profiles
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY user_profiles_insert_own ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- risk_cells: All authenticated users can read. Write via service role only.
-- ---------------------------------------------------------------------------
CREATE POLICY risk_cells_select_authenticated ON risk_cells
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- historical_landslides: All authenticated users can read.
-- ---------------------------------------------------------------------------
CREATE POLICY historical_landslides_select_authenticated ON historical_landslides
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- weather_observations: All authenticated users can read.
-- ---------------------------------------------------------------------------
CREATE POLICY weather_observations_select_authenticated ON weather_observations
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- sensors: All authenticated users can read.
-- ---------------------------------------------------------------------------
CREATE POLICY sensors_select_authenticated ON sensors
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- sensor_readings: All authenticated users can read. No public writes.
-- ---------------------------------------------------------------------------
CREATE POLICY sensor_readings_select_authenticated ON sensor_readings
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- risk_assessments: All authenticated users can read.
-- ---------------------------------------------------------------------------
CREATE POLICY risk_assessments_select_authenticated ON risk_assessments
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- citizen_reports: Citizens see own reports. Field officers/admins see all.
-- Citizens can insert their own reports.
-- ---------------------------------------------------------------------------
CREATE POLICY citizen_reports_select_own ON citizen_reports
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY citizen_reports_select_officers ON citizen_reports
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid() AND up.role IN ('field_officer', 'admin')
        )
    );

CREATE POLICY citizen_reports_insert_own ON citizen_reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY citizen_reports_update_officers ON citizen_reports
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid() AND up.role IN ('field_officer', 'admin')
        )
    );

-- ---------------------------------------------------------------------------
-- report_media: Same access pattern as citizen_reports (via report ownership).
-- ---------------------------------------------------------------------------
CREATE POLICY report_media_select_own ON report_media
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM citizen_reports cr
            WHERE cr.id = report_media.report_id AND cr.user_id = auth.uid()
        )
    );

CREATE POLICY report_media_select_officers ON report_media
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid() AND up.role IN ('field_officer', 'admin')
        )
    );

CREATE POLICY report_media_insert_own ON report_media
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM citizen_reports cr
            WHERE cr.id = report_media.report_id AND cr.user_id = auth.uid()
        )
    );

-- ---------------------------------------------------------------------------
-- alerts: All authenticated users can read active alerts.
-- ---------------------------------------------------------------------------
CREATE POLICY alerts_select_authenticated ON alerts
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- infrastructure_assets: All authenticated users can read.
-- ---------------------------------------------------------------------------
CREATE POLICY infrastructure_assets_select_authenticated ON infrastructure_assets
    FOR SELECT USING (auth.role() = 'authenticated');
