--used to initilize seed in Nexial script when default setting is chosen
SELECT (max(id)+1) AS seed FROM "public"."purchase_order";