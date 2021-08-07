library("ggplot2")
library("RPostgreSQL")
library("dplyr")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(
  drv,
  dbname = "ufficioacquisti",
  host = "localhost",
  port = 15000,
  user = "postgres",
  password = "bdd2021"
)

query <- "explain analyse select * from Include where numerorichiesta=0 and dipartimento='THQQYK'"
senzaIndice <- data.frame()
dbGetQuery(con, query)
dbGetQuery(con, query)
for (var in 0:29) {
  senzaIndice <- rbind(senzaIndice, dbGetQuery(con, query)[6:7,])
}
dbGetQuery(con, "create index index_num_dip on include(numerorichiesta, dipartimento)")
conIndice <- data.frame()
dbGetQuery(con, query)
dbGetQuery(con, query)
for (var in 0:29) {
  conIndice <- rbind(conIndice, dbGetQuery(con, query)[3:4,])
}
dbGetQuery(con, "drop index index_num_dip")

colnames(senzaIndice)[1] <- "Planning senza indice"
colnames(senzaIndice)[2] <- "Execution senza indice"
colnames(conIndice)[1] <- "Planning con indice"
colnames(conIndice)[2] <- "Execution con indice"

senzaIndice[, 1] <- as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 1]))
senzaIndice[, 2] <- as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 2]))
conIndice[, 1] <- as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 1]))
conIndice[, 2] <- as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 2]))

evaluateIndex <- function(indexName, query, prep_query = NULL, indexQuery, dropIndexQuery, rowsToKeepWithout, rowsToKeepWith) {
  senzaIndice <- data.frame()
  for (var in 0:49) {
    dbBegin(con)
    dbSendQuery(con, "SET LOCAL enable_seqscan = OFF;")
    if (!missing(prep_query)){
      dbSendQuery(con, prep_query)
    }
    dbGetQuery(con, query)[rowsToKeepWithout,]
    senzaIndice <- rbind(senzaIndice, dbGetQuery(con, query)[rowsToKeepWithout,])
    dbRollback(con)
  }

  dbSendQuery(con, indexQuery)
  conIndice <- data.frame()
  for (var in 0:49) {
    dbBegin(con)
    dbSendQuery(con, "SET LOCAL enable_seqscan = OFF;")
    if (!missing(prep_query)){
      dbSendQuery(con, prep_query)
    }
    dbGetQuery(con, query)[rowsToKeepWith,]
    conIndice <- rbind(conIndice, dbGetQuery(con, query)[rowsToKeepWith,])
    dbRollback(con)
  }
  dbSendQuery(con, dropIndexQuery)

  colnames(senzaIndice)[1] <- "Planning"
  colnames(senzaIndice)[2] <- "Execution"
  colnames(conIndice)[1] <- "Planning"
  colnames(conIndice)[2] <- "Execution"

  senzaIndice$"Tipo" <- "senza"
  conIndice$"Tipo" <- "con"

  senzaIndice[, 1] <- format(as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 1])), nsmall = 3)
  senzaIndice[, 2] <- format(as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", senzaIndice[, 2])), nsmall = 3)
  conIndice[, 1] <- format(as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", conIndice[, 1])), nsmall = 3)
  conIndice[, 2] <- format(as.numeric(gsub("([0-9]+\\.?[0-9]+)|.", "\\1", conIndice[, 2])), nsmall = 3)

  risultato <- rbind(senzaIndice, conIndice)

  write.csv(risultato, paste0("./R/csv/", paste0(indexName, ".csv")), quote = FALSE, row.names = FALSE)
  risultato[, 1] <- as.numeric(risultato[, 1])
  risultato[, 2] <- as.numeric(risultato[, 2])

  plot <- ggplot(risultato, aes(fill = Tipo)) +
    geom_boxplot(aes(Tipo, Planning), outlier.shape = NA) +
    coord_cartesian(ylim = quantile(risultato$Planning, c(0.1, 0.9)))
  ggsave(paste0("./R/plots/", paste0(indexName, "_Planning.png")), width = 7.5)
  plot <- ggplot(risultato, aes(fill = Tipo)) +
    geom_boxplot(aes(Tipo, Execution), outlier.shape = NA) +
    coord_cartesian(ylim = quantile(risultato$Execution, c(0.1, 0.9)))
  ggsave(paste0("./R/plots/", paste0(indexName, "_Execution.png")), width = 7.5)
}

evaluateIndex(
  indexName = "Indice_Include.Ordine_Select",
  query = "explain analyse select * from include where ordine=5;",
  indexQuery = "create index index_ordine on include(ordine);",
  dropIndexQuery = "drop index index_ordine;",
  rowsToKeepWithout = c(4,9),
  rowsToKeepWith = c(6, 7)
)

evaluateIndex(
  indexName = "Indice_Include.Ordine_Update",
  query = "explain analyse update include set ordine=18 where Dipartimento='WLIQJC' and NumeroRichiesta=79 and Articolo = 102;",
  prep_query = "update include set ordine=NULL where Dipartimento='WLIQJC' and NumeroRichiesta=79 and Articolo = 102;",
  indexQuery = "create index index_ordine on include(ordine);",
  dropIndexQuery = "drop index index_ordine;",
  rowsToKeepWithout = c(4, 11),
  rowsToKeepWith = c(4, 11)
)

evaluateIndex(
  indexName = "Indice_RichiestaAcquisto.DataEmissione_Select",
  query = "explain analyse select * from RichiestaAcquisto where DataEmissione BETWEEN '2020-10-01' AND '2020-11-01';",
  indexQuery = "create index index_data on RichiestaAcquisto(DataEmissione);",
  dropIndexQuery = "drop index index_data;",
  rowsToKeepWithout = c(4, 9),
  rowsToKeepWith = c(6, 7)
)

evaluateIndex(
  indexName = "Indice_RichiestaAcquisto.DataEmissione_Update",
  query = "explain analyse insert into RichiestaAcquisto(Dipartimento) values ('ZXTSNW');",
  indexQuery = "create index index_data on RichiestaAcquisto(DataEmissione);",
  dropIndexQuery = "drop index index_data;",
  rowsToKeepWithout = c(3, 6),
  rowsToKeepWith = c(3, 6)
)