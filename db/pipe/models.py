
import enum
import uuid

from sqlalchemy import JSON, UUID, Column, DateTime, Enum, Integer, Numeric, String, create_engine, func
from sqlalchemy.orm import DeclarativeBase



class Base(DeclarativeBase):
    pass

# 
# Data Pipe Tables
#

class SensorData(Base):
    __tablename__ = 'sensor_data' 
    serial_number = Column(String)
    measured_at = Column(DateTime)
    delivered_at = Column(DateTime, nullable=False)
    device_type = Column(String)
    payload = Column(JSON)
    telemetry = Column(JSON)

    __mapper_args__ = {
        "primary_key": [serial_number, measured_at]
    }

class Meter(Base):
    __tablename__ = "meter"
    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    serial_number = Column(String)
    rate = Column(Numeric(precision=12, scale=6))
    length = Column(Numeric(precision=12, scale=6))
    measured_at = Column(DateTime, nullable=False)
     
    __mapper_args__ = {
        "primary_key": [id]
    }


#
# Tables synced back from correction pipeline
#

class CorrectionLineage(Base):
    __tablename__ = "correction_lineage"
 
    id = Column(UUID, nullable=False)
    created_at = Column(DateTime, nullable=False)
    attributes = Column(JSON, nullable=False)

    __mapper_args__ = {
        "primary_key": [id]
    }
 

class MeterReadingCorrected(Base):
    __tablename__ = "meter_reading_corrected"

    serial_number = Column(String)
    rate = Column(Numeric(12, 6))
    length = Column(Numeric(12, 6))
    measured_at = Column(DateTime)
    id = Column(String)  

    __mapper_args__ = {
        "primary_key": [id]
    }

#
# Calibration Control
#

class CalibrationType(enum.Enum):
    LINEAR = "linear"
    PARABOLIC = "parabolic"
    PIECEWISE_LINEAR_4 = "piecewise_linear_4"


class Calibration(Base):
    __tablename__ = "calibration"

    id = Column(Integer, primary_key=True, autoincrement=True)
    serial_number = Column(String)
    calibration_type = Column(Enum(CalibrationType, native_enum=False), nullable=False)
    parameters = Column(JSON, nullable=False) # structure variants, currently unchecked
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=True)

    __mapper_args__ = {
        "primary_key": [id]
    }    
