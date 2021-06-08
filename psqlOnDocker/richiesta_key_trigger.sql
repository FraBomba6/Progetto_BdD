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

create trigger imposta_numero_richiesta
before insert on richiestaacquisto
for each row
execute procedure set_numero_richiesta();
