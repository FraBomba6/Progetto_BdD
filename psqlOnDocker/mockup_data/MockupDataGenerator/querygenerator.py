import os

def build(table, **kwargs):
    keys = ','.join(kwargs.keys())
    values = ','.join(kwargs.values())
    return f"INSERT INTO {table}({keys}) VALUES ({values})"

def make_sql(table, queries):
    if not os.path.exists('sql'):
        os.mkdir('sql')
    with open(f"sql/{table}.sql", "a") as f:
        f.writelines(queries)
    print(f"Queries saved on file sql/{table}.sql")
