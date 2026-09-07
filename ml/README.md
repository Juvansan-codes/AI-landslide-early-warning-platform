# Machine Learning Module

This module contains the machine learning pipeline for landslide risk assessment.

## Structure

```
ml/
├── data/           # Raw and processed datasets
├── features/       # Feature engineering scripts
├── models/         # Trained model artifacts (gitignored)
├── training/       # Training scripts and notebooks
├── inference/      # Inference/serving scripts
└── README.md
```

## Planned Implementation

- **Model**: XGBoost for location-specific landslide risk assessment
- **Explainability**: SHAP for model prediction explanations
- **Libraries**: Pandas, NumPy, Scikit-learn, XGBoost, SHAP

## Data Sources (Future)

- Historical landslide records
- Terrain/DEM features (slope, elevation, aspect)
- Rainfall data (IMD, NASA GPM)
- Soil moisture measurements
- Satellite-derived features (NDVI change, SAR coherence)

## Status

⚠️ **Not yet implemented.** Directory structure only — awaiting data acquisition and feature engineering design.
