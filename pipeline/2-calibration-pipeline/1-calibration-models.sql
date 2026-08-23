CREATE OR REPLACE FUNCTION calibration_linear(x FLOAT, slope FLOAT, intercept FLOAT)
RETURNS FLOAT
LANGUAGE SQL
AS
$$
  slope * x + intercept
$$;

CREATE OR REPLACE FUNCTION calibration_parabolic(x FLOAT, a FLOAT, b FLOAT, c FLOAT)
RETURNS FLOAT
LANGUAGE SQL
AS
$$
  a * x * x + b * x + c
$$;


CREATE OR REPLACE FUNCTION four_point_linear(
    x FLOAT,
    x1 FLOAT, y1 FLOAT,
    x2 FLOAT, y2 FLOAT,
    x3 FLOAT, y3 FLOAT,
    x4 FLOAT, y4 FLOAT,
    x5 FLOAT, y5 FLOAT
)
RETURNS FLOAT
LANGUAGE SQL
AS
$$
  CASE
    WHEN x <= x2 THEN y1 + (x - x1) * (y2 - y1) / (x2 - x1)
    WHEN x <= x3 THEN y2 + (x - x2) * (y3 - y2) / (x3 - x2)
    WHEN x <= x4 THEN y3 + (x - x3) * (y4 - y3) / (x4 - x3)
    ELSE y4 + (x - x4) * (y5 - y4) / (x5 - x4)
  END
$$;