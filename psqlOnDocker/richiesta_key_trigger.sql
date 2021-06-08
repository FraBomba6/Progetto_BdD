begin transaction;

create or replace function set_numero_richiesta()
returns trigger language plpgsql as
$$
	declare
		n integer;
	begin
		select top 1 numero into n from richiestaacquisto where dipartimento = new.dipartimento order by numero desc;
		n = n+1;
		new.numero := n;
		return new;
	end;
$$;

create trigger imposta_numero_richiesta
before insert on richiestaacquisto
execute procedure set_numero_richiesta();
commit;
