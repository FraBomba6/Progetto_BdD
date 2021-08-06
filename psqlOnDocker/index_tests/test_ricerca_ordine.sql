start transaction;
SET LOCAL enable_seqscan = OFF;
explain analyse select * from include where ordine=5;
rollback;
