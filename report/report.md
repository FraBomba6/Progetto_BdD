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
  - \usepackage{datatool}
  - \usepackage{booktabs}
  - \usepackage{array}
  - \usepackage{multirow} 
  - \usepackage{bigstrut}
  - \hypersetup{colorlinks=true,
            linkcolor=black,
            urlcolor=blue,
            allbordercolors={0 0 0},
            pdfborderstyle={/S/U/W 1}}
  - \usepackage{caption}
---

\captionsetup{labelformat=empty}
\pagenumbering{arabic}
\newpage
\tableofcontents
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
|:-|-|
|Inserimento di una richiesta d'acquisto|60/settimana|
|||
|Aggiornamento dello stato di un ordine|10/settimana|
|||
|Visualizzazione delle informazioni relative ad una richiesta d'acquisto|120/settimana|
|||
|Visualizzazione degli articoli contenuti in una richiesta d'acquisto|180/settimana|
|||
|Inserimento di un nuovo ordine|5/settimana|
|||
|Visualizzazione di tutti gli articoli|200/settimana|
|||
|Calcolo della spesa mensile dei dipartimenti|30/mese|
|||
|Calcolo della spesa complessiva dell'ente in un intervallo di tempo|5/mese|


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

### Assunzioni in merito alle ambiguità rilevate {#assunzioni}

- Sulla base di quanto riportato nelle specifiche sopracitate, si è osservato come il concetto di **listino** delinei l'insieme di articoli associati al rispettivo fornitore senza, però, aggiungere informazioni supplementari in merito a tale relazione. Si è, pertanto, deciso di **non** rappresentare il listino all'interno della Basi di Dati ma di, piuttosto, rappresentare l'associazione fra un singolo articolo e il rispettivo fornitore. 
- Si assume che un articolo possa essere fornito da un insieme di fornitori e che, di conseguenza, mentre una richiesta d'acquisto si rivolge agli articoli, è responsabilità dell'ufficio acquisti l'individuazione dello specifico fornitore, in merito ad aspetti logistici e di convenienza.
- Si assume che sia di interesse dell'ente la possibilità di ricondurre un ordine alle richieste d'acquisto che esso soddisfa e una richiesta d'acquisto agli ordini che la coinvolgono.
- Si osserva, inoltre, la necessità di memorizzare il prezzo al quale ogni singolo articolo viene acquistato nell'eventualità che vengano successivamente variati lo sconto e/o il prezzo unitario.
- Infine, sapendo che un ordine coinvolge al più un fornitore e che gli articoli inclusi nelle richieste d'acquisto possono potenzialmente provenire da fornitori diversi si assume che:
	- Un singolo ordine possa soddisfare una richiesta d'acquisto anche parzialmente;
	- Per ogni articolo coinvolto, venga soddisfatta la quantità specificata. 

\newpage

# Progettazione concettuale

## Diagramma ER {#er-v1}

\begin{figure}[H]
\centering
\includegraphics[width=510px]{../ER.png}
\end{figure}

\newpage

## Osservazioni

Sulla base del diagramma ER proposto, si riportano le osservazioni effettuate, includendo i **vincoli aziendali** individuati e le eventuali **regole di derivazione**.

### Vincoli aziendali {#vincoli}

Il diagramma presenta un singolo ciclo che coinvolge le entità *Ordine*, *Articolo* e *Fornitore*. Sulla base di quanto riportato nei requisiti si introduce il seguente vincolo aziendale: \emph{\textbf{il fornitore degli articoli relativi ad un ordine deve essere il medesimo di quello associato all'ordine stesso}}. 

Inoltre, si evidenzia come sia la **data di consegna di un articolo** che il **prezzo di acquisto di un articolo** relativamente ad una richiesta, possano essere disponibili solo in seguito alla partecipazione di un ordine alla relazione. 

### Regole di derivazione

Il diagramma presenta due attributi derivati, ovvero **Data di Consegna** e **Numero Articoli**. Il primo è relativo alla relazione Include e viene derivato sulla base della data di consegna relativa all'ordine che soddisfa ciascun articolo. Il secondo, invece, è relativo all'entità Richiesta d'Acquisto e viene calcolato contando gli articoli associati ad una richiesta (considerandone la rispettiva quantità ordinata).

### Considerazioni

```{=latex}
% La relazione **Include** prevede l'aggiunta dell'attributo **Prezzo Unitario Finale** al fine di poter stabilire, come indicato al punto [2.5.1](#assunzioni), il prezzo al quale l'articolo viene acquistato.
```
Si osserva come la partecipazione dell'entità *Ordine* alla relazione ternaria che coinvolge le entità *Richiesta d'Acquisto*, *Ordine* e *Articolo* sia **opzionale**. Quest'ultima avverrà, infatti, solamente all'atto di emissione (da parte dell'ufficio acquisti) di un ordine che soddisfa l'articolo incluso in una specifica richiesta. 

\newpage

# Progettazione logica

## Analisi delle ridondanze

### Analisi dei cicli

Come specificato precedentemente, l'unico ciclo presente nello schema ER coinvolge le entità **Ordine**, **Articolo** e **Fornitore**. Un ordine, infatti, deve essere rivolto ad uno specifico fornitore e, pertanto, gli articoli contenuti devono necessariamente provenire tutti dallo stesso fornitore.

Considerato il fatto che il medesimo articolo possa essere fornito da più fornitori, al fine di poter strutturare un ordine è necessario sapere il fornitore che lo evaderà e gli articoli in esso contenuti. Non è, pertanto, possibile effettuare un'eliminazione del ciclo senza la conseguente perdita di informazione necessaria al corretto comportamento della Base di Dati. Pertanto, il ciclo viene mantenuto e vincolato sulla base delle osservazioni effettuate al punto [3.2](#vincoli).

### Attributi derivabili {#volumi}

Al fine di valutare il mantenimento o l'eliminazione delle ridondanze presenti nel diagramma ER proposto, si definisce, di seguito, la tavola dei volumi di entità e relazioni presenti nella Base di Dati. Si considera quanto segue:

- La stato della base di dati dopo un anno di attività;
- Richieste d'acquisto che coinvolgono mediamente 5 articoli e soddisfatte da 3 ordini;
- Ordini che contengono, in media, 60 articoli;
- Ordini che soddisfano mediamente 12 richieste d'acquisto.

|**Concetto**|**Tipo**|**Volume**|
|-|:-:|-:|
|Responsabile|E|25|
|Dipartimento|R|30|
|Richiesta d'Acquisto|E|2400|
|Articolo|E|300|
|Ordine|E|200|
|Fornitore|E|5|
|Include|R|12000|
|Fornisce|R|450|

Si fa riferimento, inoltre, alle operazioni frequenti riportate al punto [2.4](#op-frequenti).

Si effettua, quindi, un'analisi delle ridondanze in merito agli attributi derivati **Data di Consegna** della relazione **Include** e **Numero Articoli** dell'entità **Richiesta d'Acquisto**. 

Il primo, è coinvolto nelle operazioni di:

- Visualizzazione degli articoli contenuti in una richiesta d'acquisto [`180/settimana`]
- Aggiornamento dello stato di un ordine [`10/settimana`]

Il secondo, invece, è coinvolto nelle operazioni di:

- Visualizzazione delle informazioni relative ad una Richiesta d'Acquisto [`120/settimana`];
- Inserimento di una Richiesta d'Acquisto [`60/settimana`].


\newpage

### Data di Consegna 

Per ogni operazione, si prevedono gli accessi seguenti:

```{=latex}

% data di consegna

\begin{table}[H]
\centering
\caption {\textbf{Visualizzazione degli articoli di una Richiesta d'Acquisto}}
\begin{tabular}{|p{0.20\textwidth}|l|l|l|l|l|}
\cline{3-6}
\multicolumn{2}{l|}{} & \multicolumn{2}{|l|}{\textbf{Presenza di attributo derivato}}  & \multicolumn{2}{|l|}{\textbf{Assenza di attributo derivato}}   \\ \cline{1-6}
\textit{Concetto} & \textit{Tipo} & \textit{Accessi} & \textit{Tipo di accesso} & \textit{Accessi} & \textit{Tipo di accesso}        \\ \cline{1-6}
Richiesta d'Acquisto &  E         &         1        &             R            &        1         &          R                      \\ \cline{1-6}
Include           &     R         &         5        &             R            &        5         &          R                      \\ \cline{1-6}
Ordine            &     E         &         -        &             -            &        5         &          R                      \\ \cline{1-6}
\end{tabular}
\end{table}

\begin{table}[H]
\centering
\caption {\textbf{Aggiornamento dello stato di un ordine}}
\begin{tabular}{|p{0.20\textwidth}|l|l|l|l|l|}
\cline{3-6}
\multicolumn{2}{l|}{} & \multicolumn{2}{|l|}{\textbf{Presenza di attributo derivato}}  & \multicolumn{2}{|l|}{\textbf{Assenza di attributo derivato}}   \\ \cline{1-6}
\textit{Concetto} & \textit{Tipo} & \textit{Accessi} & \textit{Tipo di accesso} & \textit{Accessi} & \textit{Tipo di accesso}        \\ \cline{1-6}
Ordine            &     E         &         1        &             W            &        1         &          W                      \\ \cline{1-6}
Include           &     R         &         60       &             W            &        -         &          -                      \\ \cline{1-6}
\end{tabular}
\end{table}


```

Considerando la tavola dei volumi riportata precedentemente, si osserva quanto segue: 

- L'operazione di *Visualizzazione degli articoli di una Richiesta d'Acquisto* considera:
	+ 0 scritture e 6 letture in caso di presenza dell'attributo derivato
	+ 0 scritture e 11 letture in caso di assenza dell'attributo derivato

|

- L'operazione di *Aggiornamento dello stato di un Ordine* considera: 
	+ 61 scritture e 0 letture in caso di presenza dell'attributo derivato
	+ 1 scrittura e 0 letture in caso di assenza dell'attributo derivato

Applicando alle scritture un peso doppio rispetto a quello delle letture e considerando la frequenza delle operazioni sopracitate si osservano i costi di seguito descritti:

Nel caso di **presenza** dell'attributo derivato: 

$180 \cdot (0 \cdot 2 + 6 \cdot 1) \; + \; 10 \cdot (61 \cdot 2 + 0 \cdot 1) = 1080 + 1220 = 2300$

|

Nel caso di **assenza** dell'attributo derivato: 

$180 \cdot (0 \cdot 2 + 11 \cdot 1) \; + \; 10 \cdot (1 \cdot 2 + 0 \cdot 1) = 1980 + 20 = 2000$

Sulla base dei risultati ottenuti si sceglie, quindi, di non mantenere l'attributo derivato.

\newpage

### Numero Articoli

Per ogni operazione, si prevedono gli accessi seguenti:

```{=latex}

% numero articoli

\begin{table}[H]
\centering
\caption {\textbf{Visualizzazione delle informazioni relative ad una Richiesta d'Acquisto}}
\begin{tabular}{|p{0.20\textwidth}|l|l|l|l|l|}
\cline{3-6}
\multicolumn{2}{l|}{} & \multicolumn{2}{|l|}{\textbf{Presenza di attributo derivato}}  & \multicolumn{2}{|l|}{\textbf{Assenza di attributo derivato}}   \\ \cline{1-6}
\textit{Concetto} & \textit{Tipo} & \textit{Accessi} & \textit{Tipo di accesso} & \textit{Accessi} & \textit{Tipo di accesso}      \\ \cline{1-6}
Richiesta d'Acquisto &     E      &        1         &             R            &        1         &          R                    \\ \cline{1-6}
Include              &     R      &        -         &             -            &        5         &          R                    \\ \cline{1-6}
\end{tabular}
\end{table}


\begin{table}[H]
\centering
\caption {\textbf{Inserimento di una Richiesta d'Acquisto}}
\begin{tabular}{|p{0.20\textwidth}|l|l|l|l|l|}
\cline{3-6}
\multicolumn{2}{l|}{} & \multicolumn{2}{|l|}{\textbf{Presenza di attributo derivato}}  & \multicolumn{2}{|l|}{\textbf{Assenza di attributo derivato}}   \\ \cline{1-6}
\textit{Concetto} & \textit{Tipo} & \textit{Accessi} & \textit{Tipo di accesso} & \textit{Accessi} & \textit{Tipo di accesso}      \\ \cline{1-6}
Richiesta d'Acquisto &     E      &        1         &             R            &        1         &          R                    \\ \cline{1-6}
Richiesta d'Acquisto &     E      &        2         &             W            &        1         &          W                    \\ \cline{1-6}
Include              &     R      &        5         &             R            &        -         &          -                    \\ \cline{1-6}
Include              &     R      &        5         &             W            &        5         &          W                    \\ \cline{1-6}
\end{tabular}
\end{table}
```

Considerando la tavola dei volumi riportata precedentemente, si osserva quanto segue: 

- L'operazione di *Visualizzazione delle informazioni relative ad una Richiesta d'Acquisto* considera:
	+ 0 scritture ed 1 lettura in caso di presenza dell'attributo derivato
	+ 0 scritture e 6 letture in caso di assenza dell'attributo derivato 

|

- L'operazione di *Inserimento di una Richiesta d'Acquisto* considera: 
	+ 7 scritture e 6 letture in caso di presenza dell'attributo derivato
	+ 6 scritture e 1 lettura in caso di assenza dell'attributo derivato

|

Applicando alle scritture un peso doppio rispetto a quello delle letture e considerando la frequenza delle operazioni sopracitate si osservano i costi di seguito descritti:

Nel caso di **presenza** dell'attributo derivato: 

$120 \cdot (0 \cdot 2 + 1 \cdot 1) \; + \; 60 \cdot (7 \cdot 2 + 6 \cdot 1) = 120 + 1200  = 1320$

|

Nel caso di **assenza** dell'attributo derivato: 

$120 \cdot (0 \cdot 2 + 6 \cdot 1) \; + \; 60 \cdot (6 \cdot 2 + 1 \cdot 1)  = 720 + 780 = 1500$

Sulla base dei risultati ottenuti si sceglie, quindi, di mantenere l'attributo derivato, procedendone alla reifica ad attributo nell'entità *Richiesta d'Acquisto*.

\newpage

## Eliminazione delle generalizzazioni

Non essendovi relazioni di generalizzazione nel diagramma concettuale proposto al punto [3.1](#er-v1), non è stato necessario apportare modifiche rivolte all'eliminazione di eventuali relazioni di generalizzazione.

## Partizionamento ed accorpamento di entità e associazioni

### Reifica di relazioni binarie

Il diagramma presenta una relazione binaria **Fornisce** che coinvolge le entità **Articolo** e **Fornitore**, che hanno entrambe una partecipazione di tipo `(1, N)`. In particolare, per ogni coppia Articolo-Fornitore si osserva la presenza di una serie di attributi quali prezzo unitario, sconto, quantità minima ordinabile e codice articolo per il fornitore. Si sceglie, pertanto, di reificare la relazione ad un'omonima entità contenente gli attributi citati.

### Reifica delle relazioni ternarie

Il diagramma ER presenta una relazione ternaria **Include** che coinvolge le entità **Richiesta d'Acquisto**, **Articolo** e **Ordine**. In particolare, la partecipazione delle entità Richiesta d'Acquisto e Articolo è di tipo `(1, N)`, mentre quella dell'entità Ordine è `(0, N)`: questo perché una richiesta non può essere vuota e un articolo può essere contenuto in una o più richieste, mentre un articolo appartenente ad una richiesta può non essere necessariamente incluso in un ordine. 

Al fine di eliminare la relazione ternaria, si sceglie di reificarla ad entità in relazione con **Richiesta d'Acquisto**, **Articolo** ed **Ordine**, avente come attributi quelli precedentemente individuati rispetto alla relazione.

### Valutazione degli attributi composti

L'unico attributo composto presente nel diagramma è *Luogo di Nascita* in riferimento all'entità **Responsabile**. In particolare, l'attributo comprende i riferimenti relativi al Comune e alla Provincia di nascita. Vista la scarsità di interrogazioni in merito a dati anagrafici dei responsabili, si sceglie di mantenere l'attributo *Luogo di Nascita* rispetto alla separazione degli attributi *Comune* e *Provincia*. Si prevede, quindi, la presenza di un unico attributo contenente entrambe le informazioni.

### Eliminazione di attributi multivalore

Il diagramma presenta un attributo multivalore *Recapiti Telefonici* in riferimento all'entità **Fornitore**. Questo, infatti, può avere uno o più contatti di riferimento. L'attributo multivalore viene, conseguentemente, reificato ad entità.

\newpage

### Ristrutturazione del diagramma ER

Sulla base delle analisi e osservazioni effettuate, si provvede alla ristrutturazione del diagramma proposto al punto [3.1](#er-v1). Ne consegue, la seguente rappresentazione: 

\begin{figure}[H]
\centering
\includegraphics[width=510px]{../ER_final.png}
\end{figure}

\newpage

## Scelta degli identificatori primari

Non essendovi entità che presentano più identificatori primari candidati, non si attuano decisioni aggiuntive e si sceglie di utilizzare le chiavi proposte dal diagramma.

## Traduzione verso il modello logico-relazionale

Partendo dal diagramma ER ristrutturato, è stato prodotto il corrispondente schema relazionale, le cui traduzioni vengono di seguito suddivise in quattro categorie: 

- Entità
- Relazioni molti a molti
- Relazioni uno a molti
- Relazioni uno a uno

| \textbf{Concetto} | \textbf{Cardinalità} |\textbf{Nome} |
|------------------------|:--------------------:|--------------|
|Entità| - |Responsabile|
|Entità| - |Dipartimento|
|Entità| - |Richiesta d'Acquisto|
|Entità| - |Include|
|Entità| - |Articolo|
|Entità| - |Ordine|
|Entità| - |Fornisce|
|Entità| - |Fornitore|
|Entità| - |Recapito Telefonico|
|Relazione|Uno a molti|Gestisce|
|Relazione|Uno a molti|Formula|
|Relazione|Uno a molti|I-R|
|Relazione|Uno a molti|I-A|
|Relazione|Uno a molti|I-O|
|Relazione|Uno a molti|A-F|
|Relazione|Uno a molti|F-F|
|Relazione|Uno a molti|Evade|
|Relazione|Uno a molti|R|

### Traduzione di Entità

```{=latex}

\begin{itemize}
	\item \textbf{Responsabile}(\underline{CodiceFiscale}, Nome, Cognome, DataNascita, LuogoNascita)
		\begin{itemize}
			\item NotNull: Nome, Cognome, DataNascita, LuogoNascita
		\end{itemize}
	\item \textbf{Dipartimento}(\underline{Codice}, Descrizione)
	\item \textbf{RichiestaAcquisto}(\underline{Numero, \emph{Dipartimento}}, DataEmissione, NumeroArticoli)
		\begin{itemize}
			\item NotNull: DataEmissione, Dipartimento, NumeroArticoli
			\item Chiave Esterna: Dipartimento si riferisce alla chiave primaria dell'entità Dipartimento 
		\end{itemize}
	\item \textbf{Include}(\underline{\emph{NumeroRichiesta, Articolo, Dipartimento}}, Quantità, PrezzoUnitario)
		\begin{itemize}
			\item NotNull: Quantità, PrezzoUnitario, NumeroRichiesta, Dipartimento, Articolo 
			\item Chiave Esterna: NumeroRichiesta e Dipartimento si riferiscono alla chiave primaria dell'entità RichiestaAcquisto, Articolo si riferisce alla chiave primaria dell'entità Articolo
		\end{itemize}
	\item \textbf{Articolo}(\underline{Codice}, Descrizione, Classe, UnitàDiMisura)
		\begin{itemize}
			\item NotNull: Descrizione, Classe, UnitàDiMisura
		\end{itemize}
	\item \textbf{Ordine}(\underline{Codice}, Stato, DataEmissione, DataConsegna)
		\begin{itemize}
			\item NotNull: Stato, DataEmissione
		\end{itemize}
	\item \textbf{Fornisce}(\underline{\emph{Fornitore, Articolo}}, Sconto, PrezzoUnitario, QuantitàMinima, CodBar)
		\begin{itemize}
			\item NotNull: PrezzoUnitario, QuantitàMinima, CodBar, Fornitore, Articolo
			\item Chiave Esterna: Fornitore si riferisce alla chiave primaria dell'entità Fornitore, Articolo si riferisce alla chiave primaria dell'entità Articolo
		\end{itemize}
	\item \textbf{Fornitore}(\underline{PartitaIVA}, Indirizzo, Email, FAX)
		\begin{itemize}
			\item NotNull: Indirizzo, Email 
		\end{itemize}
	\item \textbf{RecapitoTelefonico}(\underline{NumeroTelefono})
\end{itemize}

```


### Traduzione di Relazioni Uno a molti

*I vincoli espressi di seguito costituiscono un'integrazione rispetto a quelli introdotti precedentemente.*

```{=latex}
\begin{itemize}
	\item \textbf{Gestisce}
	\begin{itemize}
		\item Modifica: Dipartimento(\underline{Codice}, Descrizione, \emph{Responsabile})
		\item NotNull: Responsabile 
		\item Chiave Esterna: Responsabile si riferisce alla chiave primaria dell'entità Responsabile
	\end{itemize}
	\item \textbf{Formula}
		\begin{itemize}
			\item Codificata precedentemente in quanto Richiesta d'Acquisto è un'entità debole
		\end{itemize}
	\item \textbf{I-R} e \textbf{I-A}
		\begin{itemize}
			\item Codificate precedentemente in quanto Include è un'entità debole) 
		\end{itemize}
	\item \textbf{I-O}
		\begin{itemize}
			\item Modifica: Include(\underline{\emph{NumeroRichiesta, Articolo, Dipartimento}}, \emph{Ordine}, Quantità, PrezzoUnitario)
			\item NotNull: Non vengono introdotti vincoli aggiuntivi rispetto a quelli già individuati 
			\item Chiave Esterna: Ordine si riferisce alla chiave primaria dell'entità Ordine
		\end{itemize}
	\item \textbf{A-F} e \textbf{F-F}
		\begin{itemize}
			\item Codificate precedentemente in quanto Fornisce è un'entità debole) 
		\end{itemize}
	\item \textbf{Evade}
		\begin{itemize}
			\item Modifica: Ordine(\underline{Codice}, Stato, DataEmissione, DataConsegna, \emph{Fornitore})
			\item NotNull: Fornitore
			\item Chiave Esterna: Fornitore si riferisce alla chiave primaria dell'entità Fornitore
		\end{itemize}
	\item \textbf{R}
		\begin{itemize}
			\item Modifica: RecapitoTelefonico(\underline{NumeroTelefono}, \emph{Fornitore})
			\item NotNull: Fornitore
			\item Chiave Esterna: Fornitore si riferisce alla chiave primaria dell'entità Fornitore
		\end{itemize}
\end{itemize}
```

### Traduzione di relazioni molti a molti e uno a uno

Il diagramma ER non presenta relazioni di tipo *molti a molti* e di tipo *uno a uno*. Di conseguenza non vi è necessità di codificare relazioni di questo tipo. 

### Osservazioni

Si osserva come non sia possibile garantire il rispetto del Vincolo di Integrità espresso al punto [3.2.1](#vincoli). Sarà, di conseguenza, necessario individuare appositi strumenti al fine di garantirne il mantenimento.

\newpage

## Modello Relazionale

\

\begin{figure}[H]
\centering
\includegraphics[width=510px]{../Logical.png}
\end{figure}

\newpage

# Progettazione Fisica

## Osservazioni sugli indici

Al fine di introdurre un miglioramento delle prestazioni, si valuta l'inserimento di ulteriori indici confrontando la variazione delle prestazione sia in operazioni di **ricerca** che in operazioni di **modifica**. L'indicizzazione permette, infatti, un tempo di lookup inferiore durante query di selezione ma può causare l'aumento dei tempi di esecuzione delle query di modifica e inserimento sulla stessa tabella. Si rende, pertanto, necessario un confronto atto a stabilire le variazioni che i tempi di esecuzione subiscono in entrambi i casi. 

A tal fine, è stato utilizzato il comando `EXPLAIN ANALYZE [statement]`, che permette di ottenere informazioni sull'**execution plan** e sui tempi di esecuzione richiesti da una query. È stato, inoltre, impostato ad `OFF` l'attributo `enable seqscan` al fine di discoraggiare il query planner all'utilizzo di scan sequenziali che invaliderebbero i confronti fra operazioni su tabelle in assenza e presenza di indici. 

Si tiene, inoltre, presente il fatto che ogni tabella viene automaticamente indicizzata dal DBMS sulla sua chiave primaria.

Gli indici presi in considerazione sono i seguenti: 

- Indicizzazione sugli attributi **Dipartimento** e **NumeroRichiesta** dell'entità *Include*
- Indicizzazione sull'attributo **Ordine** dell'entità *Include*
- Indicizzazione sull'attributo **DataRichiesta** dell'entità *RichiestaAcquisto*

Nel primo caso, è stato osservato come l'indicizzazione di chiavi primarie composite in PostgreSQL avvenga anche su sottoinsiemi della stessa. Pertanto, considerata l'appartenenza di Dipartimento e NumeroRichiesta alla chiave primaria di RichiestaAcquisto, non risulterebbe conveniente l'aggiunta di un ulteriore indice sui due soli attributi. Il DBMS sfrutterebbe, in ogni caso, l'indicizzazione della chiave primaria. Si sceglie, pertanto, di non implementare tale indice all'interno della base di dati.

Nel secondo e terzo caso, invece, si sceglie di procedere al confronto in presenza e assenza degli indici. L'indicizzazione dell'entità *Include* sull'attributo **Ordine** permetterebbe, infatti, una più efficiente ricerca degli articoli contenuti in un determinato Ordine, mentre quella dell'entità *RichiestaAcquisto* sull'attributo **DataEmissione** permetterebbe una più veloce ricerca delle Richieste d'Acquisto effettuate in un determinato intervallo di tempo, utile durante la computazione di statistiche e metriche mensili, semestrali e annualli da parte dell'ente pubblico.

I test sono stati condotti sui dati di Mockup (la cui produzione viene descritta al punto [x.y](#mockup-data)), realizzati nel rispetto dei volumi descritti al punto [4.1.2](#volumi) al fine di poter condurre operazioni di test e di analisi sulla base di dati.

### Indicizzazione di Include su Ordine in operazioni di ricerca

```{=latex}

\DTLloaddb{ordine_select}{../R/csv/Indice_Include.Ordine_Select.csv}

\begin{table}[H]
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Assenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{senza}{\Tipo}]{ordine_select}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage} \hfill
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Presenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{con}{\Tipo}]{ordine_select}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage}
\end{table}
```

### Indicizzazione di Include su Ordine in operazioni di inserimento 

```{=latex}

\DTLloaddb{ordine_update}{../R/csv/Indice_Include.Ordine_Update.csv}

\begin{table}[H]
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Assenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{senza}{\Tipo}]{ordine_update}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage} \hfill
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Presenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{con}{\Tipo}]{ordine_update}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage}
\end{table}
```

#### Osservazioni 

Sulla base dei dati ottenuti sono stati prodotti i seguenti grafici:

```{=latex}
\begin{figure}[H]
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_Include.Ordine_Select_Planning.png}
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_Include.Ordine_Select_Execution.png}
\caption{Variazione di Planning ed Execution time per operazioni di selezione}
\end{figure}
```

```{=latex}
\begin{figure}[H]
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_Include.Ordine_Update_Planning.png}
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_Include.Ordine_Update_Execution.png}
\caption{Variazione di Planning ed Execution time per operazioni di modifica}
\end{figure}
```

\newpage

Le query di selezione e modifica utilizzate sono le seguenti:

```sql
-- Selezione 
EXPLAIN ANALYSE 
	SELECT * 
	FROM Include 
	WHERE Ordine=5;

-- Modifica
EXPLAIN ANALYSE 
	UPDATE Include 
	SET Ordine=NULL 
	WHERE 
		Dipartimento='WLIQJC' AND 
		NumeroRichiesta=79 AND 
		Articolo=102;
```

Si osserva quanto segue:

- Nel caso di **query di selezione** i tempi di esecuzione migliorano notevolmente in presenza di un indice
- Nel caso di **query di modifica** la presenza dell'indice non causa notevoli variazioni nei tempi di esecuzione

Si sceglie, pertanto, di **mantenere l'indice** all'interno della base di dati.

### Indicizzazione di DataEmissione su RichiestaAcquisto in operazioni di ricerca

```{=latex}

\DTLloaddb{richiesta_select}{../R/csv/Indice_RichiestaAcquisto.DataEmissione_Select.csv}

\begin{table}[H]
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Assenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{senza}{\Tipo}]{richiesta_select}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage} \hfill
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Presenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{con}{\Tipo}]{richiesta_select}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage}
\end{table}
```

### Indicizzazione di DataEmissione su RichiestaAcquisto in operazioni di modifica

```{=latex}

\DTLloaddb{richiesta_update}{../R/csv/Indice_RichiestaAcquisto.DataEmissione_Update.csv}

\begin{table}[H]
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Assenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{senza}{\Tipo}]{richiesta_update}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage} \hfill
\begin{minipage}{0.5\textwidth}
\centering
\caption{\textbf{Presenza dell'Indice}}
\begin{tabular}{ccc}
\toprule
\textbf{Planning} & \textbf{Execution} \\
\midrule
\DTLforeach*[\equal{con}{\Tipo}]{richiesta_update}
{\Planning=Planning,\Execution=Execution,\Tipo=Tipo}
{\\ \Planning & \Execution}
% \vdots & \vdots & \vdots  \\ 
% \bottomrule
\end{tabular}

\end{minipage}
\end{table}
```

#### Osservazioni

Sulla base dei dati ottenuti sono stati prodotti i seguenti grafici:

```{=latex}
\begin{figure}[H]
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_RichiestaAcquisto.DataEmissione_Select_Planning.png}
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_RichiestaAcquisto.DataEmissione_Select_Execution.png}
\caption{Variazione di Planning ed Execution time per operazioni di selezione}
\end{figure}
```

```{=latex}
\begin{figure}[H]
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_RichiestaAcquisto.DataEmissione_Update_Planning.png}
\includegraphics[width=0.5\textwidth, height=280px]{../R/plots/Indice_RichiestaAcquisto.DataEmissione_Update_Execution.png}
\caption{Variazione di Planning ed Execution time per operazioni di modifica}
\end{figure}
```

\newpage

Le query di selezione e modifica utilizzate sono le seguenti:

```sql
-- Selezione 
EXPLAIN ANALYSE 
	SELECT * 
	FROM RichiestaAcquisto 
	WHERE DataEmissione BETWEEN '2020-10-01' AND '2020-11-01'

-- Modifica
EXPLAIN ANALYSE 
	INSERT INTO RichiestaAcquisto(Dipartimento) 
	VALUES ('ZXTSNW')
```

Si osserva quanto segue:

- Nel caso di **query di selezione** i tempi di esecuzione subiscono un notevole miglioramento in presenza dell'indice 
- Nel caso di **query di modifica** i tempi di esecuzione non subiscono variazioni significative, ma se si osserva una maggiore variabilità nel caso di assenza dell'indice.

Sulla base dei risultati ottenuti si sceglie, quindi, il **mantenimento dell'indice**.

\newpage

# Implementazione 

## Containerizzazione del DBMS

## Implementazione della Base di Dati

## Produzione e Inserimento dei dati di Mockup

## Osservazioni

# Analisi dei dati

\newpage

# Conclusioni







