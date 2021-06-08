start transaction;

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


create or replace function aggiorna_richiesta()
returns trigger language plpgsql as
$$
	declare
		minstato stato_ordine;
		new_stato_richiesta stato_richiesta;
	begin
		select min(stato) into minstato from Include inner join Ordine on Include.ordine = Ordine.codice where ordine = new.codice;
		new_stato_richiesta = map_stati(minstato);
		update richiestaacquisto set stato = new_stato_richiesta where (numero, dipartimento) in (select numerorichiesta, dipartimento from include where ordine = new.codice) and stato <> new_stato_richiesta;
		return new;
	end;
$$;

create trigger aggiorna_stato_richiesta
after insert or update on Ordine
for each row
execute procedure aggiorna_richiesta();
commit;
