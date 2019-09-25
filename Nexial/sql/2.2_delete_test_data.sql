--Thirdly, run this file to add the procedure to DB, if the user wants to delete records from DB.
CREATE OR REPLACE PROCEDURE delete_test_data(seed TEXT,t_rows TEXT)
LANGUAGE PLPGSQL
AS $$
DECLARE
	counter BIGINT	:= 1;
	total_rows BIGINT := t_rows :: BIGINT;
	current_value BIGINT := seed :: BIGINT;
BEGIN
	
	WHILE counter <= total_rows LOOP
		
		DELETE FROM "public"."note" WHERE purchase_order_id = current_value;
		DELETE FROM "public"."line_item" WHERE purchase_order_id = current_value;
		DELETE FROM "public"."purchase_order" WHERE id = current_value;
		current_value := current_value+1;
		counter := counter + 1;
	END LOOP;
	EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Exception, there was a problem in deleteing the records';
		RETURN;
END;
$$;
COMMIT;