# Progetto Basi di Dati - Ufficio Acquisti di un ente pubblico

Progetto di laboratorio del corso di Basi di Dati e Laboratorio dell'Università degli Studi di Udine A.A. 2020/2021, relativo alla progettazione di una base di dati per l'**ufficio acquisti di un ente pubblico**. La consegna originale è disponibile al file `Consegna.pdf` (*Esercizio 3*).

## Progettazione e sviluppo della Base di Dati

L'attività progettuale è stata descritta nel report (contenuto in formato pdf e markdown all'interno della cartella `report`). I diagrammi prodotti e riportati all'interno del report sono accessibili, in formato `.drawio` e `.png`, all'interno della directory `ER`. 

## Creazione della base di dati

Per fini analitici o di testing, è sufficiente:

1. **Localizzarsi nella directory psqlOnDocker**

```bash

cd psqlOnDocker/

```

2. **Eseguire il docker container e attenderne l'inizializzazione**

```docker

# Add -d flag to run in detach mode
docker compose up

``` 

3. **Creare il database**

```bash

make db

```

È possibile, successivamente, accedere al database tramite le seguenti credenziali

| **Parametro** | **Valore**  |
|---------------|-------------|
|  Indirizzo    | `localhost` |
|  Porta        | `15000`     |
|  Utente       | `postgres`  |
|  Password     | `bdd2021`   |

## Creazione dei dati di mockup

È possibile effettuare una nuova generazione dei dati di mockup tramite il seguente procedimento: 

1. **Localizzarsi nella directory psqlOnDocker**

```bash

cd psqlOnDocker/

```

2. **Lanciare la generazione**

```bash

make mockup

```

I file sql generati **sovrascriveranno** quelli già presenti all'interno della directory `psqlOnDocker/sql`

## Analisi dei dati

I dati di Mockup sono stati analizzati all'interno del notebook **RMarkdown** presente al percorso file `R/DataAnalysis.Rmd`. I grafici sono stati, inoltre, prodotti in formato `.png` all'interno della directory `R/analysisPlots`. 

Un'ulteriore analisi è stata svolta al fine di valutare l'inserimento di ulteriori indici all'interno della base di dati. Quest'ultima è stata descritta all'interno del file `R/IndexEval.R`. Analogamente, i grafici sono stati prodotti all'interno della directory `R/plots` e i dati raccolti sono stati serializzati in formato `.csv` all'interno della directory `R/csv`.
