# %%
import datetime
import querygenerator
from faker import Faker
import random

fake = Faker()

StatoRic = ['emessa', 'lavorazione', 'evasa', 'chiusa']
Classe = ['cancelleria', 'libri', 'elettronica', 'informatica', 'pulizia', 'mobilia']
UnitaDiMisura = ['cad', 'kg', 'm', 'l']
StatoOrdine = ['emesso', 'spedito', 'consegnato']


# %%
def getResponabile():
    return {
        'CodiceFiscale': fake.unique.pystr_format(string_format='??????##?##?###?').upper(),
        'Nome': fake.first_name(),
        'Cognome': fake.last_name(),
        'DataNascita': fake.date_between(start_date='-70y', end_date='-20y').strftime('%Y-%m-%d'),
        'LuogoNascita': fake.city()
    }


def getDipartimento(responabile):
    return {
        'Codice': fake.unique.pystr_format(string_format='??????').upper(),
        'Descrizione': fake.sentence(nb_words=5),
        'Responsabile': responabile
    }


def getRichiestaAcquisto(numero, dipartimento):
    return {
        'Numero': numero,
        'Dipartimento': dipartimento,
        'DataEmissione': fake.date_between(start_date='-2y').strftime('%Y-%m-%d')
    }


def getArticolo(codice):
    return {
        'Codice': codice,
        'Descrizione': fake.sentence(nb_words=5),
        'Classe': random.choice(Classe),
        'UnitaDiMisura': random.choice(UnitaDiMisura)
    }


def getFornitore():
    return {
        'PartitaIVA': fake.unique.pystr_format(string_format='??###########').upper(),
        'Indirizzo': fake.unique.address(),
        'Email': fake.unique.ascii_company_email(),
        'FAX': fake.unique.msisdn()
    }


def getRecapitoTelefonico(fornitore):
    return {
        'NumeroTelefono': fake.unique.msisdn(),
        'Fornitore': fornitore
    }


def getFornisce(articolo, fornitore):
    return {
        'Articolo': articolo,
        'Fornitore': fornitore,
        'Sconto': round(random.uniform(0, 50), 2),
        'PrezzoUnitario': round(random.uniform(0, 200), 2),
        'CodBar': fake.pystr_format(string_format='####################')
    }


def getOrdine(fornitore):
    data = fake.date_between(start_date='-2y')
    stato = ''
    if data < datetime.date.today() - datetime.timedelta(days=90):
        stato = 'consegnato'
    elif data < datetime.date.today() - datetime.timedelta(days=30):
        stato = 'spedito'
    else:
        stato = 'emesso'
    return {
        'Fornitore': fornitore,
        'Stato': stato,
        'DataEmissione': data.strftime('%Y-%m-%d')
    }


def getInclude(dipartimento, numeroRichiesta, articolo):
    return {
        'Dipartimento': dipartimento,
        'NumeroRichiesta': numeroRichiesta,
        'Articolo': articolo,
        'Quantita': random.randint(1, 50)
    }


# %%
listaResponsabile = []
for i in range(25):
    listaResponsabile.append(getResponabile())

listaDipartimento = []
for i in range(30):
    resp = listaResponsabile[i % len(listaResponsabile)]['CodiceFiscale']
    listaDipartimento.append(getDipartimento(resp))

listaRichiestaAcquisto = []
for i in range(6000):
    dip = listaDipartimento[i % len(listaDipartimento)]['Codice']
    listaRichiestaAcquisto.append(getRichiestaAcquisto(i, dip))

listaArticolo = []
for i in range(500):
    listaArticolo.append(getArticolo(i))

listaFornitore = []
listaRecapitoTelefonico = []
for i in range(5):
    fornitore = getFornitore()
    listaFornitore.append(fornitore)
    listaRecapitoTelefonico.append(getRecapitoTelefonico(fornitore['PartitaIVA']))

listaFornisce = []
for i in range(750):
    offset = 0
    if i > 499:
        offset = 1
    art = listaArticolo[i % len(listaArticolo)]['Codice']
    fornitore = listaFornitore[(i + offset) % len(listaFornitore)]['PartitaIVA']
    listaFornisce.append(getFornisce(art, fornitore))

listaOrdine = []
for i in range(200):
    fornitore = listaFornitore[i % len(listaFornitore)]['PartitaIVA']
    listaOrdine.append(getOrdine(fornitore))

listaInclude = []
for richiesta in listaRichiestaAcquisto:
    articoli = random.sample(listaArticolo, 10)
    for articolo in articoli:
        listaInclude.append(getInclude(richiesta['Dipartimento'], richiesta['Numero'], articolo['Codice']))

# %%
tabelle = {
        'Responsabile': listaResponsabile,
        'Dipartimento': listaDipartimento,
        'RichiestaAcquisto': listaRichiestaAcquisto,
        'Articolo': listaArticolo,
        'Fornitore': listaFornitore,
        'RecapitoTelefonico': listaRecapitoTelefonico,
        'Fornisce': listaFornisce,
        'Ordine': listaOrdine,
        'Include': listaInclude
    }

for tabella, listaEntry in tabelle.items():
    queries = []
    for entry in listaEntry:
        queries.append(querygenerator.build_from_json(tabella, entry))
    querygenerator.make_sql(tabella, queries)
