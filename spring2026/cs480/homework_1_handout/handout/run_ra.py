import sys
from radb import parse
from radb.db import DB

# usage: python run_ra.py q1.1.1.ra
ra_file = sys.argv[1]

db = DB.connect("postgresql://postgres:gobaxter1@localhost:5432/homework1")

with open(ra_file) as f:
    ra = f.read()

tree = parse.one_statement_from_string(ra)
result = db.eval(tree)

for row in result:
    print(row)
