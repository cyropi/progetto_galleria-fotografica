# SQL 

Nel file **Tabelle.sql**, si troverà il codice relativo alle creazione delle *tabelle* presenti nel DB. \
Nel file **Popolamento.sql**, si troverà il codice relativo al *popolamento* delle stesse tabelle presenti nel DB.\
Nel file **Funzioni.sql**, si troverà il codice relativo alle creazione delle *funzioni* presenti nel DB. \
Nel file **Procedure.sql**, si troverà il codice relativo alle creazione delle *procedure* presenti nel DB. \
Nel file **Trigger.sql**, si troverà il codice relativo alle creazione dei *trigger* presenti nel DB. \
Nel file **Viste.sql**, si troverà il codice relativo alle creazione delle *viste* presenti nel DB.
\
\
Si faranno, di seguito, una serie di commenti riguardanti eventuali dubbi che potrebbero sorgere sul codice SQL.

&nbsp; 

# Tabelle
Le tabelle sono state implementate seguendo esattamente il Class Diagram e lo schema logico presente nella documentazione; unico appunto va fatto per quanto riguarda la messa in pratica dei trigger delle Foreign Key. Ogni FK, di ogni tabella, ha il seguente schema di base: 

```bash
    CONSTRAINT constraint_name FOREIGN KEY (column_name)
        REFERENCES table_name (column_name)
        ON UPDATE CASCADE
        ON DELETE CASCADE
```

ad eccezione della tabella FOTOGRAFIA, dove, nella chiave esterna che si riferisce all'utente, segue invece la seguente implementazione:

```bash
    CONSTRAINT constraint_name FOREIGN KEY (column_name)
        REFERENCES table_name (column_name)
        ON UPDATE CASCADE
        ON DELETE SET NULL
```

Il motivo è giustificato dal fatto che, all'eliminazione di un utente, come da vincolo richiesto (vedasi Documentazione), non tutte le sue foto devono essere eliminate; se il trigger **ON DELETE** venisse impostato a **CASCADE**, invece, ne sarebbero eliminate tutte di conseguenza. La FK *id_utente* impostata a NULL avrà poi utilità nel trigger ***fotografie_dopo_eliminazione_utente***, che provvederà alla corretta eliminazione delle foto dell'utente appena eliminato.  

&nbsp;

# Popolamento
Il popolamento di base del database (utile per verificarne il suo funzionamento) è stato effettuato nel seguente modo: 
- Sono stati creati 4 utenti;
- Ogni utente ha 6 fotografie, 2 delle quali inserite nel cestino, 2 invece impostate come private;
- Ogni utente ha 1 video, formato da 3 foto;
- Ogni fotografia del sistema ha lo stesso valore (non essendo visualizzabile direttamente nel DBMS, risulta indifferente);
- Tra le 6 fotografie dell'utente, ognuna raffigura almeno un soggetto, mentre soltanto 2 raffigurano anche degli utenti del sistema;
- Ogni utente possiede, oltre la rispettiva collezione personale, una collezione condivisa con un altro utente;
- Nelle collezioni condivise create, sono state inserite tutte le fotografie (non eliminate e non private) degli utenti partecipanti ad essa;
- La tabella SOGGETTO è riempita con 10 categorie di default;
- La tabella LUOGO è riempita con 20 città di default (sono state scelte le prime 20 città italiane per numero di abitanti).

&nbsp;

# Funzioni

***foto_non_presenti_in_collezione_condivisa***
```bash
CREATE OR REPLACE FUNCTION public.foto_non_presenti_in_collezione_condivisa(
	p_id_utente integer,
	p_nome_collezione character varying)
RETURNS TABLE(id_foto integer, val_foto bytea, dispositivo character varying, città character varying, 
    	      data date, pubblica smallint, eliminata smallint, id_utente integer) 
		  
DECLARE
	v_id_collezione collezione.id_collezione%type;
	
BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );
	
	RETURN QUERY
		SELECT * 
		FROM fotografia AS f 
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0 AND f.pubblica = 1 AND
			  f.id_foto NOT IN( SELECT crf.id_foto
					    FROM collezione_raggruppa_foto AS crf
					    WHERE crf.id_collezione = v_id_collezione );
END;
```
Dopo aver recuperato l'ID dell'utente (come parametro) e l'ID della collezione condivisa (grazie alla funzione ausiliaria **recupera_id_collezione**), la funzione restituisce una query che seleziona tutte le fotografie dell'utente (pubbliche e non eliminate) che NON sono presenti nella tabella COLLEZIONE_RAGGRUPPA_FOTO, in cui ovviamente l'*id_collezione* è lo stesso di quello recuperato. 
\
\
\
***recupera_id_foto***
```bash
CREATE OR REPLACE FUNCTION public.recupera_id_foto(
	)
RETURNS integer

DECLARE
	v_id_foto integer;
	
BEGIN
	SELECT f.id_foto INTO v_id_foto
	FROM fotografia AS f
	ORDER BY f.id_foto DESC
	LIMIT 1;
	
	RETURN v_id_foto;
END;
 ```
Funzione che restituisce l'ID dell'ultima fotografia inserita, recuperata ordinando prima le fotografie in ordine decrescente (secondo l'*id_foto*), e poi utilizzando il comando **LIMIT 1**, che va a prendersi eslusivamente la prima tupla. La sua utilità è data dal fatto che, nell'applicazione JAVA, al momento esatto dell'aggiunta di una nuova fotografia, non essendo ancora in possesso dell'ID della foto, non sarebbe possibile andare ad inserire quest'ultima nelle tabelle FOTO_RAFFIGURA_UTENTE e FOTO_RAFFIGURA_SOGGETTO; non a caso viene richiamata dalle procedure ***inserisci_in_foto_raffigura_UTENTE*** ed ***inserisci_in_foto_raffigura_soggetto***.

**PS**: discorso analogo vale per la funzione ***recupera_id_video***, che viene richiamata dalla procedura ***inserisci_in_video_formato_da_foto***.
 \
 \
 \
***top_3_luoghi***
```bash
CREATE OR REPLACE FUNCTION public.top_3_luoghi(
	p_id_utente integer)
RETURNS TABLE(città character varying, n_foto bigint) 

BEGIN
	RETURN QUERY
		SELECT f.città, count(*) AS n_foto
		FROM fotografia AS f
		WHERE f.id_utente = p_id_utente AND f.eliminata = 0
		GROUP BY f.città
		ORDER BY n_foto DESC
		LIMIT 3;
END;
```
Dopo aver recuperato l'ID dell'utente (come parametro), la funzione restituisce una query che seleziona, per ogni città (**GROUP BY**), il nome della stessa e il numero totale (grazie alla funzione di sistema **count**) di fotografie dell'utente in cui essa è presente, ordinati in ordine descrescente secondo lo stesso numero totale di foto; con il comando **LIMIT 3** si vanno a recuperare esclusivamente le prime 3 città.

&nbsp; 

# Procedure
***aggiungi_fotografia***
```bash
CREATE OR REPLACE PROCEDURE public.aggiungi_fotografia(
	IN p_val_foto character varying,
	IN p_dispositivo character varying,
	IN p_citta character varying,
	IN p_id_utente integer)
BEGIN
	INSERT INTO fotografia( val_foto, dispositivo, città, pubblica, eliminata, id_utente ) 
	VALUES( pg_read_binary_file(p_val_foto), p_dispositivo, p_citta, default, default, p_id_utente );
END;
```
Procedura che effettua un semplice **INSERT** di valori nella tabella FOTOGRAFIA. Da notare però che, per inserire il valore della foto in *val_foto*, essendo di tipo bytea, è opportuno castare la stringa del path della foto (presa in input) attraverso la funzione di sistema **pg_read_binary_file**. Inoltre, i valori interi di *pubblica* ed *eliminata* non vengono passati come parametro perchè sono impostati automaticamente al valore di default (vedasi Documentazione o codice SQL della tabella FOTOGRAFIA) attraverso il comando **default**.
\
\
\
***crea_utente***
```bash
CREATE OR REPLACE PROCEDURE public.crea_utente(
	IN p_nome character varying,
	IN p_cognome character varying,
	IN p_email character varying,
	IN p_nazione character varying,
	IN p_password character varying)
BEGIN
	INSERT INTO utente( nome, cognome, email, nazione, password ) 
	VALUES( initcap(p_nome), initcap(p_cognome), lower(p_email), initcap(p_nazione), p_password );
END;
```
Come nel caso di **aggiungi_fotografia**, anche qui si tratta di un semplice **INSERT** di valori nella tabella UTENTE; si fa però notare che vengono utilizzate altre due funzioni di sistema: **initcap**, che va ad impostare, ai valori string di *nome*, *cognome* e *nazione*, la lettera maiuscola al primo carattere (come giusto che sia essendo nomi propri), e **lower**, che va ad impostare, al valore string di *email*, i caratteri minuscoli (per una questione di maggior leggibilità).
\
\
\
***crea_collezione_condivisa***
```bash
CREATE OR REPLACE PROCEDURE public.crea_collezione_condivisa(
	IN p_id_utente integer,
	IN p_email character varying,
	IN p_nome_collezione character varying)
BEGIN
	v_id_utente = recupera_id_utente( p_email );
	
	INSERT INTO collezione( personale, nome )
	VALUES( 0, p_nome_collezione );
	
	SELECT c.id_collezione INTO v_id_collezione
	FROM collezione AS c
	ORDER BY c.id_collezione DESC
	LIMIT 1;

	call inserisci_in_utente_possiede_collezione( p_id_utente, v_id_collezione );
	call inserisci_in_utente_possiede_collezione( v_id_utente, v_id_collezione );
END;
```
Dopo aver recuperato l'ID dell'utente che sta usando il sistema (come parametro), il nome da dare alla collezione condivisa (come parametro), e l'ID di un utente con cui condividere la collezione (recuperato dall'email tramite la funzione ausiliaria **recupera_id_utente**), la procedura crea la collezione condivisa in 3 passaggi:


1 - Inserisce nella tabella COLLEZIONE una nuova tupla con ID non specificato (essendo di tipo serial sarà aggiunto automaticamente), valore 0 in *personale* (essendo condivisa), e il nome della collezione in *nome*; \
2 - Attraverso la query **SELECT...INTO** va a recuperare l'ID della collezione appena creata (dunque l'ultima), inserendolo in una variabile d'appoggio; \
3 - Attraverso la procedura ausiliaria **inserisci_in_utente_possiede_collezione**, inserisce nella tabella UTENTE_POSSIEDE_COLLEZIONE le due tuple che associano l'ID della collezione condivisa recuperato al passaggio 2) con, rispettivamente, l'ID dell'utente che crea la collezione e l'ID dell'utente con cui essa è condivisa.
\
\
\
***inserisci_fotografie_in_collezione_condivisa*** 
```bash
CREATE OR REPLACE PROCEDURE public.inserisci_fotografie_in_collezione_condivisa(
	IN p_id_utente integer,
	IN p_email character varying)
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
```
Dato che questa procedura può essere effettuata solo dopo l'immediata creazione di una collezione condivisa, essa non richiede come parametro il nome della collezione, ma gli basta l'email dell'utente con cui la collezione è stata condivisa; questo perchè, dopo aver recuperato l'ID di quest'ultimo utente, proprio come nel caso di **crea_collezione_condivisa**, viene recuperato, attraverso la query **SELECT...INTO**, l'ID dell'ultima collezione inserita nella tabella COLLEZIONE. A questo punto, la procedura apre un cursore contenente tutte le fotografie (*id_foto*) pubbliche e non eliminate dei due utenti (si è preferito utilizzare una query che sfruttasse il comando **UNION**), e, successivamente, attraverso un **simple LOOP**, vengono prima recuperati e poi inseriti i suoi valori (associati all'*id_collezione* recuperato prima) all'interno della tabella COLLEZIONE_RAGGRUPPA_FOTO. 

**PS**: una versione alternativa e più ottimizzata di questa procedura è quella di inserire direttamente i valori nella tabella COLLEZIONE_RAGGRUPPA_FOTO, senza sfruttare l'utilizzo di un cursore, che, in questa situazione, non è assolutamente necessario.
\
\
\
***elimina_fotografia***
```bash
CREATE OR REPLACE PROCEDURE public.elimina_fotografia(
	IN p_id_foto integer,
	IN p_id_utente integer)
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
```
Questa procedura inizialmente va a contare, attraverso la funzione di sistema **count**, il numero di fotografie dell'utente presenti nella tabella COLLEZIONE_RAGGRUPPA_FOTO che hanno lo stesso ID della foto passata come parametro; questo conteggio, che è inserito in una variabile d'appoggio, serve a controllare quante stesse fotografie sono presenti nel sistema, o, ancora meglio, in quante collezioni diverse una stessa fotografia è presente; difatti, a questo punto, nell'**IF...ELSEIF** successivo, abbiamo che:


1 - se la foto è presente una sola volta, allora si può procedere tranquillamente alla sua eliminazione dal sistema, eliminandola direttamente dalla tabella FOTOGRAFIA; \
2 - se la foto è presente più di una volta, allora la si elimina solamente dalla collezione personale dell'utente, ovvero dalla tabella COLLEZIONE_RAGGRUPPA_FOTO in cui l'ID della collezione è uguale a quello dell'utente;
\
\
\
***elimina_fotografia_in_collezione_condivisa***
```bash
CREATE OR REPLACE PROCEDURE public.elimina_fotografia_in_collezione_condivisa(
	IN p_id_foto integer,
	IN p_nome_collezione character varying)
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
```
Procedura molto molto simile ad **elimina_fotografia**, con la differenza che, dato che la fotografia deve essere eliminata da una collezione condivisa, innanzitutto necessita di andare a recuperare l'ID della collezione (attraverso la funzione ausiliaria **recupera_id_collezione**); successivamente, nell'**IF...ELSEIF**, va a controllare:


1 - se la foto è presente una sola volta, allora anche qui si procede alla sua eliminazione dal sistema; \
2 - se la foto è presente più di una volta, invece, la si elimina solamente dalla collezione condivisa in questione, ovvero dalla tabella COLLEZIONE_RAGGRUPPA_FOTO in cui l'ID della collezione è uguale a quello recuperato in precedenza;
\
\
\
***elimina_fotografie_in_collezione_condivisa***
```bash
CREATE OR REPLACE PROCEDURE public.elimina_fotografie_in_collezione_condivisa(
	IN p_nome_collezione character varying)
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
		call elimina_fotografia_in_collezione_condivisa_2( foto_attuale.id_foto, v_id_collezione );
	END LOOP;
	
	CLOSE cursore_foto;
END; 
```
Procedura che, dopo aver inizialmente recuperato l'ID della collezione attraverso la solita funzione ausiliaria **recupera_id_collezione**, apre un cursore con tutte le foto di quella collezione; a questo punto, scorre ogni singola foto del cursore con un **simple LOOP** e, per ognuna di esse, viene chiamata la procedura ausiliara **elimina_fotografia_in_collezione_condivisa_2**, che provvederà alla corretta eliminazione di ognuna di esse.

**PS**: la funzione **elimina_fotografia_in_collezione_condivisa_2** non è altro che la funzione **elimina_fotografia_in_collezione_condivisa**, con l'unica differenza che accetta come parametro direttamente l'ID della collezione piuttosto che il suo nome.

**PS**: si fa notare che, a differenza di **inserisci_fotografie_in_collezione_condivisa**, questa procedura richiede l'utilizzo obbligatorio di un cursore, dato che occorre valutare l'ID di ogni singola tupla per la chiamata alla procedura **elimina_fotografia_in_collezione_condivisa_2**.
\
\
\
***elimina_collezione_condivisa***
```bash
CREATE OR REPLACE PROCEDURE public.elimina_collezione_condivisa(
	IN p_nome_collezione character varying)
DECLARE
	v_id_collezione collezione.id_collezione%type;

BEGIN
	v_id_collezione = recupera_id_collezione( p_nome_collezione );

	call elimina_fotografie_in_collezione_condivisa( p_nome_collezione );
	
	DELETE FROM collezione AS c
	WHERE c.id_collezione = v_id_collezione;
END; 
```
Questa procedura si occupa, innanzitutto, di eliminare correttamente tutte le foto della collezione condivisa in procinto di essere eliminata attraverso la chiamata alla procedura **elimina_fotografie_in_collezione_condivisa**; successivamente, va ad effettuare l'ovvia eliminazione della stessa dalla tabella COLLEZIONE. 
\
\
\
***truncate_tabelle*** 
```bash
CREATE OR REPLACE PROCEDURE public.truncate_relazioni(
	)
BEGIN
	TRUNCATE utente RESTART identity CASCADE;
	TRUNCATE collezione RESTART identity CASCADE;
	TRUNCATE fotografia RESTART identity CASCADE;	
	TRUNCATE video RESTART identity CASCADE;
END;
```
Procedura utile per resettare i dati del DB (riempito ad esempio con popolamenti di prova); difatti, si occupa di eliminare, attraverso il comando **TRUNCATE**, tutte le tuple presenti nelle tabelle UTENTE, COLLEZIONE, FOTOGRAFIA, VIDEO, e, di conseguenza, grazie all'opzione **CASCADE**, tutte le tuple che referenziano le loro chiavi primarie. Si è usato il comando TRUNCATE invece di DELETE perchè, da come si può notare, ammette l'utilizzo della clausola **RESTART identity**, che permette l'azzeramento di tutti i valori serial delle chiavi primarie. Le tabelle LUOGO, SOGGETTO e AMMINISTRATORE sono esenti dal TRUNCATE, dato che, a prescindere dai diversi popolamenti, le categorie di soggetti, le città e l'amministratore restano immutati.

&nbsp;

# Trigger
***collezione_condivisa_dopo_fotografia_privata***
```bash
CREATE TRIGGER collezione_condivisa_dopo_fotografia_privata
    AFTER UPDATE 
    ON public.fotografia
    FOR EACH ROW
    WHEN (old.pubblica = 1 AND new.pubblica = 0)
    EXECUTE FUNCTION public.collezione_condivisa_dopo_fotografia_privata();
```
```bash
CREATE OR REPLACE FUNCTION public.collezione_condivisa_dopo_fotografia_privata()
RETURNS trigger

BEGIN
	DELETE FROM collezione_raggruppa_foto AS crf
	WHERE crf.id_collezione <> NEW.id_utente AND crf.id_foto = NEW.id_foto;
	
	RETURN NULL;
END;
```
Trigger che si attiva esclusivamente dopo la modifica di una foto da pubblica a privata; si occupa di eliminare dalla tabella COLLEZIONE_RAGGRUPPA_FOTO tutte le tuple che hanno *id_collezione* diverso da quello dell'utente che possiede la foto (appena modificata), andando cosi a rimuovere la foto da ogni collezione condivisa in cui è presente eccetto ovviamente quella personale.
\
\
\
***collezione_gia_condivisa***
```bash
CREATE TRIGGER collezione_gia_condivisa
    AFTER INSERT
    ON public.utente_possiede_collezione
    FOR EACH ROW
    WHEN (new.id_utente <> new.id_collezione)
    EXECUTE FUNCTION public.collezione_gia_condivisa();
```
```
CREATE OR REPLACE FUNCTION public.collezione_gia_condivisa()
RETURNS trigger

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
```
Trigger che si attiva esclusivamente dopo l'inserimento di un nuovo utente in una collezione condivisa (e dunque quando in UTENTE_POSSIEDE_COLLEZIONE si avrà che *id_utente* è diverso da *id_collezione*, altrimenti si tratterebbe di una creazione di collezione personale); si occupa di contare quante tuple con lo stesso *id_utente* e ontemporaneamente lo stesso *id_collezione* sono presenti nella tabella UTENTE_POSSIEDE_COLLEZIONE, e, se il numero è maggiore di 1, solleva un eccezione per avvisare che nella collezione in questione è già presente l'utente in procinto di essere aggiunto.
\
\
\
***controllo_email***
```bash
CREATE TRIGGER controllo_email
    AFTER INSERT
    ON public.utente
    FOR EACH ROW
    EXECUTE FUNCTION public.controllo_email();
```
```bash
CREATE OR REPLACE FUNCTION public.controllo_email()
RETURNS trigger

DECLARE
    email_pattern VARCHAR = '[A-Za-z0-9]{2,}@[A-Za-z0-9]{2,}\.[A-Za-z]{2,}';

BEGIN
    IF NEW.email !~ email_pattern
       THEN RAISE EXCEPTION 'Inserire un indirizzo email valido!';
    END IF;
	
    RETURN NULL;
END; 
```
Trigger che si attiva dopo la creazione di un nuovo utente; si occupa di dichiarare una stringa di pattern contentente un espressione regolare, precisamente POSIX. L'espressione consiste in una parola di almeno 2 caratteri seguita da una @, a sua volta seguita da altre due parole di almeno 2 caratteri separate da un punto. Se l'email appena inserita è diversa dal pattern, viene sollevata un'eccezione che richiede di reinserire l'email; da notare che, per confrontare l'email con il pattern, viene usato il simbolo "**!~**", che restituisce "true" se le due stringhe NON corrispondono. 

**PS**: discorso analogo vale per il trigger ***controllo_password***.
\
\
\
***fotografie_dopo_eliminazione_utente***
```bash
CREATE TRIGGER fotografie_dopo_eliminazione_utente
    AFTER DELETE
    ON public.utente
    FOR EACH ROW
    EXECUTE FUNCTION public.fotografie_dopo_eliminazione_utente();
```
```bash
CREATE OR REPLACE FUNCTION public.fotografie_dopo_eliminazione_utente()
RETURNS trigger

BEGIN
	DELETE FROM fotografia AS f
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
									WHERE crf.id_foto = f.id_foto 
								              AND crf.id_collezione <> OLD.id_utente)));
	
	RETURN NULL;
END;  
```
Trigger che si attiva naturalmente dopo l'eliminazione di un utente dal sistema; si ricorda che, all'eliminazione di esso, le FK (riferite all'utente) delle tuple di FOTOGRAFIA vengono impostate a NULL. A questo punto, si deve procedere con l'eliminazione delle fotografie, che, come da vincolo richiesto (vedasi Documentazione), devono essere tutte quelle dell'utente eliminato eccetto quelle che raffigurano utenti di una collezione condivisa in cui esse sono presenti. La **DELETE** utilizzata per effettuare ciò, partendo dall'alto verso il basso, è strutturata come segue:

1 - eliminare tutte le foto in cui l'*id_utente* della foto è NULL (che quindi si riferiscono all'utente appena eliminato) e che, contemporaneamente, l'*id_foto*...\
2 - non è presente nella tabella FOTO_RAFFIGURA_UTENTE dove l'*id_utente*...\
3 - si trova nella tabella UTENTE_POSSIEDE_COLLEZIONE in cui l'*id_collezione*...\
4 - è presente nella tabella COLLEZIONE_RAGGRUPPA_FOTO in cui al suo interno gli è associato lo stesso *id_foto*, e in cui l'*id_collezione* è diverso dal vecchio ID dell'utente eliminato (quest'ultima condizione potrebbe anche essere trascurata, dato che tutti i riferimenti alla collezione personale dell'utente eliminato vengono già cancellaie dal trigger **collezione_personale_dopo_eliminazione_utente**, che si attiva prima di **fotografie_dopo_eliminazione_utente**).

Saranno dunque eliminate tutte le foto che hanno *id_utente* uguale a NULL (punto 1), ma che devono rispettare anche la condizione di **non** raffigurare degli utenti (punto 2) che sono partecipanti ad una collezione condivisa in cui naturalmente esse sono presenti (punto 3 e 4). Leggendola dal basso verso l'alto: 

4 - il punto 4 fa si che si vadano a selezionare tutte le collezioni condivise (*crf.id_collezione <> OLD.id_utente*) che contengono la foto da eliminare (*crf.id_foto = f.id_foto*); \
3 - il punto 3 va a selezionare tutti gli utenti che partecipano alle collezioni condivise recuperate nel punto 4; \
2 - il punto 2 va invece a selezionare tutte le foto che raffigurano gli utenti recuperati al punto 3; \
1 - al termine della catena, il punto 1 va ad eliminare le foto che hanno l'*id_utente* uguale a NULL e l'*id_foto* **non** sono presente tra le foto recuperate al punto 2.

&nbsp;

# Viste
***numero_totale_fotografie_e_utenti***
```bash
CREATE OR REPLACE VIEW public.numero_totale_fotografie_e_utenti
 AS
 SELECT ( SELECT count(*) AS count
           FROM utente) AS totale_utenti,
    ( SELECT count(*) AS count
```
	   
L'unica vista presente nel sistema; essa, sfruttando la possibilità (in Postgres) di effettuare multiple selezioni all'interno dello stesso comando **SELECT**, va a recuperare il numero totale di utenti e di fotografie presenti nel sistema in un'unica tupla. Si è pensato il suo utilizzo all'interno della pagina dell'amministratore, per dargli una panoramica generale della situazione.
