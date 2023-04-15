CREATE OR REPLACE FUNCTION public.collezione_condivisa_dopo_fotografia_privata()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	DELETE FROM collezione_raggruppa_foto AS crf
	WHERE crf.id_collezione <> NEW.id_utente AND crf.id_foto = NEW.id_foto;
	
	RETURN NULL;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.collezione_gia_condivisa()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	v_counter integer;
	
BEGIN
	SELECT count(*) INTO v_counter
	FROM utente_possiede_collezione AS upc
	WHERE upc.id_collezione = NEW.id_collezione AND upc.id_utente = NEW.id_utente;
	
	IF v_counter > 1
		THEN RAISE EXCEPTION 'COLLEZIONE GIA CONDIVISA CON QUESTO UTENTE!';
	END IF;
	
    RETURN NULL;
END; 
$BODY$;
