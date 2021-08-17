# %%
import datetime
import pandas
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

unitaDiMisura_Classe = {
    'cancelleria': ['cad', 'm'],
    'libri': ['cad'],
    'pulizia': ['cad', 'kg', 'l'],
    'elettronica': ['cad', 'm'],
    'informatica': ['cad'],
    'mobilia': ['cad']
}


def decision(probability):
    return random.random() < probability


# %%
def getResponsabile():
    return {
        'CodiceFiscale': fake.unique.pystr_format(string_format='??????##?##?###?').upper(),
        'Nome': fake.first_name(),
        'Cognome': fake.last_name(),
        'DataNascita': fake.date_between(start_date='-70y', end_date='-20y').strftime('%Y-%m-%d'),
        'LuogoNascita': fake.city()
    }


def getDipartimento(responsabileDipartimento):
    return {
        'Codice': fake.unique.pystr_format(string_format='??????').upper(),
        'Descrizione': fake.sentence(nb_words=5),
        'Responsabile': responsabileDipartimento
    }


def getRichiestaAcquisto(dipartimentoRichiesta, dataEmissione):
    return {
        'Dipartimento': dipartimentoRichiesta,
        'DataEmissione': dataEmissione
    }


def getArticolo(codiceArticolo):
    classe = random.choices(Classe, weights=[50, 20, 10, 5, 10, 5])[0]
    return {
        'Codice': codiceArticolo,
        'Descrizione': fake.sentence(nb_words=5),
        'Classe': classe,
        'UnitaDiMisura': random.choice(unitaDiMisura_Classe[classe])
    }


def getFornitore():
    return {
        'PartitaIVA': fake.unique.pystr_format(string_format='??###########').upper(),
        'Indirizzo': fake.unique.address(),
        'Email': fake.unique.ascii_company_email(),
        'FAX': fake.unique.msisdn()
    }


def getRecapitoTelefonico(fornitoreRecapito):
    return {
        'NumeroTelefono': fake.unique.msisdn(),
        'Fornitore': fornitoreRecapito
    }


def getFornisce(articoloFornito, classe, fornitoreArticolo):
    return {
        'Articolo': articoloFornito,
        'Fornitore': fornitoreArticolo,
        'Sconto': round(random.uniform(0, 50), 2),
        'PrezzoUnitario': round(random.uniform(rangePrezzi[classe]['low'], rangePrezzi[classe]['high']), 2),
        'CodBar': fake.pystr_format(string_format='####################')
    }


def getOrdine(fornitoreOrdine, data):
    if data < datetime.date.today() - datetime.timedelta(days=90):
        stato = 'consegnato'
    elif data < datetime.date.today() - datetime.timedelta(days=30):
        stato = 'spedito'
    else:
        stato = 'emesso'
    return {
        'Fornitore': fornitoreOrdine,
        'Stato': stato,
        'DataEmissione': data.strftime('%Y-%m-%d')
    }


def getInclude(dipartimento, numeroRichiesta, articoloInclude):
    return {
        'Dipartimento': dipartimento,
        'NumeroRichiesta': numeroRichiesta,
        'Articolo': articoloInclude,
        'Quantita': random.randint(1, 20)
    }


# %%
volumi = {
    'responsabile': 25,
    'dipartimento': 30,
    'richiestaAcquisto': 3120,
    'articolo': 300,
    'fornitore': 5,
    'fornisce': 450
}

listaResponsabile = []
for i in range(volumi['responsabile']):
    listaResponsabile.append(getResponsabile())

listaDipartimento = []
for i in range(volumi['dipartimento']):
    resp = listaResponsabile[i % len(listaResponsabile)]['CodiceFiscale']
    listaDipartimento.append(getDipartimento(resp))


def getProbabilityVector():
    vector = []
    for dip in range(volumi['dipartimento']):
        vector.append(0.90)
    return vector


listaRichiestaAcquisto = []
probability_vector = getProbabilityVector()
minRic = 50
mediaTarget = 60
maxRic = 70
targetSettimanale = 0
ricSetFatte = 0
mediaRic = 0
settimane = 1
giorno = 1
# today = datetime.date.today()
# start = today - datetime.timedelta(days=280)
noWorkDays = [
    datetime.date(2020, 1, 1),
    datetime.date(2020, 1, 6),
    datetime.date(2020, 4, 12),
    datetime.date(2020, 4, 13),
    datetime.date(2020, 4, 25),
    datetime.date(2020, 5, 1),
    datetime.date(2020, 6, 2),
    datetime.date(2020, 8, 15),
    datetime.date(2020, 11, 1),
    datetime.date(2020, 12, 8),
    datetime.date(2020, 12, 25),
    datetime.date(2020, 12, 26)
]
start = datetime.date(2020, 1, 1)
weekDelta = datetime.timedelta(days=7)
dayDelta = datetime.timedelta(days=1)
while len(listaRichiestaAcquisto) != volumi['richiestaAcquisto']:
    if mediaRic == 0:
        targetSettimanale = random.randint(minRic, maxRic)
    elif (volumi['richiestaAcquisto'] - len(listaRichiestaAcquisto)) <= 70:
        targetSettimanale = volumi['richiestaAcquisto'] - len(listaRichiestaAcquisto)
    elif mediaRic < mediaTarget:
        targetSettimanale = random.randint(mediaTarget, maxRic)
    elif mediaRic > mediaTarget:
        targetSettimanale = random.randint(minRic, mediaTarget)
    else:
        targetSettimanale = random.randint(minRic, maxRic)

    if settimane != 1:
        mediaRic = int((mediaRic + targetSettimanale) / 2)
    else:
        mediaRic = targetSettimanale

    giorno = start.isoweekday()
    while giorno <= 5 and ricSetFatte < targetSettimanale:
        dayDelta = datetime.timedelta(days=giorno)
        if start + dayDelta not in noWorkDays:
            for dip in range(volumi['dipartimento']):
                if ricSetFatte >= targetSettimanale:
                    break
                if decision(probability_vector[dip]):
                    listaRichiestaAcquisto.append(getRichiestaAcquisto(listaDipartimento[dip]['Codice'], (start + dayDelta).strftime('%Y-%m-%d')))
                    probability_vector[dip] = probability_vector[dip] / 2
                    ricSetFatte += 1
        giorno += 1
    ricSetFatte = 0
    settimane += 1
    probability_vector = getProbabilityVector()

    if start == datetime.date(2020, 1, 1):
        start += datetime.timedelta(days=5)
    else:
        start += weekDelta

listaArticolo = []
for i in range(volumi['articolo']):
    listaArticolo.append(getArticolo(i+1))

listaFornitore = []
listaRecapitoTelefonico = []
for i in range(volumi['fornitore']):
    fornitore = getFornitore()
    listaFornitore.append(fornitore)
    listaRecapitoTelefonico.append(getRecapitoTelefonico(fornitore['PartitaIVA']))

listaFornisce = []
combinazioniForniture = [
    ['cancelleria', 'libri'],
    ['pulizia', 'mobilia'],
    ['elettronica'],
    ['informatica'],
    ['cancelleria', 'pulizia', 'libri', 'elettronica', 'informatica', 'mobilia']
]

while len(listaFornisce) < volumi['fornisce']:
    for articolo in listaArticolo:
        if not any(articolo['Codice'] == fornitura['Articolo'] for fornitura in listaFornisce):
            candidates = [index for index, comb in enumerate(combinazioniForniture) if articolo['Classe'] in comb]
            index = random.choice(candidates)
            listaFornisce.append(getFornisce(articolo['Codice'], articolo['Classe'], listaFornitore[index]['PartitaIVA']))
        else:
            for index, combinazione in enumerate(combinazioniForniture):
                if len(listaFornisce) >= volumi['fornisce']:
                    break
                if articolo['Classe'] in combinazione and random.random() < 0.5:
                    fornisce = getFornisce(articolo['Codice'], articolo['Classe'], listaFornitore[index]['PartitaIVA'])
                    if not any(fornisce['Articolo'] == fornitura['Articolo'] and fornisce['Fornitore'] == fornitura['Fornitore'] for fornitura in listaFornisce):
                        listaFornisce.append(fornisce)
# %%
ultimoNumeroRichiesta = {}
for dip in listaDipartimento:
    ultimoNumeroRichiesta[dip['Codice']] = 1

for i in range(len(listaRichiestaAcquisto)):
    dip = listaRichiestaAcquisto[i]['Dipartimento']
    listaRichiestaAcquisto[i]['Numero'] = ultimoNumeroRichiesta[dip]
    ultimoNumeroRichiesta[dip] += 1

listaInclude = []
for i in range(len(listaRichiestaAcquisto)):
    articoliDaOrdinare = random.sample(listaArticolo, 5)
    for articolo in articoliDaOrdinare:
        listaInclude.append(getInclude(listaRichiestaAcquisto[i]['Dipartimento'], listaRichiestaAcquisto[i]['Numero'], articolo['Codice']))

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

# %%
codiceOrdine = 1
listaOrdine = []

# Generate Ordine
# today = datetime.date.today()
# start = today - datetime.timedelta(days=280)
start = datetime.date(2020, 1, 1)

while start <= datetime.date(2020, 12, 31):
    if start == datetime.date(2020, 1, 1):
        orderDay = start + datetime.timedelta(days=5)
    else:
        orderDay = start + weekDelta
    while orderDay in noWorkDays:
        orderDay += dayDelta
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
            if articolo[0] == fornitura['Articolo']:
                if best_prezzoScontato == 0 or fornitura['PrezzoUnitario']*(1 - fornitura['Sconto'] * 0.01) < best_prezzoScontato:
                    best_fornitore = fornitura['Fornitore']
                    best_prezzoScontato = fornitura['PrezzoUnitario']*(1 - fornitura['Sconto'] * 0.01)
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
                for i in range(len(listaInclude)):
                    if listaInclude[i]['Dipartimento'] == articolo[2] and listaInclude[i]['NumeroRichiesta'] == articolo[3] and listaInclude[i]['Articolo'] == articolo[0]:
                        listaInclude[i]['Ordine'] = ordiniSettimanali[articolo[1]]
                        break

    if start == datetime.date(2020, 1, 1):
        start += datetime.timedelta(days=5)
    else:
        start += weekDelta

# %%
for entryInclude in listaInclude:
    try:
        ordine = entryInclude['Ordine']
    except KeyError:
        print(entryInclude)
        break

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
for tabella, listaEntry in tabelle.items():
    queries = []
    for entry in listaEntry:
        if tabella == 'Articolo':
            entry.pop('Codice')
        elif tabella == 'RichiestaAcquisto':
            entry.pop('Numero')
        elif tabella == 'Ordine':
            entry.pop('Codice')
        queries.append(querygenerator.build_from_json(tabella, entry))
    querygenerator.make_sql(tabella, queries)
