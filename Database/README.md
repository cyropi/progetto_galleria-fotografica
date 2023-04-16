# Database

Per testare il Database, potrebbe essere utile interagire con esso attraverso Postgres:
- [Download PostgreSQL](https://www.postgresql.org/download/) (DBMS)
- [Download pgAdmin](https://www.pgadmin.org/download/) (Interfaccia grafica per semplificarne la gestione)

\
Nella cartella **GalleriaFotograficaSQL** si troverà il codice sorgente, in linguaggio SQL, usato per la creazione e lo sviluppo del database.

Nella cartella **GalleriaFotograficaDB.zip** si troveranno, invece, una serie di files compressi ed estrapolati dal database già creato. Una volta scaricata ed
esratta, la cartella ZIP può essere usato all'interno di Postgres per ripristinare il database senza doverlo creare manualmente. La procedura da seguire è la seguente:

```bash
- Aprire pgAdmin
- Creare un nuovo DB
- Tasto destro sul DB appena creato
- Cliccare su "Restore..."
- Nella sezione "General", inserire "Directory" come format
- Recuperare la cartella estratta precedentemente ed inserirla come filename
- Completare il procedimento
```
