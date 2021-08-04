start transaction;

--      +----------+
--      |   ENUM   |
--      +----------+

create type classe_merceologica as enum ('cancelleria', 'libri', 'elettronica', 'informatica', 'pulizia', 'mobilia');
create type unita_misura as enum ('cad', 'kg', 'm', 'l');
create type stato_ordine as enum ('emesso', 'spedito', 'consegnato', 'annullato');


--      +-----------+
--      |  TABELLE  |
--      +-----------+

create table Responsabile
(
    CodiceFiscale char(16) primary key,
    Nome          text not null,
    Cognome       text not null,
    DataNascita   date not null,
    LuogoNascita  text not null
);


create table Dipartimento
(
    Codice       char(6) primary key,
    Descrizione  text     not null,
    Responsabile char(16) not null references Responsabile on update cascade on delete restrict
);


create table ProssimoCodiceRichiesta
(
    Dipartimento   char(6) primary key references Dipartimento on update cascade on delete cascade,
    ProssimoNumero integer default 0
);


create table RichiestaAcquisto
(
    Numero           integer,
    Dipartimento     char(6)      not null references Dipartimento on update cascade on delete restrict,
    DataEmissione    date         not null default current_date,
	NumeroArticoli   integer      not null default 0,
    primary key (Numero, Dipartimento)
);


create table Articolo
(
    Codice        serial primary key,
    Descrizione   text                not null,
    Classe        classe_merceologica not null,
    UnitaDiMisura unita_misura        not null
);


create table Fornitore
(
    PartitaIVA char(13) primary key,
    Indirizzo  text        not null,
    Email      varchar(50) not null,
    FAX        varchar(15)
);


create table RecapitoTelefonico
(
    NumeroTelefono varchar(15) primary key,
    Fornitore      char(13) not null references Fornitore on update cascade on delete cascade
);


create table Fornisce
(
    Articolo       integer references Articolo on update cascade on delete cascade,
    Fornitore      char(13) references Fornitore on update cascade on delete cascade,
    Sconto         numeric     not null default 0,
    PrezzoUnitario numeric     not null check (PrezzoUnitario > 0),
    QuantitaMinima integer     not null default 1 check (QuantitaMinima >= 1),
    CodBar         varchar(20) not null,
    primary key (Articolo, Fornitore)
);


create table Ordine
(
    Codice        serial primary key,
    Fornitore     char(13)     not null references Fornitore on update cascade on delete restrict,
    Stato         stato_ordine not null default 'emesso',
    DataEmissione date         not null default current_date
);


create table Include
(
    Dipartimento    char(6),
    NumeroRichiesta integer,
    Articolo        integer          references Articolo on update cascade on delete restrict,
    Ordine          integer          default null references Ordine on update cascade on delete set null,
    Quantita        numeric          not null check (Quantita > 0),
    PrezzoUnitario  numeric(7, 2)    default null, 
    primary key (Dipartimento, NumeroRichiesta, Articolo),
    foreign key (Dipartimento, NumeroRichiesta) references RichiestaAcquisto (Dipartimento, Numero) on update cascade on delete restrict
);




--      +----------+
--      | TRIGGERS |
--      +----------+

-- Funzione trigger per l'assegnazione di un codice incrementato 
-- per dipartimento ad ogni Richiesta d'Acquisto
create or replace function nuova_entry_dipartimento()
    returns trigger
    language plpgsql as
$$
begin
    insert into ProssimoCodiceRichiesta(Dipartimento) values (new.Codice);
    return new;
end;
$$;

-- Il trigger viene eseguito dopo l'inserimento di un nuovo dipartimento
create trigger nuova_entry_dip_trigger
    after insert
    on Dipartimento
    for each row
execute procedure nuova_entry_dipartimento();




-- Funzione che calcola il prezzo unitario di un articolo considerando lo sconto
-- e lo inserisce nella relativa entry di include
create or replace function compute_final_price()
    returns trigger
    language plpgsql as
$$
declare
    currentOrder    integer;
    currentSupplier varchar;
    price           numeric;
    discount        numeric;
    finalPrice      numeric;
begin
    if new.Ordine is not null then
        currentOrder = new.Ordine;
        select Fornitore into currentSupplier from Ordine where Codice = currentOrder;
        select PrezzoUnitario, Sconto
        into price, discount
        from Fornisce
        where Fornitore = currentSupplier
          and Articolo = new.Articolo;
        finalPrice = price * (1 - discount / 100);
        new.PrezzoUnitario = finalPrice;
    end if;
    return new;
end;
$$;

-- Il trigger viene eseguito dopo ogni associazione ad un ordine di un'entry di include
create trigger final_price
    before insert or update of ordine
    on Include
    for each row
execute procedure compute_final_price();




-- Funzione che verifica il rispetto del vincolo aziendale imposto
-- Ovvero "il fornitore di un ordine deve essere lo stesso di tutti gli
-- articoli inclusi nell'ordine"
create or replace function controlla_ordine_valido()
    returns trigger
    language plpgsql as
$$
declare
    n    integer;
    forn character(13);
begin
    if new.Ordine IS NULL then
        return new;
    end if;

    select Fornitore into forn from Ordine where Codice = new.Ordine;

    select count(*)
    into n
    from Fornisce
    where (Fornisce.Articolo = new.Articolo)
      and (forn = Fornisce.Fornitore);

    if n = 0 then
        raise notice 'Prodotto non valido per fornitore';
        return null;
    end if;
    return new;
end;
$$;

-- Il trigger viene eseguito ad ogni inserimento o aggiornamento di una entry
-- di include
create trigger controlla_fornitore
    before insert or update
    on Include
    for each row
execute procedure controlla_ordine_valido();




-- Funzione che assegna un codice incrementato per dipartimento ad ogni richiesta
create or replace function set_numero_richiesta()
    returns trigger
    language plpgsql as
$$
declare
    n integer;
begin
    select ProssimoNumero into n from ProssimoCodiceRichiesta where Dipartimento = new.Dipartimento;
    if n is null then
        raise notice 'Errore: dipartimento non valido';
        return null;
    else
        new.numero := n;
        update ProssimoCodiceRichiesta set ProssimoNumero = n + 1 where Dipartimento = new.Dipartimento;
        return new;
    end if;
end;
$$;

-- Il trigger viene eseguito ad ogni nuovo inserimento in RichiestaAcquisto
create trigger imposta_numero_richiesta
    before insert
    on richiestaacquisto
    for each row
execute procedure set_numero_richiesta();




-- Aggiornamento del NumeroArticoli di una Richiesta d'Acquisto all'inserimento di nuove entry in Include
create or replace function numero_articoli_aumenta()
	returns trigger
	language plpgsql as
$$
declare
	n_art integer;
begin
	update RichiestaAcquisto set NumeroArticoli = NumeroArticoli + new.Quantita where Dipartimento=new.Dipartimento and Numero=new.NumeroRichiesta;
	return new;
end;
$$;

-- Il trigger viene eseguito ogni volta che viene aggiunta una entry in Include
create trigger numero_articoli_aumenta
	before insert
	on Include
	for each row
execute procedure numero_articoli_aumenta();




-- Aggiornamento del NumeroArticoli di una Richiesta d'Acquisto alla rimozione di entry in Include
create or replace function numero_articoli_riduci()
	returns trigger
	language plpgsql as
$$
declare
	n_art integer;
begin
	update RichiestaAcquisto set NumeroArticoli = NumeroArticoli - new.Quantita where Dipartimento=old.Dipartimento and Numero=old.NumeroRichiesta;
	return old;
end;
$$;

-- Il trigger viene eseguto ogni volta che viene rimossa una entry da include
create trigger numero_articoli_riduci
	before delete 
	on Include
	for each row
execute procedure numero_articoli_riduci();




-- Aggiornamento del NumeroArticoli di una Richiesta d'Acquisto alla modifica delle entry di include
create or replace function numero_articoli_aggiorna()
	returns trigger
	language plpgsql as
$$
declare
	n_art integer;
begin
	-- Si considera come uno spostamento di un'entry da una richiesta d'acquisto ad un'altra
	-- Di conseguenza si decrementa il numero articoli della richiesta originaria
	-- E si incrementa il numero articoli della nuova Richiesta Acquisto
	update RichiestaAcquisto set NumeroArticoli = NumeroArticoli - old.Quantita where Dipartimento=old.Dipartimento and Numero=old.NumeroRichiesta;
	update RichiestaAcquisto set NumeroArticoli = NumeroArticoli + new.Quantita where Dipartimento=new.Dipartimento and Numero=new.NumeroRichiesta;
	return new;
end;
$$;

-- Il trigger viene eseguito ogni volta che una entry di include viene modificata
create trigger numero_articoli_aggiorna
	after update 
	on Include
	for each row
execute procedure numero_articoli_aggiorna();

commit;

