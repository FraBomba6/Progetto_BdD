# Bozza di modello logico per riferimenti

## ORDINE

| Codice ordine | Data | Cazzi | Mazzi | Eccetera |
|---------------|------|-------|-------|----------|
| 39482349832   |  28  |   x   |  y    |   z      |
| 39482234222   |  28  |   x   |  y    |   z      |
| 39423425252   |  28  |   x   |  y    |   z      |


## PRODOTTO

| CodiceArticolo  | Fornitore | Prezzo | Sconto | QuantMin | CodiceProdPerFornitore | 
|-----------------|-----------|--------|--------|----------|------------------------|
|  A82P4          | Gigi      | 32 	   |  13    |  5       |  KP9                   |
|  A12P9		  | Marco 	  | 50	   |  NULL  |  1       |  K614				    |
|  A12P9		  | Gianni 	  | 48	   |  NULL  |  5       |  H678					|

- Codice articolo è FK a tabella articolo
- La PK sarebbe CodiceArticolo + Fornitore


## RICHIESTA

| Codice | Data | Altro |
|--------|------|-------|
|   1 	 | 27   |   X   |
|   2 	 | 14   |   Y   |

## ARTICOLO

| Codice | Info |
|--------|------|
| A82P4  | info1|
| A12P9  | info2|

\newpage 

## RICHIESTA->ARTICOLO

| CodiceRichiesta | CodiceArticolo| DataConsegnaPrevista |  
|-----------------|---------------|----------------------|
|         1       |    A82P4      |   17/03				 |
|         1       |    A12P9      |   19/04				 |


## ORDINE->PRODOTTO

| CodiceOrdine    | CodiceProdotto | 
|-----------------|----------------|
|  39423425252    |    KP9         |
|  39423425252    |    K678        |


## ORDINE->RICHIESTA

| CodiceOrdine | CodiceRichiesta |
|--------------|-----------------|
| 39423425252  |  2				 |
| 39482234222  |  1              |

