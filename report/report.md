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
Richiesta d'acquisto & Documento riportante i dati relativi alle necessità d'acquisto & Richiesta & Dipartimento, Articolo             \\ \hline
Articolo & Elemento atomico soggetto ad una o più richieste d'acquisto &   & Richiesta d'acquisto, Listino, Ordine 
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
\renewcommand{\arraystretch}{1.2}
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

\newpage

# Progettazione concettuale

\newpage

# Progettazione logica

\newpage

# Implementazione e Progettazione Fisica

\newpage

# Analisi dei dati in R

