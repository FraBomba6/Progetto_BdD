-- Visualizzazione di tutti gli articoli

select * from Articolo;

-- Visualizzazione di tutti gli articoli di cancelleria 

select * from Articolo where Classe='cancelleria';

-- Visualizzazione di tutti gli articoli la cui descrizione contiene la parola "penna"

select * from Articolo where Descrizione LIKE '%penna%';

-- Visualizzazione di tutti gli articoli di classe "informatica" 
-- la cui descrizione contiene la parola "stampante" 
-- La cui unità di misura è "cad"

select * 
	from Articolo 
	where Descrizione LIKE '%stampante%' and
	Classe='informatica' and
	UnitaDiMisura='cad';

-- Visualizzazione di tutti gli articoli di cancelleria contenente
--   • Codice
--   • Descrizione
--   • UnitaDiMisura
--   • Prezzo
--   • Sconto
--   • QuantitaMinima
--   • PartitaIVA fornitore

select Articolo.Codice,
	   Articolo.Descrizione,
	   Articolo.UnitaDiMisura,
	   Fornisce.PrezzoUnitario,
	   Fornisce.Sconto,
	   Fornisce.QuantitaMinima,
	   Fornitore.PartitaIVA
	from Articolo inner join Fornisce on Articolo.Codice=Fornisce.Articolo
	              inner join Fornitore on Fornitore.PartitaIVA=Fornisce.Fornitore
	order by Articolo.Codice asc;

-- Visualizzazione di tutti gli articoli che non sono forniti da alcun fornitore

select Articolo.Codice, 
	   Articolo.Descrizione,
	   Articolo.UnitaDiMisura
	from Articolo left join Fornisce on Articolo.Codice=Fornisce.Articolo
	where Fornitore is NULL;



-- Aggiornamento dello stato di un ordine	

update Ordine set Stato='emesso' where Codice=2;

update Ordine set Stato='Consegnato' where Codice=10;


-- Visualizzazione delle informazioni relative ad una richiesta d'acquisto

select * from RichiestaAcquisto where Dipartimento='DIP' and Numero=2;

select * from Include where NumeroRichiesta=2 and Dipartimento='DIP';

select * from Include inner join Ordine on Include.Ordine=Ordine.Codice;


-- Inserimento di un nuovo ordine

start transaction;

insert into Ordine(Fornitore) values ('YY39520660462');

update Include set Ordine=currval('persons_id_seq') 
			   where Articolo IN (123,22,33,56) and
		             Ordine is NULL;	
commit;


-- oppure

start transaction;

insert into Ordine(Fornitore) values ('YY39520660462');

update Include set Ordine=currval('persons_id_seq') 
			   where (NumeroRichiesta, Dipartimento, Articolo) IN
			         ((2, 'DYQSNJ', 226), (0, 'WPIUQD', 145));

commit;

-- Inserimento di una nuova richiesta

create or replace function InserisciRichiesta(dip text, _articolo integer[], _quantita integer[])
  returns void 
  language plpgsql as
$$
declare
	codice integer;
begin
	insert into RichiestaAcquisto(Dipartimento) values (dip);
	-- TODO check array length
	select prossimonumero-1 into codice from ProssimoCodiceRichiesta where Dipartimento=dip order by ProssimoNumero desc limit 1;
	insert into Include(Dipartimento, NumeroRichiesta, Articolo, Quantita)
	SELECT dip, codice, unnest(_articolo), unnest(_quantita);
end;
$$;
