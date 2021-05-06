---
title: "Relazione Progetto Basi di Dati - A.A. 2020-2021"
author: |
        | Francesco Bombassei De Bona (144665)
        | Andrea Cantarutti (141808)
        | Lorenzo Bellina (142544)
		| Alessandro Fabris (142520)
date: "01/05/2021"
output:
header-includes:
  - \usepackage{amsmath}
  - \usepackage[margin=0.8in]{geometry}
  - \usepackage[utf8]{inputenc}
  - \usepackage[italian]{babel}
  - \usepackage{graphicx}
  - \usepackage{xcolor}
  - \usepackage[normalem]{ulem}
  - \usepackage{float}
  - \usepackage{array}
  - \usepackage{multirow} 
  - \usepackage{bigstrut}
  - \hypersetup{colorlinks=true,
            linkcolor=blue,
            urlcolor=blue,
            allbordercolors={0 0 0},
            pdfborderstyle={/S/U/W 1}}
  - \usepackage{caption}
---

\captionsetup{labelformat=empty}
\newpage
\definecolor{darkgreen}{RGB}{69,151,84}
\definecolor{lightblue}{RGB}{3,219,252}
```{=latex}
% https://www.tablesgenerator.com
```

# Introduzione

Il presente elaborato espone l'attività di progettazione e implementazione di una Base di Dati relazionale, assieme all'attività di analisi dei dati ottenuti da un'applicazione della stessa. Scrivo anche delle altre parole giusto per dare un po' di corpo a questa introduzione altrimenti troppo corta, ma lo faccio solo perchè mantenga l'impaginazione perchè poi tutte queste frasi le cancelleremo.

\newpage

# Analisi dei requisiti

## Requisiti

La consegna assegnata riporta requisiti il cui **dominio di interesse** è relativo al sistema di gestione dell'*ufficio acquisti di un ente pubblico*. 

```{=latex}
% Consegna iniziale

\setlength{\fboxsep}{1em}
\noindent\fbox{%
    \parbox{\textwidth}{%
    	Si vuole realizzare una base di dati per la gestione dell'ufficio acquisti di un ente pubblico caratterizzato dal
seguente insieme di requisiti:
		\\
		\begin{itemize}
			\item l'ente sia organizzato in un certo insieme di dipartimenti, ciascuno identificato univocamente da un codice e caratterizzato da una breve descrizione e dal nominativo del responsabile (si assuma che ogni dipartimento abbia un unico responsabile e che una stessa persona possa essere responsabile di più dipartimenti);
			\\
			\item ogni dipartimento possa formulare delle richieste d'acquisto; ogni richiesta d'acquisto formulata da un dipartimento sia caratterizzata da un numero progressivo, che la identifica univocamente all'interno dell'insieme delle richieste del dipartimento (esempio, richiesta numero 32 formulata dal dipartimento D37), da una data (si assuma che uno stesso dipartimento possa effettuare più richieste in una stessa data), dall'insieme degli articoli da ordinare, con l'indicazione, per ciascun articolo, della quantità richiesta, e dalla data prevista di consegna;
			\\
			\item ogni articolo sia identificato univocamente da un codice articolo e sia caratterizzato da una breve descrizione, da una unità di misura e da una classe merceologica;
			\\
			\item ogni fornitore sia identificato univocamente da un codice fornitore e sia caratterizzato dalla partita IVA, dall'indirizzo, da uno o più recapiti telefonici e da un indirizzo di posta elettronica; alcuni fornitori (non necessariamente tutti) possiedano un numero di fax;
			\\
			\item ad ogni fornitore sia associato un listino, comprendente uno o più articoli; per ciascun articolo appartenente ad un dato listino siano specificati il codice articolo, il prezzo unitario, il quantitativo minimo d'ordine e lo sconto applicato;
			\\
			\item per soddisfare le richieste provenienti dai vari dipartimenti, l'ufficio acquisti emetta degli ordini; ogni ordine sia identificato univocamente da un codice ordine e sia caratterizzato dalla data di emissione, dal fornitore a cui viene inviato, dall'insieme degli articoli ordinati, con l'indicazione, per ciascuno di essi, della quantità ordinata, e dalla data prevista di consegna (si assuma che un ordine possa fondere insieme più richieste d'acquisto dei dipartimenti).
		\end{itemize}
	}%
}
```

\

Sulla base di quanto riportato, si procede alla formulazione di un glossario che permette la definizione univoca dei concetti esposti. 

\newpage

## Glossario

La terminologia individuata appartente al dominio di interesse e correlata alla strutturazione della Base di Dati è presentata di seguito: 

```{=latex}
% glossario dei termini

\begin{table}[h]
\renewcommand{\arraystretch}{2}
\centering
\begin{tabular}{|p{0.13\textwidth}|p{0.45\textwidth}|p{0.10\textwidth}|p{0.23\textwidth}|}
\hline
\textbf{Termine} & \textbf{Descrizione} & \textbf{Sinonimi} & \textbf{Relazioni}                 
\\ \hline
Dipartimento & Sottosezione organizzativa dell'ente &   & Responsabile, Richiesta d'acquisto     
\\ \hline
Responsabile & Persona incaricata delle responsabilità relativa ad uno o più dipartimenti &    & Dipartimento                          \\ \hline
Richiesta d'acquisto & Documento, formulato da un dipartimento, riportante i riferimenti agli articoli da ordinare, con annesse specifiche & Richiesta & Dipartimento, Articolo             \\ \hline
Articolo & Elemento atomico richiedibile ed ordinabile &   & Richiesta d'acquisto, Listino, Ordine 
\\ \hline
Fornitore & Azienda che provvede alla fornitura di articoli per l'ente &   & Listino, Ordine
\\ \hline
Listino & Catalogo contenente uno o più articoli relativi ad un fornitore &  & Articolo, Fornitore
\\ \hline
Ordine & Insieme di articoli richiesti dall'ufficio acquisti ad un fornitore per uno o più dipartimenti &  & Articolo, Fornitore
\\ \hline
\end{tabular}
\end{table}
```

\newpage

## Ristesura e strutturazione dei requisiti

A seguito dell'identificazione e organizzazione delle terminologie riportate nel precedente glossario, si identificano e raggruppano le frasi relative a requisiti espressi in linguaggio naturale sulla base di ciò che esse riferiscono.

```{=latex}

% requisiti ristrutturati

\begin{table}[H]
\renewcommand{\arraystretch}{1}
\centering
\begin{tabular}{|p{0.91\textwidth}|}
\hline
\multicolumn{1}{|c|}{\textbf{Dipartimento}}
\\ \hline
\begin{itemize}
\item Ciascuno identificato univocamente da un codice e caratterizzato da una breve descrizione e dal nominativo del responsabile
\newline
\item Si assuma che ogni dipartimento abbia un unico responsabile
\newline
\item Ogni dipartimento possa formulare delle richieste d’acquisto 
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Responsabile}}
\\ \hline
\begin{itemize}
\item Una stessa persona possa essere responsabile di più dipartimenti
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Richiesta d'Acquisto}}
\\ \hline
\begin{itemize}
\item Caratterizzata da un numero progressivo, che la identifica univocamente all’interno dell’insieme delle richieste del dipartimento, da una data, dall’insieme degli articoli da ordinare, con l’indicazione, per ciascun articolo, della quantità richiesta, e dalla data prevista di consegna
\newline
\item Si assuma che uno stesso dipartimento possa effettuare più richieste in una stessa data
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Articolo}}
\\ \hline
\begin{itemize}
\item Ogni articolo sia identificato univocamente da un codice articolo e sia caratterizzato da una breve descrizione, da una unità di misura e da una classe merceologica
\newline
\item Per ciascun articolo appartenente ad un dato listino siano specificati il codice articolo, il prezzo unitario, il quantitativo minimo d’ordine e lo sconto applicato
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Fornitore}}
\\ \hline
\begin{itemize}
\item Ogni fornitore sia identificato univocamente da un codice fornitore e sia caratterizzato dalla partita IVA, dall’indirizzo, da uno o più recapiti telefonici e da un indirizzo di posta elettronica; alcuni fornitori (non necessariamente tutti) possiedano un numero di fax
\newline
\item Ad ogni fornitore sia associato un listino 
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Listino}}
\\ \hline
\begin{itemize}
\item Comprendente uno o piu` articoli
\newline
\item Per ciascun articolo appartenente ad un dato listino siano specificati il codice articolo, il prezzo unitario, il quantitativo minimo d’ordine e lo sconto applicato
\end{itemize}
\\ \hline
\multicolumn{1}{|c|}{\textbf{Ordine}}
\\ \hline
\begin{itemize}
\item Ogni ordine sia identificato univocamente da un codice ordine e sia caratterizzato dalla data di emissione, dal fornitore a cui viene inviato, dall’insieme degli articoli ordinati, con l’indicazione, per ciascuno di essi, della quantità ordinata, e dalla data prevista di consegna
\newline
\item Si assuma che un ordine possa fondere insieme piu` richieste d’acquisto dei dipartimenti
\end{itemize}
\\ \hline
\end{tabular}
\end{table}
```

## Individuazione dei principali requisiti operazionali {#op-frequenti}

Sulla base dei requisiti individuati, si descrivono le principali operazioni, con rispettiva frequenza, sui dati. Si considera, per dare consistenza al conteggio, un ente costituito da trenta dipartimenti e associato a cinque fornitori diversi. 

\
\

| **Operazione** | **Frequenza** |
|-|-|
|Inserimento di una richiesta d'acquisto|150/settimana|
|||
|Aggiornamento dello stato di una richiesta d'acquisto|7/settimana|
|||
|Aggiornamento dello stato di un ordine|3/settimana|
|||
|Visualizzazione delle informazioni relative ad una richiesta d'acquisto|60/settimana|
|||
|Visualizzazione degli articoli contenuti in una richiesta d'acquisto|60/settimana|
|||
|Visualizzazione degli articoli ordinati e non consegnati|20/settimana|
|||
|Inserimento di un nuovo ordine|5/settimana|
|||
|Visualizzazione di tutti gli articoli|500/settimana|
|||
|Calcolo della spesa mensile dei dipartimenti e dell'ente|30/mese|

\newpage

## Criteri per la rappresentazione dei concetti

Sulla base del documento di specifiche, si inviduano i criteri opportuni per la rappresentazione dei concetti descritti.

```{=latex}

% rappresentazione dei concetti

\setlength{\fboxsep}{0.6em}
\noindent\fbox{%
    \parbox{\textwidth}{%
		\begin{itemize}
			\item l'ente sia organizzato in un certo insieme di \textbf{\textcolor{red}{dipartimenti}}, ciascuno identificato univocamente da un \textbf{\textcolor{darkgreen}{codice}} e caratterizzato da una breve \textbf{\textcolor{darkgreen}{descrizione}} e dal nominativo del \textbf{\textcolor{red}{responsabile}} (si assuma che \textbf{\textcolor{blue}{ogni dipartimento abbia un unico responsabile e che una stessa persona possa essere responsabile di più dipartimenti}});
			\\
			\item ogni dipartimento possa formulare delle \textbf{\textcolor{red}{richieste d'acquisto}}; ogni richiesta d'acquisto \textbf{\textcolor{blue}{formulata da un dipartimento}} sia caratterizzata da un \textbf{\textcolor{darkgreen}{numero progressivo}}, che la identifica univocamente all'interno dell'insieme delle richieste del dipartimento (esempio, richiesta numero 32 formulata dal dipartimento D37), da una \textbf{\textcolor{darkgreen}{data}} (si assuma che uno stesso dipartimento possa effettuare più richieste in una stessa data), dall'\textbf{\textcolor{blue}{insieme degli articoli da ordinare}}, con l'indicazione, per ciascun \textbf{\textcolor{red}{articolo}}, della \textbf{\textcolor{lightblue}{quantità richiesta}}, e dalla \textbf{\textcolor{lightblue}{data prevista di consegna}};
			\\
			\item ogni articolo sia identificato univocamente da un \textbf{\textcolor{darkgreen}{codice articolo}} e sia caratterizzato da una \textbf{\textcolor{darkgreen}{breve descrizione}}, da una \textbf{\textcolor{darkgreen}{unità di misura}} e da una \textbf{\textcolor{darkgreen}{classe merceologica}};
			\\
			\item ogni \textbf{\textcolor{red}{fornitore}} sia identificato univocamente da un \textbf{\textcolor{darkgreen}{codice fornitore}} e sia caratterizzato dalla \textbf{\textcolor{darkgreen}{partita IVA}}, dall'\textbf{\textcolor{darkgreen}{indirizzo}}, da \textbf{\textcolor{darkgreen}{uno o più recapiti telefonici}} da un \textbf{\textcolor{darkgreen}{indirizzo di posta elettronica}}; alcuni fornitori (non necessariamente tutti) possiedano un \textbf{\textcolor{darkgreen}{numero di fax}};
			\\
			\item \textbf{\textcolor{blue}{ad ogni fornitore sia associato}} \textbf{\textcolor{brown}{un listino}}, \textbf{\textcolor{blue}{comprendente uno o più articoli}}; per ciascun articolo appartenente ad un dato listino siano specificati il \textbf{\textcolor{lightblue}{codice articolo}}, il \textbf{\textcolor{lightblue}{prezzo unitario}}, il \textbf{\textcolor{lightblue}{quantitativo minimo d'ordine}} e lo \textbf{\textcolor{lightblue}{sconto applicato}};
			\\
			\item per soddisfare le richieste provenienti dai vari dipartimenti, l'ufficio acquisti emetta degli \textbf{\textcolor{red}{ordini}}; ogni ordine sia identificato univocamente da un \textbf{\textcolor{darkgreen}{codice d'ordine}} e sia caratterizzato dalla \textbf{\textcolor{darkgreen}{data di emissione}}, dal \textbf{\textcolor{blue}{fornitore a cui viene inviato}}, dall'\textbf{\textcolor{blue}{insieme degli articoli ordinati}}, con l'indicazione, per ciascuno di essi, della \textbf{\textcolor{lightblue}{quantità ordinata}}, e dalla \textbf{\textcolor{lightblue}{data prevista di consegna}} (si assuma che un ordine possa fondere insieme più richieste d'acquisto dei dipartimenti).
		\end{itemize}
		\begin{table}[H]
		\centering
		\begin{tabular}{llllll}
		\hline
		\textbf{Legenda}: & \textbf{\textcolor{red}{Entità}} & \textbf{\textcolor{darkgreen}{Attributo}} & \textbf{\textcolor{brown}{Ambiguità}} & \textbf{\textcolor{blue}{Relazioni}} & \textbf{\textcolor{lightblue}{Attributi di relazione}} \\ 
		\end{tabular}
		\end{table}
	}%
}
```
### Assunzioni in merito alle ambiguità rilevate

Sulla base di quanto riportato nelle specifiche sopracitate, si è osservato come il concetto di **listino** delinei l'insieme di articoli associati al rispettivo fornitore senza, però, aggiungere informazioni supplementari in merito a tale relazione. Si è, pertanto, deciso di **non** rappresentare il listino all'interno della Basi di Dati ma di, piuttosto, rappresentare l'associazione fra un singolo articolo e il rispettivo fornitore. 

Si assume che un articolo possa essere fornito da un insieme di fornitori e che, di conseguenza, mentre una richiesta d'acquisto si rivolge agli articoli, è responsabilità dell'ufficio acquisti l'individuazione dello specifico fornitore, in merito ad aspetti logistici e di convenienza.

Si assume, inoltre, che sia di interesse dell'ente la possibilità di ricondurre un ordine alle richieste d'acquisto che esso soddisfa e una richiesta d'acquisto agli ordini che la coinvolgono.

Infine, sapendo che un ordine coinvolge al più un fornitore e che gli articoli inclusi nelle richieste d'acquisto possono potenzialmente provenire da fornitori diversi si assume che:

- Un singolo ordine possa soddisfare una richiesta d'acquisto anche parzialmente;
- Per ogni articolo coinvolto, venga soddisfatta la quantità specificata. 

\newpage

# Progettazione concettuale

## Diagramma ER

\begin{figure}[H]
\centering
\includegraphics[width=510px]{../ER.png}
\end{figure}

\newpage

## Osservazioni

Sulla base del diagramma ER proposto, si riportano le osservazioni effettuate, includendo i **vincoli aziendali** individuati e le **regole di derivazione** degli attributi derivati.

### Vincoli aziendali {#vincoli}

Il diagramma presenta un singolo ciclo che coinvolge le entità *Ordine*, *Articolo* e *Fornitore*. Sulla base di quanto riportato nei requisiti si introduce il seguente vincolo aziendale: \emph{\textbf{il fornitore degli articoli relativi ad un ordine deve essere il medesimo di quello associato all'ordine stesso}}. 

Inoltre, si evidenzia come la **data di consegna di un articolo** relativo ad una richiesta d'acquisto possa essere calcolata solo successivamente alla partecipazione di un ordine alla relazione. Questo è motivato dal fatto che la data prevista di consegna è valutabile conoscendo la data di emissione dell'ordine.

### Regole di derivazione

Gli attributi derivati, con rispettive regole di derivazione, sono riportati di seguito: 

1. L'attributo **Stato Richiesta** dell'entità *Richiesta d'Acquisto* viene derivato valutando lo stato di tutti gli *Ordini* associati ad una specifica richiesta.  
2. L'attributo **Data Prevista di Consegna** della relazione *Include* viene derivato sommando al valore dell'attributo **Data Emissione** dell'entità *Ordine* quello dell'attributo **Tempo di Consegna** della relazione *Fornisce*. 

### Considerazioni

Si suppone che, nel caso della prima regola di derivazione esplicitata, la valutazione dell'attributo **Stato Richiesta** sia definita da una funzione che, sulla base dell'insieme dei rispettivi *ordini*, individua quello/i con *stato* meno avanzato. Una completa richiesta d'acquisto risulterà, infatti, conclusasi completamente solo quando tutti gli ordini che la soddisfano saranno giunti a destinazione presso il dipartimento.

Inoltre, la partecipazione dell'entità *Ordine* alla relazione ternaria che coinvolge le entità *Richiesta d'Acquisto*, *Ordine* e *Articolo* sia **opzionale**. Quest'ultima avverrà, infatti, solamente al momento in cui l'ufficio acquisti emetterà un ordine atto a soddisfare l'articolo incluso in una specifica richiesta. 

\newpage

# Progettazione logica

## Analisi delle ridondanze

### Analisi dei cicli

Come specificato precedentemente, l'unico ciclo presente nello schema ER coinvolge le entità **Ordine**, **Articolo** e **Fornitore**. Un ordine, infatti, deve essere rivolto ad uno specifico fornitore e, pertanto, gli articoli contenuti devono necessariamente provenire tutti dallo stesso fornitore.

Considerato il fatto che il medesimo articolo può essere fornito da più fornitori, al fine di poter strutturare un ordine è necessario sapere il fornitore che lo evaderà e gli articoli in esso contenuti. Non è, pertanto, possibile effettuare un'eliminazione del ciclo senza la conseguente perdita di informazione necessaria al corretto comportamento della Base di Dati. Pertanto, il ciclo viene mantenuto e vincolato sulla base delle osservazioni effettuate al punto [3.2](#vincoli).

### Attributi derivabili

Al fine di valutare il mantenimento o l'eliminazione delle ridondanze presenti nel diagramma ER proposto, si definisce, di seguito, la tavola dei volumi di entità e relazioni presenti nella Base di Dati.

|Concetto|Tipo|Volume|
|-|:-:|-:|
|Responsabile|E|25|
|Dipartimento|R|30|
|Richiesta d'Acquisto|E|6000|
|Articolo|E|500|
|Ordine|E|200|
|Fornitore|E|5|
|Include|R|60000|
|Fornisce|R|750|

Si fa riferimento, inoltre, alle operazioni frequenti riportate al punto [2.4](#op-frequenti).

Si analizzano, quindi, le ridondanze in merito agli attributi derivati **Stato Richiesta** dell'entità *Richiesta d'Acquisto* e **Data Prevista di Consegna** della relazione *Include*.

#### Stato Richiesta

L'attributo è coinvolto nelle operazioni di **Aggiornamento dello stato di una Richiesta d'Acquisto** [`7/settimana`] e quelle di **Visualizzazione delle informazioni relative ad una Richiesta d'Acquisto** [`60/settimana`]. Si riportano, di seguito, le tavole degli accessi in presenza e assenza dell'attributo derivato, assieme alla rispettiva valutazione del costo di esecuzione.

Nel caso di **presenza** dell'attributo derivato, si prevedono gli accessi seguenti:


```{=latex}

% stato richiesta d'acquisto in presenza dell'attributo

\begin{table}[H]
\caption {\textbf{Aggiornamento dello stato di una richiesta d'acquisto}}
\centering
\begin{tabular}{|l|l|l|l|}
\hline
\textbf{Concetto}    & \textbf{Tipo} & \textbf{Accessi} & \textbf{Tipo di accesso} \\ \hline
Ordine               & E    & 5       & R               \\ \hline
Include              & R    & 5       & R               \\ \hline
Richiesta d'Acquisto & E    & 1       & W               \\ \hline
\end{tabular}
\end{table}

\begin{table}[H]
\caption[Caption for LOF]{\textbf{Visualizzazione dello stato di una richiesta d'acquisto}\footnotemark}
\centering
\begin{tabular}{|l|l|l|l|}
\hline
\textbf{Concetto}    & \textbf{Tipo} & \textbf{Accessi} & \textbf{Tipo di accesso} \\ \hline
Richiesta d'Acquisto & E             &    1             &           R               \\ \hline
\end{tabular}
\end{table}

```

\footnotetext{Lo stato è ottenuto tramite l'operazione di visualizzazione delle informazioni relative ad una richiesta d'acquisto}

Considerando il costo in scrittura pari al doppio del costo in lettura e le frequenze precedentemente riportate, si osserva che il costo di **aggiornamento** è pari a $7\cdot(5\cdot1 + 5\cdot1 + 1\cdot2) = 84$ e quello di **visualizzazione** è pari a $60\cdot(1\cdot1) = 60$. Di conseguenza, il costo complessivo in presenza dell'attributo derivato è pari a $$ 84 + 60 = 144 $$ 

Nel caso di **assenza** dell'attributo derivato, si prevedono gli accessi seguenti:

```{=latex}

% stato richiesta d'acquisto in assenza dell'attributo

\begin{table}[H]
\caption{\textbf{Visualizzazione dello stato di una richiesta d'acquisto}}
\centering
\begin{tabular}{|l|l|l|l|}
\hline
\textbf{Concetto}    & \textbf{Tipo} & \textbf{Accessi} & \textbf{Tipo di accesso} \\ \hline
Ordine               &    E          &      5           &      R				   \\ \hline
Include              &    R          &      5           &      R				   \\ \hline
\end{tabular}
\end{table}

```

Si osserva che non vi è alcun costo di **aggiornamento** in assenza dell'attributo e che il costo di **visualizzazione** è pari a $$ 60\cdot(5\cdot1 + 5\cdot1) = 600 $$ 

Sulla base dei risultati ottenuti, si ritiene conveniente il **mantenimento** dell'attributo derivato.

#### Data Prevista di Consegna



## Eliminazione delle generalizzazioni

Non ci sono generalizzazioni da eliminare.

## Partizionamento ed accorpamento di entità e associazioni

### Reifica di relazioni binarie

Il diagramma presenta una relazione binaria **Fornisce** che coinvolge le entità **Articolo** e **Fornitore**, che hanno entrambe una partecipazione di tipo `(1, N)`. In particolare, per ogni coppia Articolo-Fornitore si osserva la presenza di una serie di attributi quali prezzo unitario, tempo di consegna, sconto, quantità minima ordinabile e codice articolo per il fornitore. Si sceglie, pertanto, di reificare la relazione ad un'omonima entità contenente gli attributi citati.

### Reifica delle relazioni ternarie

Il diagramma ER presenta una relazione ternaria **Include** che coinvolge le entità **Richiesta d'Acquisto**, **Articolo** e **Ordine**. In particolare, la partecipazione delle entità Richiesta d'Acquisto e Articolo è di tipo `(1, N)`, mentre quella dell'entità Ordine è `(0, N)`: questo perché una richiesta non può essere vuota e un articolo può essere contenuto in una o più richieste, mentre un articolo appartenente ad una richiesta può non essere necessariamente incluso in un ordine. 

Al fine di eliminare la relazione ternaria, si sceglie di reificarla ad entità in relazione con **Richiesta d'Acquisto**, **Articolo** ed **Ordine**, avente come attributi quelli che precedentemente individuato rispetto alla relazione.

### Valutazione degli attributi composti

L'unico attributo composto presente nel diagramma è *Luogo di Nascita* in riferimento all'entità **Responsabile**. In particolare, l'attributo comprende i riferimenti relativi al Comune e alla Provincia di nascita. Vista la scarsità di interrogazioni in merito a dati anagrafici dei responsabili, si sceglie di mantenere l'attributo *Luogo di Nascita* rispetto alla separazione degli attributi *Comune* e *Provincia*. Si prevede, quindi, la presenza di un unico attributo contenente entrambe le informazioni.

### Eliminazione di attributi multivalore

Il diagramma presenta un attributo multivalore *Recapiti Telefonici* in riferimento all'entità **Fornitore**. Questo, infatti, può avere uno o più contatti di riferimento. L'attributo multivalore viene, conseguentemente, reificato ad un'entità.

### Ristrutturazione del diagramma ER

Si riporta il diagramma.

\newpage

## Scelta degli identificatori primari

## Traduzione verso il modello logico-relazionale

\newpage

# Implementazione e Progettazione Fisica

\newpage

# Analisi dei dati








































