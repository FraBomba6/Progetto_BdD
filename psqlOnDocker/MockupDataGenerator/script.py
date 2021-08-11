# %%
import datetime
import querygenerator
from faker import Faker
import random

fake = Faker()

Classe = ['cancelleria', 'pulizia', 'libri', 'elettronica', 'informatica', 'mobilia']
UnitaDiMisura = ['cad', 'kg', 'm', 'l']
StatoOrdine = ['emesso', 'spedito', 'consegnato', 'annullato']

rangePrezzi = {
    'cancelleria': {
        'low': 0.1,
        'high': 30
    },
    'libri': {
        'low': 5,
        'high': 50
    },
    'elettronica': {
        'low': 15,
        'high': 1500
    },
    'informatica': {
        'low': 10,
        'high': 1500
    },
    'pulizia': {
        'low': 1,
        'high': 30
    },
    'mobilia': {
        'low': 5,
        'high': 500
    }
}


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


def getRichiestaAcquisto(dipartimento):
    return {
        'Dipartimento': dipartimento,
        'DataEmissione': fake.date_between(start_date='-280d').strftime('%Y-%m-%d')
    }


def getArticolo(codice):
    return {
        'Codice': codice,
        'Descrizione': fake.sentence(nb_words=5),
        'Classe': random.choices(Classe, weights=[50, 20, 10, 5, 10, 5])[0],
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


def getFornisce(articolo, classe, fornitore):
    return {
        'Articolo': articolo,
        'Fornitore': fornitore,
        'Sconto': round(random.uniform(0, 50), 2),
        'PrezzoUnitario': round(random.uniform(rangePrezzi[classe]['low'], rangePrezzi[classe]['high']), 2),
        'CodBar': fake.pystr_format(string_format='####################')
    }


def getOrdine(fornitore, data):
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
        'Quantita': random.randint(1, 20)
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
for i in range(2400):
    dip = listaDipartimento[i % len(listaDipartimento)]['Codice']
    listaRichiestaAcquisto.append(getRichiestaAcquisto(dip))

listaArticolo = []
for i in range(300):
    listaArticolo.append(getArticolo(i+1))

listaFornitore = []
listaRecapitoTelefonico = []
for i in range(5):
    fornitore = getFornitore()
    listaFornitore.append(fornitore)
    listaRecapitoTelefonico.append(getRecapitoTelefonico(fornitore['PartitaIVA']))

listaFornisce = []
for i in range(450):
    offset = 0
    if i > 299:
        offset = 1
    art = listaArticolo[i % len(listaArticolo)]
    fornitore = listaFornitore[(i + offset) % len(listaFornitore)]['PartitaIVA']
    listaFornisce.append(getFornisce(art['Codice'], art['Classe'], fornitore))

listaInclude = []
for i in range(len(listaRichiestaAcquisto)):
    numero = (i // len(listaDipartimento)) + 1
    articoliDaOrdinare = random.sample(listaArticolo, 5)
    for articolo in articoliDaOrdinare:
        listaInclude.append(getInclude(listaRichiestaAcquisto[i]['Dipartimento'], numero, articolo['Codice']))

# %%
tabelle = {
        'Responsabile': listaResponsabile,
        'Dipartimento': listaDipartimento,
        'RichiestaAcquisto': listaRichiestaAcquisto,
        'Articolo': listaArticolo,
        'Fornitore': listaFornitore,
        'RecapitoTelefonico': listaRecapitoTelefonico,
        'Fornisce': listaFornisce,
        'Include': listaInclude
    }


for tabella, listaEntry in tabelle.items():
    queries = []
    for entry in listaEntry:
        queries.append(querygenerator.build_from_json(tabella, entry))
    querygenerator.make_sql(tabella, queries)

# %%
for i in range(len(listaRichiestaAcquisto)):
    listaRichiestaAcquisto[i]['Numero'] = (i // len(listaDipartimento)) + 1

# %%
codiceOrdine = 1
listaOrdine = []

# Generate Ordine
today = datetime.date.today()
start = today - datetime.timedelta(days=280)

while start <= today:
    weekDelta = datetime.timedelta(days=7)
    orderDay = start + weekDelta
    print(f"Week from {start} to {orderDay}")
    richiesteValide = []
    for richiesta in listaRichiestaAcquisto:
        if start <= datetime.date.fromisoformat(richiesta['DataEmissione']) < orderDay:
            richiesteValide.append((richiesta['Dipartimento'], richiesta['Numero']))

    articoliDaOrdinare = []
    for relazione in listaInclude:
        if (relazione['Dipartimento'], relazione['NumeroRichiesta']) in richiesteValide:
            articoliDaOrdinare.append((relazione['Articolo'], relazione['Dipartimento'], relazione['NumeroRichiesta']))

    articoliForniti = []
    for articolo in articoliDaOrdinare:
        best_fornitore = ''
        best_prezzoScontato = 0
        for fornitura in listaFornisce:
            if articolo[0] == fornitura['Articolo'] and (best_prezzoScontato == 0 or fornitura['PrezzoUnitario']*(1 - fornitura['Sconto'] * 0.01) < best_prezzoScontato):
                best_fornitore = fornitura['Fornitore']
        articoliForniti.append((articolo[0], best_fornitore, articolo[1], articolo[2]))

    ordiniSettimanali = {}
    for fornitore in listaFornitore:
        for articolo in articoliForniti:
            if fornitore['PartitaIVA'] == articolo[1]:
                if fornitore['PartitaIVA'] not in ordiniSettimanali.keys():
                    ordine = getOrdine(fornitore['PartitaIVA'], orderDay)
                    if ordine['Stato'] == 'spedito' or ordine['Stato'] == 'consegnato':
                        ordine['DataConsegna'] = (datetime.datetime.strptime(ordine['DataEmissione'], '%Y-%m-%d') + datetime.timedelta(days=5)).strftime('%Y-%m-%d')
                    ordine['Codice'] = codiceOrdine
                    listaOrdine.append(ordine)
                    ordiniSettimanali[fornitore['PartitaIVA']] = codiceOrdine
                    codiceOrdine += 1
                for i in range((articolo[3] - 1) * 150, (articolo[3] - 1) * 150 + 150):
                    if listaInclude[i]['Dipartimento'] == articolo[2] and listaInclude[i]['NumeroRichiesta'] == articolo[3] and listaInclude[i]['Articolo'] == articolo[0]:
                        listaInclude[i]['Ordine'] = ordiniSettimanali[articolo[1]]
                        break

    start += weekDelta

# %%
for entryInclude in listaInclude:
    ordine = entryInclude['Ordine']
    fornitore = ''
    prezzo = 0
    for entryOrdine in listaOrdine:
        if entryOrdine['Codice'] == ordine:
            fornitore = entryOrdine['Fornitore']
            break
    for entryFornisce in listaFornisce:
        if entryFornisce['Fornitore'] == fornitore and entryFornisce['Articolo'] == entryInclude['Articolo']:
            prezzo = entryFornisce['PrezzoUnitario']
            break
    rangeMin = 1
    rangeMax = min(30, int(3000/prezzo))
    entryInclude['Quantita'] = random.randint(rangeMin, rangeMax)

# %%
tabelle['Ordine'] = listaOrdine
for key, value in tabelle.items():
    print(f"{key}: {len(value)}")

# %%
queries = []
for entry in listaOrdine:
    queries.append(querygenerator.build_from_json('Ordine', entry))
querygenerator.make_sql('Ordine', queries)
queries = []
for entry in listaInclude:
    queries.append(querygenerator.build_from_json('Include', entry))
querygenerator.make_sql('Include', queries)
