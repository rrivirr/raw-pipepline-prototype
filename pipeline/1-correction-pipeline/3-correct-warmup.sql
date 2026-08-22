

--- any gap beyond the threshold indicated a warmup or a potential warmup (state unknown with data outage)
--- or flag periods with certain signature defined by the data scientist

CREATE OR REPLACE PROCEDURE correct_warmup()
  RETURNS BOOLEAN
  AS
  $$
BEGIN

LET warmup_reset := 10 * 60;


-- TODO: this detection logic needs to be improved.  the preceeding rows count is a not a precise method
CREATE OR REPLACE TABLE "3_correct_warmup" AS
    SELECT *
    FROM (
        SELECT *,
        MAX(gap_length) OVER (
            PARTITION BY serial_number
            ORDER BY measured_at
            ROWS BETWEEN 300 PRECEDING and CURRENT ROW
        ) as max_gap
        FROM (
            SELECT *, 
            DATE_PART(EPOCH, measured_at) - LAG(DATE_PART(EPOCH, measured_at)) 
                OVER ( PARTITION BY serial_number ORDER BY measured_at) AS gap_length
            FROM "1_analysis_rows"
        )
    ) 
    WHERE max_gap < :warmup_reset;
  
  
-- tag lineage here
-- lineage will be a json column where data is appended.
-- it should be one run-level lineage that travels along in the pipeline with this job.  the rows get a lineage id.


RETURN TRUE;
END;
$$
;


