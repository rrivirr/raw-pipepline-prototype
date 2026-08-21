output "service_id" {
  description = "Unique identifier of the TimescaleDB service."
  value       = timescale_service.sensor_ingest.id
}

output "hostname" {
  description = "Hostname clients connect to."
  value       = timescale_service.sensor_ingest.hostname
}

output "port" {
  description = "Port clients connect to."
  value       = timescale_service.sensor_ingest.port
}

output "username" {
  description = "Postgres user for the service."
  value       = timescale_service.sensor_ingest.username
}
