# Database tables for correction/calibration prototype

These migrations describe tables that will be split into different schemas or backends in the final design

## Pipe
The ingest.  Often handled by Kinesis, our infra uses timescaledb for ingest pipe.

## Synced Corrected Raw Data Tables
Tiger Data round trip archicture syncs tables back into our domain database, for serving intermediate data to technical R&D users

## Calibration Control
API driven setup for calibration parameters for individual or group calibrated metering or sensing devices
