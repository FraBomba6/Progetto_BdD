import os


def build(table, **kwargs):
    keys = ','.join(kwargs.keys())
    values = ','.join(kwargs.values())
    return f"INSERT INTO {table}({keys}) VALUES ({values});\n"


def build_from_json(table, json):
    keys = ','.join(json.keys())
    values = ','.join([str(x) if not isinstance(x, str) else "\'"+x+"\'"for x in json.values()])
    return f"INSERT INTO {table}({keys}) VALUES ({values});\n"


def make_sql(table, queries):
    if not os.path.exists('sql'):
        os.mkdir('sql')
    with open(f"sql/{table}.sql", "w") as f:
        f.writelines(queries)
    print(f"Queries saved on file sql/{table}.sql")


def load_sql(table, fileName):
    with open(f"sql/{fileName}", "r") as f:
        query = f.readline()

