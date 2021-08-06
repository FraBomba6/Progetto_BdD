start transaction;
SET LOCAL enable_seqscan = OFF;
update include set ordine=NULL where Dipartimento='WLIQJC' and NumeroRichiesta=79 and Articolo = 102;
explain analyse update include set ordine=18 where Dipartimento='WLIQJC' and NumeroRichiesta=79 and Articolo = 102;
rollback;
