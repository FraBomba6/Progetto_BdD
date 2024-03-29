# Database Project - Purchasing Department of a Public Authority 

This repository contains the work developed by Francesco Bombassei De Bona, Andrea Cantarutti, Lorenzo Bellina and Alessandro Fabris for the Database course at the [University of Udine](https://www.uniud.it/it), held by [Angelo Montanari](https://users.dimi.uniud.it/~angelo.montanari/index.php) and [Dario Della Monica](https://users.dimi.uniud.it/~dario.dellamonica/). 

The aim of the project was **designing** and **implementing** a [Relational database](https://en.wikipedia.org/wiki/Relational_database) for a specific domain of interest, according to a given set of requirements.

## Repository Structure

### Complete Report

A detailed report, written in Italian and based on the following points:

- Requirements Analysis
- Conceptual Design
- Logical Design
- Physical Design
- Implementation
- Usage
- Queries
- Data Analysis

can be found at the path `report/report.pdf`.

### Diagrams

The ER and Logical diagrams can be found inside the `ER` directory as `.png` and `.drawio` files.

### Data and Index Analysis

Both the **indexes evalutation** and the **mockup data analysis** were written in the [R Language](https://www.r-project.org/) and can be found inside the `R` directory, together with the plots produced and all the `.csv` files.

### Implementation

The **implementation** and **mockup data generation** files can be found at the `psqlOnDocker` directory. We decided to use [PostgreSQL](https://www.postgresql.org/) as our [DBMS](https://it.wikipedia.org/wiki/Database_management_system).

## Database generation

In order to analyse or test our work, you can:

1. **Locate inside psqlOnDocker folder**

```bash

cd psqlOnDocker/

```

2. **Run the docker container and wait for its initialisation**

```docker

# Add -d flag to run in detach mode
docker compose up

``` 

3. **Run the database creation script**

```bash

make db

```

You can, then, access the database as root using the following credentials:

| **Variable**  | **Value**   |
|---------------|-------------|
|  Address      | `localhost` |
|  Port         | `15000`     |
|  User         | `postgres`  |
|  Password     | `bdd2021`   |

or by typing

```bash
psql -U postgres -h localhost -p 15000
```

Keep in mind that you'll have to install:

- [Docker](https://docs.docker.com/get-docker/)
- [PosgtreSQL](https://www.postgresql.org/download/)

## Logical diagram

If you want to interact with the database once created, here's the actual **Logical Diagram** in order to help you structuring your queries. 

<img src="./ER/Logical_bg.png" width="75%" align="center"/>

## How to examine the SQL code that creates the database

If you want to take a closer look to the actual SQL code that creates all the tables, types, triggers, functions and indexes, you can head over to the `psqlOnDocker/create_db.sql` file.

## Generate new mockup data

If you want to re-generate the mockup data, you can:

1. **Locate inside psqlOnDocker folder**

```bash

cd psqlOnDocker/

```

2. **Run the MockupDataGenerator script**

```bash

make mockup

```

The SQL files generated will **overwrite** the ones actually located inside the `psqlOnDocker/sql` folder. Keep also in mind that you'll have to install [Python](https://www.python.org/downloads/) with [pip](https://pypi.org/project/pip/) and the [Faker Library](https://pypi.org/project/Faker/) (by running `pip3 install Faker`).

## Data Analysis

Mockup data had been analysed inside a [RMarkdown](https://rmarkdown.rstudio.com/) notebook which can be found at `R/DataAnalysis.Rmd`. Moreover, all the plots were also exported as `.png` files inside the directory `R/analysisPlots`.

Another analysis was performed in order to evaluate the usage of specific [Database indexes](https://en.wikipedia.org/wiki/Database_index). The code can be found at the path `R/IndexEval.R`. All the data (as a collection of `.csv` files) and all the plots were exported respectively to the `R/csv` and the `R/plots` folders. 

