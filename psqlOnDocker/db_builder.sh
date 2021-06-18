DB_CREATION=create_db.sql
MOCKUP_DATA=MockupDataGenerator/sql/
DATABASE=ufficioacquisti
PGPASSWORD='bdd2021'

echo "Creating db"
createdb -U postgres -h localhost -p 15000 $DATABASE

echo "Building relations..."
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$DB_CREATION"

echo "Mockup data insertion..."
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Responsabile.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Dipartimento.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Articolo.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Fornitore.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/RecapitoTelefonico.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Fornisce.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/RichiestaAcquisto.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Ordine.sql"
psql -U postgres -h localhost -p 15000 -d $DATABASE -f "$MOCKUP_DATA/Include.sql"

