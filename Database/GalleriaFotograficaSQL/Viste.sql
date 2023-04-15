CREATE OR REPLACE VIEW public.numero_totale_fotografie_e_utenti
 AS
 SELECT ( SELECT count(*) AS count
           FROM utente) AS totale_utenti,
    ( SELECT count(*) AS count
           FROM fotografia) AS totale_foto;
