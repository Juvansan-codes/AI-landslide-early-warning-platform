-- =============================================================================
-- Migration 001: Enable PostGIS and Create Utility Functions
-- =============================================================================
-- AI Landslide Early Warning Platform (SIH'26)
--
-- This migration:
--   1. Enables the PostGIS extension for spatial data support.
--   2. Creates a reusable trigger function for auto-updating `updated_at`.
-- =============================================================================

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable PostGIS topology (useful for complex spatial relationships)
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- =============================================================================
-- Utility: Auto-update `updated_at` timestamp trigger function
-- =============================================================================
-- Attach this trigger to any table that has an `updated_at` column.
-- Usage:
--   CREATE TRIGGER trg_<table>_updated_at
--     BEFORE UPDATE ON <table>
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- =============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
