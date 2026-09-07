# GIS / Geospatial Module

This module handles geospatial data processing, satellite imagery analysis, and spatial operations.

## Structure

```
gis/
├── data/           # Raster and vector datasets (gitignored for large files)
├── processing/     # GIS data processing scripts
├── scripts/        # Utility scripts for data conversion, tiling, etc.
└── README.md
```

## Planned Implementation

- **Libraries**: GeoPandas, Rasterio, GDAL
- **Satellite Platform**: Google Earth Engine
- **Datasets**: Sentinel-1 SAR, Sentinel-2, SRTM DEM
- **Database**: PostGIS for spatial queries and risk cell management

## Responsibilities

- DEM processing (slope, elevation, aspect extraction)
- Satellite image processing and change detection
- Risk cell grid generation and management
- Spatial queries for impact analysis (nearby roads, villages, infrastructure)

## Status

⚠️ **Not yet implemented.** Directory structure only — awaiting pilot region selection and data acquisition.
