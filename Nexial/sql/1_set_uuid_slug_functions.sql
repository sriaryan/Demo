--run this file first to add these functions to DB
CREATE OR REPLACE FUNCTION set_uuid()
    RETURNS UUID
    LANGUAGE SQL
    AS $$
        SELECT md5(random()::text || clock_timestamp()::text)::uuid;
    $$;

CREATE OR REPLACE FUNCTION set_slug(TEXT)
    RETURNS TEXT
    LANGUAGE PLPGSQL
    AS $$
    DECLARE
        encodeduid TEXT;
    BEGIN
encodeduid := encode(decode(translate($1, '-',''), 'hex'),'base64');
      RETURN translate(encodeduid,'+/=','-_');
    END;
    $$;
COMMIT;