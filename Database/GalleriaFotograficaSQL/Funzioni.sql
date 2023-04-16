CREATE OR REPLACE FUNCTION public.cestino(
	p_id_utente integer)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date, pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.eliminata = 1;
END;
$BODY$;
