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
		from Include, Fornisce, Ordine
		where (Fornisce.Articolo = new.Articolo) and
			  (forn = Fornisce.Fornitore);

		if n = 0 then
			raise notice 'Prodotto non valido per fornitore';
			return null;
		end if;
		return new;
	end;
$$;

create trigger controlla_fornitore
before insert or update on Include
for each row
execute procedure controlla_ordine_valido();
