
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
CALL aggiungi_luogo( 'VeneziA' );

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


-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 2



-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 3


-- POPOLAMENTO COLLEZIONE PERSONALE UTENTE 4



-- CREAZIONE COLLEZIONI CONDIVISE
