/*second, run this file to add procedure to DB
the default parametrs can be changed by calling the procedure with explicit values. E.g: generate_test_data('1','1','user',po_currency=>'INR') will insert a record with INR currency*/
CREATE OR REPLACE PROCEDURE generate_test_data(
	uname TEXT,
    seed TEXT = '1000000000',
    t_rows TEXT = '2',
    po_currency TEXT = 'USD',
    po_vendor_id TEXT = '4507',
    po_vendor_name TEXT = 'LATENT CONTENT, INC',
    po_vendor_address TEXT = '527 MOLINO STREET, #106nLOS ANGELES, CA, 90013',
    li_unit_cost TEXT = '10.0',
    li_order TEXT = '0',
    li_quantity TEXT = '10',
    li_acquisition_type TEXT = 'PURCHASE',
    li_episode_code TEXT = '12',
    li_detail_code TEXT = '45',
    li_set_code TEXT = '1',
    li_memo_code TEXT = '1',
    d_department_name TEXT = 'vc new VFX'
)

/*the procedure takes a unique seed representing the id column in purchase order
table and inserts consequtive records till t_rows for the username provided in uname*/

LANGUAGE plpgsql
AS $$
DECLARE
    counter BIGINT := 1;
    total_rows BIGINT := t_rows :: BIGINT;
    current_value BIGINT := seed :: BIGINT;
    current_user_id BIGINT;
    current_department_id BIGINT;
    current_uuid_PO UUID;
    current_uuid_LI UUID;
    current_uuid_N UUID;
BEGIN
	
    /*retrieving user_id from user table that matches the username given as input*/ 
    SELECT id INTO current_user_id FROM "public"."user" WHERE username = uname;
	
    /*retrieving the corresponding department_id from user_departments table 
    with the help of already retrived user_id*/
    --SELECT department_id INTO current_department_id FROM "public"."user_department" WHERE user_id = current_user_id; 

    SELECT id INTO current_department_id FROM "department" d INNER JOIN "user_department" u ON u.department_id = d.id AND u.user_id=current_user_id AND d.name = d_department_name;
	
    /*this loop statement makes sure that generated slugs are unique 
        in nature by checking in the respective table*/ 
    WHILE counter <= total_rows LOOP
            current_uuid_PO := set_uuid(); 
        /*inserting into purchase_order table.  
        Unique values are id, external_id and slug 
        foreign key constraint on category_id,department_id and user_id*/
        INSERT INTO "public"."purchase_order" (
            "id",external_id,slug,created,updated,purchase_order_date, 
            currency,user_id,status,current_workflow_id,title,
            department_id,po_number,revision,vendor_id,category_id,
            vendor_name,vendor_address,vendor_contact)
        VALUES (
            /*here set_uuid is a custom function that generates version 1 uuid
            title concats test with id field value for testing and understandability*/
            current_value,current_uuid_PO,set_slug(current_uuid_PO::TEXT),now(),now(),
            now()::DATE,po_currency,current_user_id,'DRAFT',null,
            concat('test_',current_value :: text),
            current_department_id,(current_value+300000) :: text,0,po_vendor_id::BIGINT,null,
            po_vendor_name,po_vendor_address,
            '');

        /*making sure that generated slug is unique for line_item table*/ 
            current_uuid_LI := set_uuid();

        /*Inserting records into line_item table. 
        unique values are id, external_id and slug. 
        currently id is set to the same value as purchase_order_id 
        Foreign key constraints on purchase_order_id*/ 

        INSERT INTO "public"."line_item" ( 
            "id",external_id,slug,"order",quantity,description,unit_cost, 
            purchase_order_id,rental_period_start,rental_period_end, 
            acquisition_type,episode_code,detail_code,set_code,memo_code)  
        VALUES (
            current_value+100000,current_uuid_LI,set_slug(current_uuid_LI::TEXT),
            li_order :: INTEGER,li_quantity :: INTEGER,concat('test_',current_value :: text),
            li_unit_cost::NUMERIC(12,2),current_value,null,null,li_acquisition_type,li_episode_code,
            li_detail_code,li_set_code,li_memo_code);
			
        /*making sure that slug is unique in note table*/ 
        current_uuid_N := set_uuid();
		
        /*inserting records into note table.
        unique values are id, external_id and slug 
        currently id is kept as same as purchase_order_id
        Foreign key constraints on purchase_order_id and user_id*/ 
        INSERT INTO "public"."note" (
            "id",external_id,slug,created,updated,"content","order",
            purchase_order_id,"timestamp",user_id,context)
        VALUES (
            current_value+200000,current_uuid_N,set_slug(current_uuid_N::TEXT), 
            now(),now(),concat('test_',current_value :: text), 
            0,current_value,now(),current_user_id,'STANDARD'); 
        current_value := current_value +1; 
        counter := counter + 1; 
    END LOOP;
EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error, either record already exists in database or there is a problem with the parameters provided';
        RETURN;
END;
$$;
COMMIT;