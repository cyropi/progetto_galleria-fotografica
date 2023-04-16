CREATE OR REPLACE SEQUENCE IF NOT EXISTS public.collezione_id_collezione_seq
      INCREMENT 5
      START 100000
      MINVALUE 1
      MAXVALUE 2147483647
      CACHE 1
      OWNED BY collezione.id_collezione;
    
    
    
 CREATE OR REPLACE SEQUENCE IF NOT EXISTS public.fotografia_id_foto_seq
      INCREMENT 1
      START 100
      MINVALUE 1
      MAXVALUE 2147483647
      CACHE 1
      OWNED BY fotografia.id_foto;
    
    
    
 CREATE OR REPLACE SEQUENCE IF NOT EXISTS public.soggetto_id_soggetto_seq
      INCREMENT 1
      START 1
      MINVALUE 1
      MAXVALUE 2147483647
      CACHE 1
      OWNED BY soggetto.id_soggetto;
    
    
CREATE OR REPLACE SEQUENCE IF NOT EXISTS public.utente_id_utente_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1
    OWNED BY utente.id_utente;
    

CREATE OR REPLACE SEQUENCE IF NOT EXISTS public.video_id_video_seq
    INCREMENT 5
    START 1000
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1
    OWNED BY video.id_video;
