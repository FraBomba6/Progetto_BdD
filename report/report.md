---
title: "Relazione Progetto Basi di Dati - A.A. 2020-2021"
author: |
        | Francesco Bombassei De Bona (144665)
        | Andrea Cantarutti (141808)
        | Lorenzo Bellina (142544)
		| Alessandro Fabris (matricola)
date: "01/05/2021"
output:
header-includes:
  - \usepackage{amsmath}
  - \usepackage[margin=0.8in]{geometry}
  - \usepackage[utf8]{inputenc}
  - \usepackage[italian]{babel}
  - \usepackage{graphicx}
  - \usepackage{xcolor}
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

Sulla base di quanto riportato, si procede alla formulazione di un glossario che permette la definizione univoca dei concetti esposti. 

\newpage

## Glossario

La terminologia individuata appartente al dominio di interesse e correlata alla strutturazione della Base di Dati è presentata di seguito: 

```{=latex}
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

## Inviduazione dei principali requisiti operazionali

Sulla base dei requisiti individuati, si descrivono le principali operazioni, con rispettiva frequenza, sui dati. Si considera, per dare consistenza al conteggio, un ente costituito da trenta dipartimenti e associato ad cinque fornitori diversi. 

\
\

| **Operazione** | **Frequenza** |
|-|-|
|Inserimento di una richiesta d'acquisto|150/settimana|
|||
|Aggiornamento dello stato di una richiesta d'acquisto|7/settimana|
|||
|Visualizzazione delle richieste d'acquisto|60/settimana|
|||
|Inserimento di un nuovo ordine|5/settimana|
|||
|Aggiornamento di un ordine|5/settimana|
|||
|Modifica delle caratteristiche di un prodotto|5/mese|
|||
|Visualizzazione di tutti gli articoli|500/settimana|
|||
|Calcolo numero richieste mensili effettuate dai dipartimenti|30/mese|
|||
|Calcolo della spesa mensile dei dipartimenti e dell'ente|30/mese|

\newpage

## Criteri per la rappresentazione dei concetti

Sulla base del documento di specifiche, si inviduano i criteri opportuni per la rappresentazione dei concetti descritti.

```{=latex}
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
		\textbf{Legenda}: & \textbf{\textcolor{red}{Entità}} & \textbf{\textcolor{darkgreen}{Attributo}} & \textbf{\textcolor{brown}{Ambiguità}} & \textbf{\textcolor{bllightblueue}{Relazioni}} & \textbf{\textcolor{lightblue}{Attributi di relazione}} \\ 
		\end{tabular}
		\end{table}
	}%
}
```
### Assunzioni in merito alle ambiguità rilevate

Sulla base di quanto riportato nelle specifiche sopracitate, si è osservato come il concetto di **listino** delinei l'insieme di articoli associati al rispettivo fornitore senza, però, aggiungere informazioni supplementari in merito a tale relazione. Si è, pertanto, deciso di **non** rappresentare il listino all'interno della Basi di Dati ma di, piuttosto, rappresentare l'associazione fra un singolo prodotto e il rispettivo fornitore. 

Inoltre, si è osservata una fondamentale distinzione tra il concetto di **articolo** e quello di **articolo appartenente ad un dato listino**. In particolare, mentre l'articolo individua informazioni immutabili in merito ad un singolo bene acquistabile, il prodotto di un listino specifica aspetti quali prezzo, sconto e quantità minima ordinabile che variano a seconda del rispettivo fornitore. Si assume che un singolo prodotto possa provenire da diversi fornitori e che una richiesta d'acquisto relativa ad uno specifico articolo possa essere evasa con prodotti analoghi, ma provenienti da fornitori diversi. Costituisce responsabilità dell'ufficio acquisti l'individuazione del prodotto, con rispettivo fornitore, più conveniente sulla base degli articoli inclusi in una richiesta d'acquisto.  

Ne consegue che, a livello di dipartimento, quello che viene individuato come singolo articolo possa essere ricondotto dal personale dell'ufficio acquisti al rispettivo prodotto di uno fra diversi fornitori, sulla base di aspetti logistici e/o di convenienza.

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

### Vincoli aziendali

Il diagramma presenta un singolo ciclo che coinvolge le entità *Ordine*, *Prodotto Listino* e *Fornitore*. Sulla base di quanto riportato nei requisiti si introduce il seguente vincolo aziendale: **il fornitore dei prodotti relativi ad un ordine deve essere il medesimo di quello associato all'ordine stesso**. 

### Regole di derivazione

Gli attributi derivati, con rispettive regole di derivazione, sono riportati di seguito: 


### Considerazioni

So lillo


\newpage

# Progettazione logica

\newpage

# Implementazione e Progettazione Fisica

\newpage

# Analisi dei dati

