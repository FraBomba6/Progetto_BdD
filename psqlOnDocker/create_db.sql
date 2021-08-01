start transaction;

-- Creating enum types
create type classe_merceologica as enum ('cancelleria', 'libri', 'elettronica', 'informatica', 'pulizia', 'mobilia');
create type unita_misura as enum ('cad', 'kg', 'm', 'l');
create type stato_ordine as enum ('emesso', 'spedito', 'consegnato', 'annullato');
create type stato_articolo as enum ('richiesto', 'ordinato', 'spedito', 'consegnato'); 

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
    DataConsegna    date             default null,
    Quantita        numeric          not null check (Quantita > 0),
    PrezzoUnitario  numeric(7, 2)    default null, 
	StatoArticolo   stato_articolo   not null default 'richiesto',
    primary key (Dipartimento, NumeroRichiesta, Articolo),
    foreign key (Dipartimento, NumeroRichiesta) references RichiestaAcquisto (Dipartimento, Numero) on update cascade on delete restrict
);

-- Trigger function that considers new department entries in order to keep track of the incremental id
create or replace function nuova_entry_dipartimento()
    returns trigger
    language plpgsql as
$$
begin
    insert into ProssimoCodiceRichiesta(Dipartimento) values (new.Codice);
    return new;
end;
$$;

-- Trigger is executed everytime a new Department is added
create trigger nuova_entry_dip_trigger
    after insert
    on Dipartimento
    for each row
execute procedure nuova_entry_dipartimento();


-- Trigger function that compute the final price for an entry in Include table
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

-- Trigger is executed everytime an order is associated with an article
create trigger final_price
    before insert or update of ordine
    on Include
    for each row
execute procedure compute_final_price();


-- Trigger function that checks if article's supplier is the same as the referenced order's supplier
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

-- Trigger is executed at every insertion or update on Include
create trigger controlla_fornitore
    before insert or update
    on Include
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



-- Trigger function that gives incremental numbers to every department-related requests
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

-- Trigger is executed on every insertion inside richiestaacquisto
create trigger imposta_numero_richiesta
    before insert
    on richiestaacquisto
    for each row
execute procedure set_numero_richiesta();

commit;

