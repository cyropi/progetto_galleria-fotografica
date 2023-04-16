
-- CREAZIONE UTENTI
CALL crea_utente( 'mario', 'rossi', 'mariorossi98@gmail.com', 'italia', 'rossimario12345' );
CALL crea_utente( 'francesco', 'conte', 'francescoconte95@outlook.com', 'italia', 'contefrancesco32875' );
CALL crea_utente( 'sofia', 'ferrari', 'sofiaferrari87@libero.it', 'italia', 'ferrarisofia53765' );
CALL crea_utente( 'pasquale', 'esposito', 'pasqualeesposito92@virgilio.it', 'italia', 'espositopasquale45112' );




-- POPOLAMENTO TABELLE LUOGO E SOGGETTO
CALL aggiungi_luogo( 'Roma' );
CALL aggiungi_luogo( 'Milano' );
CALL aggiungi_luogo( 'Napoli' );
CALL aggiungi_luogo( 'Torino' );
CALL aggiungi_luogo( 'Brescia' );
CALL aggiungi_luogo( 'Bari' );
CALL aggiungi_luogo( 'Palermo' );
CALL aggiungi_luogo( 'Bergamo' );
CALL aggiungi_luogo( 'Catania' );
CALL aggiungi_luogo( 'Salerno' );
CALL aggiungi_luogo( 'Bologna' );
CALL aggiungi_luogo( 'Firenze' );
CALL aggiungi_luogo( 'Padova' );
CALL aggiungi_luogo( 'Verona' );
CALL aggiungi_luogo( 'Caserta' );
CALL aggiungi_luogo( 'Varese' );
CALL aggiungi_luogo( 'Treviso' );
CALL aggiungi_luogo( 'Monza' );
CALL aggiungi_luogo( 'Vicenza' );
CALL aggiungi_luogo( 'Venezia' );

CALL aggiungi_soggetto( 'Selfie' );
CALL aggiungi_soggetto( 'Paesaggio' );
CALL aggiungi_soggetto( 'Cibo' );
CALL aggiungi_soggetto( 'Monumenti' );
CALL aggiungi_soggetto( 'Sport' );
CALL aggiungi_soggetto( 'Concerti' );
CALL aggiungi_soggetto( 'Animali' );
CALL aggiungi_soggetto( 'Arte' );
CALL aggiungi_soggetto( 'Eventi' );
CALL aggiungi_soggetto( 'Svago' );




-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 1
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Milano', 1 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Napoli', 1 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Roma', 1 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Torino', 1 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Napoli', 1 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Treviso', 1 );

CALL inserisci_fotografia_in_cestino( 101 );
CALL inserisci_fotografia_in_cestino( 103 );

CALL rendi_fotografia_privata_o_pubblica( 102, 'privata' );
CALL rendi_fotografia_privata_o_pubblica( 105, 'privata' );

CALL crea_video( 1, null );
CALL inserisci_in_video_formato_da_foto( 100 );
CALL inserisci_in_video_formato_da_foto( 102 );
CALL inserisci_in_video_formato_da_foto( 104 );

INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 100, 1 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 100, 7 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 101, 2 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 102, 4 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 102, 1 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 102, 3 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 103, 9 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 104, 8 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 105, 10 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 105, 5 );

INSERT INTO foto_raffigura_utente( id_foto, id_utente )
VALUES( 102, 2 );
INSERT INTO foto_raffigura_utente( id_foto, id_utente )
VALUES( 104, 4 );




-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 2
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Brescia', 2 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Bari', 2 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Roma', 2 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Monza', 2 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Varese', 2 );
CALL aggiungi_fotografia( 'C:\Users\Public\Pictures\img.jpg', 'PC', 'Varese', 2 );

CALL inserisci_fotografia_in_cestino( 110 );
CALL inserisci_fotografia_in_cestino( 111 );

CALL rendi_fotografia_privata_o_pubblica( 106, 'privata' );
CALL rendi_fotografia_privata_o_pubblica( 109, 'privata' );

CALL crea_video( 2, null );
CALL inserisci_in_video_formato_da_foto( 106 );
CALL inserisci_in_video_formato_da_foto( 107 );
CALL inserisci_in_video_formato_da_foto( 109 );

INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 106, 2 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 106, 6 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 107, 8 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 108, 1 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 108, 4 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 109, 3 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 109, 6 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 109, 1 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 110, 2 );
INSERT INTO foto_raffigura_soggetto( id_foto, id_soggetto )
VALUES( 111, 5 );

INSERT INTO foto_raffigura_utente( id_foto, id_utente )
VALUES( 107, 3 );
INSERT INTO foto_raffigura_utente( id_foto, id_utente )
VALUES( 107, 1 );
INSERT INTO foto_raffigura_utente( id_foto, id_utente )
VALUES( 108, 4 );




-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 3


-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 4



-- CREAZIONE COLLEZIONI CONDIVISE
