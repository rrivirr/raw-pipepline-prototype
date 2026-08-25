The folders 1-setup-pipelines, 2-correction-pipeline-steps, and 3-correction-calibration-pipeline-dag contain SQL that is used to create a DAG pipeline in Snowflake.
Create a script that installs all these artifacts by connecting to Snowflake through SnowSQL, ignoring files that contain tests (.test.sql extension)
Connection parameters will be stored in a .install.env file that must be added to .gitignore
Test data must be installed after the SQL artifacts are in place.  
Test data reside in the file 'test-data.csv' and contain data that must be imported into TIGERLAKE_TSDB_PUBLIC_METER
All outputs must be placed into a subfolder of the current directory named run