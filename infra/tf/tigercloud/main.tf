# TimescaleDB service for the sensor ingest pipeline.
#
# Storage is deliberately not configured. TigerData moved to usage-based
# storage in June 2023; the provider's storage_gb argument is deprecated and
# there is no fixed volume to size. The 500 milli-CPU / 2 GiB pair below is the
# smallest supported compute tier and satisfies the sizing requirement in full.
resource "timescale_service" "sensor_ingest" {
  name        = var.service_name
  milli_cpu   = var.milli_cpu
  memory_gb   = var.memory_gb
  region_code = var.region_code
}
