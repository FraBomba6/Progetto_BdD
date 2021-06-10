start transaction;

-- Creating enum types
create type stato_richiesta as enum ('emessa', 'lavorazione', 'evasa', 'chiusa');
create type classe_merceologica as enum ('cancelleria', 'libri', 'elettronica', 'informatica', 'pulizia', 'mobilia');
create type unita_misura as enum ('cad', 'kg', 'm', 'l');
create type stato_ordine as enum ('emesso', 'spedito', 'consegnato');

-- Creating tables with fk and pk constraints
create table Responsabile(
	CodiceFiscale char(16) primary key,
	Nome text not null,
	Cognome text not null, 
	DataNascita date not null,
	LuogoNascita text not null
);

create table Dipartimento(
	Codice char(6) primary key,
	Descrizione text not null,
	Responsabile char(16) not null references Responsabile on update cascade on delete restrict
);


create table RichiestaAcquisto(
	Numero integer,
	Dipartimento char(6) not null references Dipartimento on update cascade on delete restrict,
	DataEmissione date not null default current_date,
	Stato stato_richiesta not null default 'emessa',
	primary key(Numero, Dipartimento)
);						


create table Articolo(
	Codice serial primary key,
	Descrizione text not null,
	Classe classe_merceologica not null,
	UnitaDiMisura unita_misura not null
);

create table Fornitore(
	PartitaIVA char(13) primary key,
	Indirizzo text not null,
	Email varchar(50) not null,
	FAX varchar(15)
);

create table RecapitoTelefonico(
	NumeroTelefono varchar(15) primary key,
	Fornitore char(13) not null references Fornitore on update cascade on delete cascade
);

create table Fornisce(
	Articolo integer references Articolo on update cascade on delete cascade,
	Fornitore char(13) references Fornitore on update cascade on delete cascade,
	Sconto numeric not null default 0,
	PrezzoUnitario numeric not null check(PrezzoUnitario > 0),
	QuantitaMinima integer not null default 1 check(QuantitaMinima >= 1),
	CodBar varchar(20) not null,
	primary key (Articolo, Fornitore)
);


create table Ordine(
	Codice serial primary key,
	Fornitore char(13) not null references Fornitore on update cascade on delete restrict,
	Stato stato_ordine not null default 'emesso',
	DataEmissione date not null default current_date
);

create table Include(
	Dipartimento char(6), 
	NumeroRichiesta integer,
	Articolo integer references Articolo on update cascade on delete restrict,
	Ordine integer default null references Ordine on update cascade on delete set null,
	DataConsegna date default null,
	Quantita numeric not null check(Quantita > 0),
	PrezzoUnitario numeric default null,
	primary key (Dipartimento, NumeroRichiesta, Articolo),
	foreign key (Dipartimento, NumeroRichiesta ) references RichiestaAcquisto(Dipartimento, Numero) on update cascade on delete restrict
);


-- Trigger function that checks if article's supplier is the same as the referenced order's supplier
create or replace function controlla_ordine_valido()
returns trigger language plpgsql as
$$
	declare
		n integer;
		forn character(13);
	begin
		if new.Ordine IS NULL then
			return new;
		end if;

		select Fornitore into forn from Ordine where Codice = new.Ordine;

		select count(*) into n
		from Fornisce
		where (Fornisce.Articolo = new.Articolo) and
			  (forn = Fornisce.Fornitore);

		if n = 0 then
			raise notice 'Prodotto non valido per fornitore';
			return null;
		end if;
		return new;
	end;
$$;

-- Trigger is executed at every insertion or update on Include
create trigger controlla_fornitore
before insert or update on Include
for each row
execute procedure controlla_ordine_valido();

-- Function that maps an order state to a request state (they differ by names, but its a one-to-one relation)
create or replace function map_stati(ord stato_ordine)
   returns stato_richiesta
   language plpgsql
  as
$$
	declare
		ret stato_richiesta;
	begin
		if ord::text = 'emesso' then
			ret = 'lavorazione';
		elsif ord::text = 'spedito' then
			ret = 'evasa';
		else
			ret = 'chiusa';	
		end if;
		return ret;
	end;
$$;


-- Trigger function that updates request state according to the states of the orders that satisfy the request
create or replace function aggiorna_richiesta_da_ordine()
returns trigger language plpgsql as
$$
	begin
	    update richiestaacquisto
	        set stato = entry.stato from (
                select distinct I1.dipartimento, I1.numerorichiesta, map_stati(min(stato)) as stato
                    from include as I1
                        inner join (select distinct dipartimento, numerorichiesta from Include as I2 where ordine = new.Codice) as I2 on (I1.dipartimento, I1.numerorichiesta) = (I2.dipartimento, I2.numerorichiesta)
                        inner join ordine on codice = I1.ordine
                    group by I1.dipartimento, I1.numerorichiesta
	            ) as entry
	        where richiestaacquisto.dipartimento = entry.Dipartimento and RichiestaAcquisto.numero = entry.NumeroRichiesta;

		return new;
	end;
$$;


-- Trigger is executed everytime and order is inserted or updated
create trigger aggiorna_stato_richiesta_da_ordine
after insert or update on Ordine
for each row
execute procedure aggiorna_richiesta_da_ordine();

-- Trigger function that updates request state according to the states of the orders that satisfy the request
create or replace function aggiorna_richiesta_da_include()
returns trigger language plpgsql as
$$
    declare
        newStato stato_richiesta;
	begin
	    if new.ordine is null then
            return new;
        end if;
	    select CASE WHEN min(CASE WHEN stato is null then 0 else 1 END) = 0 THEN null ELSE min(stato) END into newStato from Include join Ordine on Codice = Include.Ordine where numerorichiesta = new.NumeroRichiesta and dipartimento = new.Dipartimento;
	    if newStato is null then
            newStato = 'emessa';
        else
	        newStato = map_stati(newStato);
        end if;
	    update richiestaacquisto set stato = newStato where RichiestaAcquisto.dipartimento = new.Dipartimento and RichiestaAcquisto.numero = new.NumeroRichiesta;
		return new;
	end;
$$;

-- Trigger is executed everytime and order is inserted or updated
create trigger aggiorna_stato_richiesta_da_include
after insert or update of ordine on Include
for each row
execute procedure aggiorna_richiesta_da_include();


-- Trigger function that gives incremental numbers to every department-related requests
create or replace function set_numero_richiesta()
returns trigger language plpgsql as
$$
	declare
		n integer;
	begin
		select numero into n from richiestaacquisto where dipartimento = new.dipartimento order by numero desc limit 1;
		if n is null then
			n = 0;
		else
			n = n+1;
		end if;
		new.numero := n;
		return new;
	end;
$$;

-- Trigger is executed on every insertion inside richiestaacquisto
create trigger imposta_numero_richiesta
before insert on richiestaacquisto
for each row
execute procedure set_numero_richiesta();

commit;

