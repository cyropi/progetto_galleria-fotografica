CREATE TABLE IF NOT EXISTS public.amministratore
(
    id_amminist smallint NOT NULL,
    password character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT pk_amminist PRIMARY KEY (id_amminist),
    CONSTRAINT amminist_pass_nn CHECK (password IS NOT NULL)
)



CREATE TABLE IF NOT EXISTS public.utente
(
    id_utente integer NOT NULL DEFAULT nextval('utente_id_utente_seq'::regclass),
    nome character varying(30) COLLATE pg_catalog."default",
    cognome character varying(30) COLLATE pg_catalog."default",
    email character varying(50) COLLATE pg_catalog."default",
    nazione character varying(50) COLLATE pg_catalog."default",
    password character varying(30) COLLATE pg_catalog."default",
    id_amminist integer,
    CONSTRAINT pk_utente PRIMARY KEY (id_utente),
    CONSTRAINT uq_utente UNIQUE (email),
    CONSTRAINT fk_utente FOREIGN KEY (id_amminist)
        REFERENCES public.amministratore (id_amminist) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT cognome_nn CHECK (cognome IS NOT NULL),
    CONSTRAINT nome_nn CHECK (nome IS NOT NULL),
    CONSTRAINT utente_email_nn CHECK (email IS NOT NULL),
    CONSTRAINT utente_pass_nn CHECK (password IS NOT NULL)
)



CREATE TABLE IF NOT EXISTS public.fotografia
(
    id_foto integer NOT NULL DEFAULT nextval('fotografia_id_foto_seq'::regclass),
    val_foto bytea,
    dispositivo character varying(30) COLLATE pg_catalog."default",
    "città" character varying(30) COLLATE pg_catalog."default",
    data date,
    pubblica smallint DEFAULT 1,
    eliminata smallint DEFAULT 0,
    id_utente integer,
    CONSTRAINT pk_fotografia PRIMARY KEY (id_foto),
    CONSTRAINT fk_fotografia_1 FOREIGN KEY (id_utente)
        REFERENCES public.utente (id_utente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_fotografia_2 FOREIGN KEY ("città")
        REFERENCES public.luogo ("città") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT check_foto_elim CHECK (eliminata = 0 OR eliminata = 1),
    CONSTRAINT check_foto_pubb CHECK (pubblica = 0 OR pubblica = 1),
    CONSTRAINT val_foto_nn CHECK (val_foto IS NOT NULL)
)



CREATE TABLE IF NOT EXISTS public.collezione
(
    id_collezione integer NOT NULL DEFAULT nextval('collezione_id_collezione_seq'::regclass),
    personale smallint DEFAULT 1,
    nome character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT pk_collezione PRIMARY KEY (id_collezione),
    CONSTRAINT uq_collezione UNIQUE (nome),
    CONSTRAINT check_collezione_pers CHECK (personale = 0 OR personale = 1)
)



CREATE TABLE IF NOT EXISTS public.video
(
    id_video integer NOT NULL DEFAULT nextval('video_id_video_seq'::regclass),
    id_utente integer,
    descrizione text COLLATE pg_catalog."default",
    CONSTRAINT pk_video PRIMARY KEY (id_video),
    CONSTRAINT fk_video FOREIGN KEY (id_utente)
        REFERENCES public.utente (id_utente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT id_utente_nn CHECK (id_utente IS NOT NULL)
)



CREATE TABLE IF NOT EXISTS public.soggetto
(
    id_soggetto integer NOT NULL DEFAULT nextval('soggetto_id_soggetto_seq'::regclass),
    categoria character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT pk_soggetto PRIMARY KEY (id_soggetto),
    CONSTRAINT uq_soggetto UNIQUE (categoria),
    CONSTRAINT categoria_nn CHECK (categoria IS NOT NULL)
)



CREATE TABLE IF NOT EXISTS public.luogo
(
    "città" character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_luogo PRIMARY KEY ("città")
)



CREATE TABLE IF NOT EXISTS public.collezione_raggruppa_foto
(
    id_collezione integer,
    id_foto integer,
    CONSTRAINT fk_crf_1 FOREIGN KEY (id_collezione)
        REFERENCES public.collezione (id_collezione) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_crf_2 FOREIGN KEY (id_foto)
        REFERENCES public.fotografia (id_foto) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)



CREATE TABLE IF NOT EXISTS public.utente_possiede_collezione
(
    id_utente integer,
    id_collezione integer,
    CONSTRAINT fk_upc_1 FOREIGN KEY (id_utente)
        REFERENCES public.utente (id_utente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_upc_2 FOREIGN KEY (id_collezione)
        REFERENCES public.collezione (id_collezione) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)



CREATE TABLE IF NOT EXISTS public.foto_raffigura_soggetto
(
    id_foto integer,
    id_soggetto integer,
    CONSTRAINT fk_frs_1 FOREIGN KEY (id_foto)
        REFERENCES public.fotografia (id_foto) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_frs_2 FOREIGN KEY (id_soggetto)
        REFERENCES public.soggetto (id_soggetto) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)



CREATE TABLE IF NOT EXISTS public.foto_raffigura_utente
(
    id_foto integer,
    id_utente integer,
    CONSTRAINT fk_fru_1 FOREIGN KEY (id_foto)
        REFERENCES public.fotografia (id_foto) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_fru_2 FOREIGN KEY (id_utente)
        REFERENCES public.utente (id_utente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)



CREATE TABLE IF NOT EXISTS public.video_formato_da_foto
(
    id_video integer,
    id_foto integer,
    CONSTRAINT fk_vff_1 FOREIGN KEY (id_video)
        REFERENCES public.video (id_video) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_vff_2 FOREIGN KEY (id_foto)
        REFERENCES public.fotografia (id_foto) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)
