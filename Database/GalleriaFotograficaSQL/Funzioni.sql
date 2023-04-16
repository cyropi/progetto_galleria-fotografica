CREATE OR REPLACE FUNCTION public.cestino(
	p_id_utente integer)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date, 
		  pubblica smallint, eliminata smallint, id_utente integer) 
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



CREATE OR REPLACE FUNCTION public.collezione_condivisa(
	p_nome_collezione character varying)
    RETURNS TABLE(id_foto integer, id_collezione integer, val_foto bytea, dispositivo character varying, "città" character varying, 
		  data date, pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
	v_id_collezione collezione.id_collezione%type;

BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );

	RETURN QUERY
		SELECT *
		FROM collezione_raggruppa_foto AS crf NATURAL JOIN fotografia AS f
		WHERE crf.id_collezione = v_id_collezione;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.collezione_personale(
	p_id_utente integer)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date,
		  pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.foto_non_presenti_in_collezione_condivisa(
	p_id_utente integer,
	p_nome_collezione character varying)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date, 
		  pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );
	
	RETURN QUERY
		SELECT * 
		FROM fotografia AS f 
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0 AND f.privata = 0 AND
			  f.id_foto NOT IN( SELECT crf.id_foto
					    FROM collezione_raggruppa_foto AS crf
					    WHERE crf.id_collezione = v_id_collezione );
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_id_collezione(
	p_nome_collezione character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	SELECT c.id_collezione INTO v_id_collezione
	FROM collezione AS c
	WHERE c.nome = p_nome_collezione;
	
	RETURN v_id_collezione;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_id_foto(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_id_foto integer;
	
BEGIN
	SELECT f.id_foto INTO v_id_foto
	FROM fotografia AS f
	ORDER BY f.id_foto DESC
	LIMIT 1;
	
	RETURN v_id_foto;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_id_soggetto(
	p_categoria character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_id_soggetto soggetto.id_soggetto%type;
	
BEGIN
	SELECT id_soggetto INTO v_id_soggetto 
	FROM soggetto AS s
	WHERE s.categoria = p_categoria;
	
	RETURN v_id_soggetto;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_id_utente(
	p_email character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_id_utente utente.id_utente%type;
	
BEGIN
	SELECT u.id_utente INTO v_id_utente
	FROM utente AS u
	WHERE u.email = p_email;
	
	RETURN v_id_utente;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_id_video(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_id_video integer;
	
BEGIN
	SELECT v.id_video INTO v_id_video
	FROM video AS v
	ORDER BY v.id_video DESC
	LIMIT 1;
	
	RETURN v_id_video;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_soggetti_foto(
	p_id_foto integer)
    RETURNS TABLE(id_soggetto integer, categoria character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM soggetto AS s
		WHERE s.id_soggetto IN( SELECT frs.id_soggetto
					FROM foto_raffigura_soggetto AS frs
					WHERE frs.id_foto IN( SELECT f.id_foto
							      FROM fotografia AS f
							      WHERE f.id_foto = p_id_foto ) );
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.recupera_utenti_foto(
	p_id_foto integer)
    RETURNS TABLE(id_utente integer, nome character varying, cognome character varying, email character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT u.id_utente, u.nome, u.cognome, u.email
		FROM utente AS u
		WHERE u.id_utente IN( SELECT fru.id_utente
				      FROM foto_raffigura_utente AS fru
				      WHERE fru.id_foto IN( SELECT f.id_foto
							    FROM fotografia AS f
							    WHERE f.id_foto = p_id_foto ) );
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.stesso_luogo(
	p_id_utente integer,
	p_citta character varying)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date, 
		  pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.città = p_citta AND f.eliminata = 0;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.stesso_soggetto(
	p_id_utente integer,
	p_categoria character varying)
    RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, "città" character varying, data date, 
		  pubblica smallint, eliminata smallint, id_utente integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0 AND 
			  f.id_foto IN( SELECT frs.id_foto 
					FROM foto_raffigura_soggetto AS frs 
					WHERE frs.id_soggetto IN( SELECT s.id_soggetto
								  FROM soggetto AS s
								  WHERE s.categoria = p_categoria ) );
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.top_3_luoghi(
	p_id_utente integer)
    RETURNS TABLE("città" character varying, n_foto bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
	RETURN QUERY
		SELECT f.città, COUNT(*) AS n_foto
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0
		GROUP BY f.città
		ORDER BY n_foto DESC
		LIMIT 3;
END;
$BODY$;
