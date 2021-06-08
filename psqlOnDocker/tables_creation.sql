begin transaction;

create type stato_richiesta as enum ('emessa', 'lavorazione', 'evasa', 'chiusa');

create type classe_merceologica as enum ('cancelleria', 'libri', 'elettronica', 'informatica', 'pulizia', 'mobilia');

create type unita_misura as enum ('cad', 'kg', 'm', 'l');

create type stato_ordine as enum ('emesso', 'spedito', 'consegnato');

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
	Numero serial,
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
	foreign key (Dipartimento, NumeroRichiesta ) references RichiestaAcquisto(Dipartimento, Numero)
);

commit;
