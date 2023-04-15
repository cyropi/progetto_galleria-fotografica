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



CREATE OR REPLACE FUNCTION public.collezione_personale_dopo_eliminazione_utente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN	
	DELETE FROM collezione AS c
	WHERE c.id_collezione = OLD.id_utente;
	
	RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.controllo_email()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    email_pattern VARCHAR = '[A-Za-z0-9]{2,}@[A-Za-z0-9]{2,}\.[A-Za-z]{2,}';

BEGIN
    IF NEW.email !~ email_pattern
		THEN RAISE EXCEPTION 'Inserire un indirizzo email valido!';
    END IF;
	
	RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.controllo_password()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    pass_pattern VARCHAR = '[A-Za-z0-9]{6,}';

BEGIN
    IF NEW.password !~ pass_pattern
		THEN RAISE EXCEPTION 'Inserire una password valida! La password deve contenere almeno 6 lettere e NON ammette caratteri speciali.';
    END IF;
	
	RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.creazione_collezione_personale()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	INSERT INTO collezione( id_collezione, personale )
	VALUES( new.id_utente, default );
	
	INSERT INTO utente_possiede_collezione( id_utente, id_collezione )
	VALUES( new.id_utente, new.id_utente );
	
    RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.fotografie_dopo_eliminazione_utente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	DELETE 
	FROM fotografia AS f
	WHERE f.id_utente IS NULL AND 
		  f.id_foto NOT IN( 
			  	SELECT fru.id_foto
				FROM foto_raffigura_utente AS fru
				WHERE fru.id_utente IN(
						    SELECT upc.id_utente
						    FROM utente_possiede_collezione AS upc
						    WHERE upc.id_collezione IN( 
									    SELECT crf.id_collezione
									    FROM collezione_raggruppa_foto AS crf
									    WHERE crf.id_foto = f.id_foto )));
					
	RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.inserimento_data_in_fotografia()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	UPDATE fotografia
	SET data = CURRENT_DATE
	WHERE NEW.data IS NULL;
	
	RETURN NULL;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.inserimento_fotografia_in_collezione_personale()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	INSERT INTO collezione_raggruppa_foto( id_collezione, id_foto )
	VALUES( new.id_utente, new.id_foto );
	
    RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.inserimento_id_amminist_in_utente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_id_amminist amministratore.id_amminist%TYPE;
	
BEGIN
	SELECT id_amminist INTO v_id_amminist 
	FROM amministratore;
	
	UPDATE utente
	SET id_amminist = v_id_amminist
	WHERE NEW.id_amminist IS NULL;
	
	RETURN NULL;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.limite_fotografie_per_utente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_counter integer;
	
BEGIN
	SELECT count(*) INTO v_counter
	FROM fotografia AS f
	WHERE f.id_utente = NEW.id_utente;
	
	IF v_counter > 1000
		THEN RAISE EXCEPTION 'HAI RAGGIUNTO IL LIMITE MASSIMO DI FOTO!';
	END IF;

	RETURN NULL;
END; 
$BODY$;



CREATE OR REPLACE FUNCTION public.limite_utenti_sistema()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	
BEGIN
	SELECT u.id_utente INTO v_id_utente
	FROM utente AS u
	ORDER BY u.id_utente DESC
	LIMIT 1;
	
	IF v_id_utente > 99999
		THEN RAISE EXCEPTION 'RAGGIUNTO IL LIMITE MASSIMO DI UTENTI!';
	END IF;

	RETURN NULL;
END; 
$BODY$;
