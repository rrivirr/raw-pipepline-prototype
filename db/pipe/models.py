
import uuid

from sqlalchemy import JSON, UUID, Column, DateTime, Numeric, String, create_engine, func
from sqlalchemy.orm import DeclarativeBase



class Base(DeclarativeBase):
    pass

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
   


# from dotenv import load_dotenv
# import os
# load_dotenv()

# # Create a SQLite database engine (file named 'app.db')
# engine = create_engine(os.getenv('DATABASE_URL'))

# # Create tables in the database (if they don’t exist)
# Base.metadata.create_all(engine)

# # Create hypertable manually or via extension
# with engine.connect() as conn:
#     conn.execute(text("""
#         SELECT create_hypertable('sensor_data', 'timestamp',
#                                  partitioning_column => 'device_id',
#                                  number_partitions => 8);
#     """))
#     conn.commit()
