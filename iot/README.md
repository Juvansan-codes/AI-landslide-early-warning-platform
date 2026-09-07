# IoT Module

This module contains firmware and configuration for the field sensor hardware prototype.

## Structure

```
iot/
├── arduino/        # Arduino UNO R4 sketches
├── esp32/          # ESP32 firmware (WiFi + HTTP communication)
└── README.md
```

## Hardware

- **Arduino UNO R4**: Reads sensor data (soil moisture, tilt/IMU, rain)
- **ESP32**: Receives data from Arduino via serial, sends to FastAPI backend over HTTP/REST

## Sensors

| Sensor | Purpose |
|--------|---------|
| Soil Moisture | Detect soil saturation levels |
| Tilt / IMU | Detect ground movement or slope deformation |
| Rain Sensor | Detect active rainfall at the sensor location |

## Data Flow

```
Sensors → Arduino UNO R4 → ESP32 → HTTP/REST → FastAPI → Database → Risk Engine
```

## Communication

- Arduino → ESP32: Serial communication
- ESP32 → Backend: HTTP POST to FastAPI endpoint
- Protocol: REST (no MQTT unless required later)

## Status

⚠️ **Not yet implemented.** Directory structure only — awaiting hardware assembly and endpoint design.
