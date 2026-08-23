-- watermark tracking tables
CREATE TABLE IF NOT EXISTS lineage_export_watermark (
    last_exported_at TIMESTAMP_NTZ
);
INSERT INTO lineage_export_watermark (last_exported_at)
SELECT '1970-01-01'::TIMESTAMP_NTZ
WHERE NOT EXISTS (SELECT 1 FROM lineage_export_watermark);