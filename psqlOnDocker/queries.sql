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

create or replace function NuovoOrdine(fornitore text, _articolo integer[], _richiesta integer[], _dipartimento text[])
  returns void 
  language plpgsql as
$$
declare
	codice integer;
begin
	insert into Ordine(Fornitore) values (fornitore);

	if array_length(_articolo, 1) == 0 then
		raise exception 'Ogni vettore deve contenere almeno un elemento';
	end if;

	if array_length(_articolo, 1) == array_length(_richiesta, 1) AND
	   array_length(_richiesta, 1) == array_length(_dipartimento, 1) then

		codice = currval('ordine_codice_seq');
		UPDATE Include i
			SET Ordine = codice
			FROM (
				select unnest(_dipartimento) as Dipartimento,
					   unnest(_richiesta) as NumeroRichiesta,
					   unnest(_articolo) as Articolo 
			 ) u
		WHERE i.Dipartimento = u.Dipartimento and
			  i.NumeroRichiesta = u.NumeroRichiesta and
			  i.Articolo = u.Articolo;
	else
		raise exception 'Gli array hanno cardinalità diverse';
	end if;
end;
$$;


-- Inserimento di una nuova richiesta

create or replace function InserisciRichiesta(dip char(6), _articolo integer[], _quantita integer[])
  returns void 
  language plpgsql as
$$
declare
	codice integer;
begin
	insert into RichiestaAcquisto(Dipartimento) values (dip);
	select prossimonumero-1 into codice from ProssimoCodiceRichiesta where Dipartimento=dip;

	if array_length(_articolo, 1) IS NULL then
		raise exception 'Specificare almeno un articolo';
	elseif array_length(_quantita, 1) IS NULL then
		insert into Include(Dipartimento, NumeroRichiesta, Articolo, Quantita)
			select dip, codice, unnest(_articolo), 1;
	elseif array_length(_articolo, 1) = array_length(_quantita, 1) then
		insert into Include(Dipartimento, NumeroRichiesta, Articolo, Quantita)
			select dip, codice, unnest(_articolo), unnest(_quantita);
	else
		raise exception 'Gli array hanno cardinalità diverse';
	end if;
end;
$$;

-- Visualizzazione degli articoli contenuti in una richiesta d'acquisto

select * from RichiestaAcquisto inner join Include on RichiestaAcquisto.Dipartimento = Include.Dipartimento and RichiestaAcquisto.Numero = Include.NumeroRichiesta;


-- Calcolo della spesa mensile dei dipartimenti

-- Calcolo della spesa complessiva dell’ente in un intervallo di tempo (funzione?)

