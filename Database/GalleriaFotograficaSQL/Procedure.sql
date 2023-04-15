CREATE OR REPLACE PROCEDURE public.aggiungi_fotografia(
	IN p_val_foto character varying,
	IN p_dispositivo character varying,
	IN p_citta character varying,
	IN p_id_utente integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO fotografia( val_foto, dispositivo, città, pubblica, eliminata, id_utente ) 
	VALUES( pg_read_binary_file(p_val_foto), p_dispositivo, p_citta, default, default, p_id_utente );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.aggiungi_luogo(
	IN "p_città" character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT into luogo( città )
	VALUES( initcap(p_città) );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.aggiungi_soggetto(
	IN p_categoria character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT into soggetto( categoria )
	VALUES( p_categoria );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.aggiungi_utente_in_collezione_condivisa(
	IN p_email character varying,
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	v_id_collezione collezione.id_collezione%type;

BEGIN
	v_id_utente = recupera_id_utente( p_email );
	v_id_collezione = recupera_id_collezione( p_nome_collezione );
	
	CALL inserisci_in_utente_possiede_collezione( v_id_utente, v_id_collezione );
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.crea_amministratore(
	IN p_password character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO amministratore( password ) 
	VALUES( p_password );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.crea_collezione_condivisa(
	IN p_id_utente integer,
	IN p_email character varying,
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	v_id_utente = recupera_id_utente( p_email );
	
	INSERT INTO collezione( personale, nome )
	VALUES( 0, p_nome_collezione );
	
	SELECT c.id_collezione INTO v_id_collezione
	FROM collezione AS c
	ORDER BY c.id_collezione DESC
	LIMIT 1;

	CALL inserisci_in_utente_possiede_collezione( p_id_utente, v_id_collezione );
	CALL inserisci_in_utente_possiede_collezione( v_id_utente, v_id_collezione );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.crea_utente(
	IN p_nome character varying,
	IN p_cognome character varying,
	IN p_email character varying,
	IN p_nazione character varying,
	IN p_password character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO utente( nome, cognome, email, nazione, password ) 
	VALUES( initcap(p_nome), initcap(p_cognome), lower(p_email), p_nazione, p_password );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.crea_video(
	IN p_id_utente integer,
	IN p_descrizione text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO video( id_utente, descrizione ) 
	VALUES( p_id_utente, p_descrizione );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_collezione_condivisa(
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_collezione collezione.id_collezione%type;

BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );

	CALL elimina_fotografie_in_collezione_condivisa( p_nome_collezione );
	
	DELETE FROM collezione AS c
	WHERE c.id_collezione = v_id_collezione;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_fotografia(
	IN p_id_foto integer,
	IN p_id_utente integer)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
	v_counter integer;
	
BEGIN
	SELECT count(*) INTO v_counter
	FROM collezione_raggruppa_foto AS crf
	WHERE crf.id_foto = p_id_foto;
	
	IF v_counter = 1
		THEN DELETE FROM fotografia AS f
			 WHERE f.id_foto = p_id_foto;
 
	ELSEIF v_counter > 1
		THEN DELETE FROM collezione_raggruppa_foto AS crf
			 WHERE crf.id_collezione = p_id_utente AND crf.id_foto = p_id_foto;
	END IF;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_fotografia_in_collezione_condivisa(
	IN p_id_foto integer,
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
	v_id_collezione collezione.id_collezione%type;
	v_counter integer;
	
BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );

	SELECT count(*) INTO v_counter
	FROM collezione_raggruppa_foto AS crf
	WHERE crf.id_foto = p_id_foto;
		
	IF v_counter = 1
		THEN DELETE FROM fotografia AS f
			 WHERE f.id_foto = p_id_foto;
 
	ELSEIF v_counter > 1
		THEN DELETE FROM collezione_raggruppa_foto AS crf
			 WHERE crf.id_collezione = v_id_collezione AND crf.id_foto = p_id_foto;
	END IF;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_fotografia_in_collezione_condivisa_2(
	IN p_id_foto integer,
	IN p_id_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
	v_counter integer;
	
BEGIN
	SELECT count(*) INTO v_counter
	FROM collezione_raggruppa_foto AS crf
	WHERE crf.id_foto = p_id_foto;
		
	IF v_counter = 1
		THEN DELETE FROM fotografia AS f
			 WHERE f.id_foto = p_id_foto;
 
	ELSEIF v_counter > 1
		THEN DELETE FROM collezione_raggruppa_foto AS crf
			 WHERE crf.id_collezione = v_id_collezione AND crf.id_foto = p_id_foto;
	END IF;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_fotografie_in_collezione_condivisa(
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
	v_id_collezione collezione.id_collezione%type;
	cursore_foto refcursor;
	foto_attuale fotografia.id_foto%type;

BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );

	OPEN cursore_foto FOR
		SELECT crf.id_foto
		FROM collezione_raggruppa_foto AS crf
		WHERE crf.id_collezione = v_id_collezione;

	LOOP
		FETCH cursore_foto INTO foto_attuale;
		EXIT WHEN NOT FOUND;
		CALL elimina_fotografia_in_collezione_condivisa_2( foto_attuale.id_foto, v_id_collezione );
	END LOOP;
	
	CLOSE cursore_foto;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_utente(
	IN p_id_utente integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM utente AS u
	WHERE u.id_utente = p_id_utente;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_utente_in_collezione_condivisa(
	IN p_email character varying,
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );
	v_id_utente = recupera_id_utente( p_email );
	
	DELETE FROM utente_possiede_collezione AS upc
	WHERE upc.id_collezione = v_id_collezione AND upc.id_utente = v_id_utente;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.elimina_video(
	IN p_id_video integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM video AS v
	WHERE v.id_video = p_id_video;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_fotografia_in_cestino(
	IN p_id_foto integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE fotografia AS f
	SET eliminata = 1
	WHERE f.id_foto = p_id_foto;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_fotografia_in_collezione_condivisa(
	IN p_id_foto integer,
	IN p_nome_collezione character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );
	
	INSERT INTO collezione_raggruppa_foto( id_collezione, id_foto ) 
	VALUES( v_id_collezione, p_id_foto );
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_fotografie_in_collezione_condivisa(
	IN p_id_utente integer,
	IN p_email character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	v_id_collezione collezione.id_collezione%type;
	cursore_foto refcursor;
	foto_attuale fotografia.id_foto%type;
	
BEGIN	
	v_id_utente = recupera_id_utente( p_email );
	
	SELECT c.id_collezione INTO v_id_collezione
	FROM collezione AS c
	ORDER BY c.id_collezione DESC
	LIMIT 1;
	
	OPEN cursore_foto FOR
		SELECT f.id_foto
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.pubblica = 1 AND f.eliminata = 0
		UNION
		SELECT f.id_foto
		FROM fotografia AS f
		WHERE f.id_utente = v_id_utente AND f.pubblica = 1 AND f.eliminata = 0;
	
	LOOP
		FETCH cursore_foto INTO foto_attuale;
		EXIT WHEN NOT FOUND;
		INSERT INTO collezione_raggruppa_foto( id_collezione, id_foto )
		VALUES( v_id_collezione, foto_attuale );
	END LOOP;
	
	CLOSE cursore_foto;
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_in_foto_raffigura_soggetto(
	IN p_categoria character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_foto fotografia.id_foto%type;
	v_id_soggetto soggetto.id_soggetto%type;
	
BEGIN
	v_id_foto = recupera_id_foto();
	v_id_soggetto = recupera_id_soggetto( p_categoria );
	
	INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto ) 
	VALUES( v_id_foto, v_id_soggetto );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_in_foto_raffigura_utente(
	IN p_email character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_foto fotografia.id_foto%type;
	v_id_utente utente.id_utente%type;
	
BEGIN
	v_id_foto = recupera_id_foto();
	v_id_utente = recupera_id_utente( p_email );
	
	INSERT INTO foto_raffigura_utente( id_foto, id_utente ) 
	VALUES( v_id_foto, v_id_utente );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_in_utente_possiede_collezione(
	IN p_id_utente integer,
	IN p_id_collezione integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO utente_possiede_collezione( id_utente, id_collezione ) 
	VALUES( p_id_utente, p_id_collezione );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.inserisci_in_video_formato_da_foto(
	IN p_id_foto integer)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_video video.id_video%type;
	
BEGIN
	v_id_video = recupera_id_video();
	
	INSERT INTO video_formato_da_foto( id_video, id_foto ) 
	VALUES( v_id_video, p_id_foto );
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.rendi_fotografia_privata_o_pubblica(
	IN p_id_foto integer,
	IN p_stato character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	IF p_stato = 'privata'
		THEN UPDATE fotografia AS f
			 SET pubblica = 0
			 WHERE f.id_foto = p_id_foto;
			 
	ELSEIF p_stato = 'pubblica'
		THEN UPDATE fotografia AS f
		SET pubblica = 1
		WHERE f.id_foto = p_id_foto;
	END IF;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.rimuovi_fotografia_da_cestino(
	IN p_id_foto integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE fotografia AS f
	SET eliminata = 0
	WHERE f.id_foto = p_id_foto;
END; 
$BODY$;



CREATE OR REPLACE PROCEDURE public.truncate_tabelle(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	TRUNCATE utente RESTART identity CASCADE;
	TRUNCATE collezione RESTART identity CASCADE;
	TRUNCATE fotografia RESTART identity CASCADE;	
	TRUNCATE video RESTART identity CASCADE;
END;
$BODY$;
