--Lastly, run this file to delete all the stored procedures and functions added as a part of data setup
DROP FUNCTION IF EXISTS set_uuid();
DROP FUNCTION IF EXISTS set_slug(TEXT);
DROP PROCEDURE IF EXISTS generate_test_data(TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT);
DROP PROCEDURE IF EXISTS delete_test_data(TEXT,TEXT);