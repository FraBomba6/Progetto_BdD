MOCKUP := MockupDataGenerator

.PHONY : mockup db

mockup:
	@python3 ./$(MOCKUP)/script.py
	@echo "Mockup data built at folder $(MOCKUP)/sql"

db:
	@echo "Building database with mockup data insertion"
	@echo "Edit 'db_builder' file with your configuration parameters"
	@./db_builder
	@echo "Done"

