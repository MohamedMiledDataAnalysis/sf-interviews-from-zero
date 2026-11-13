"""Builds ashcombe.db (SQLite) from the companion CSV files.
Run from the companion folder:  python sql/sqlite_version/build_db.py"""
import csv, os, sqlite3
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', '..', 'data')
DB = os.path.join(HERE, 'ashcombe.db')
if os.path.exists(DB):
    os.remove(DB)
con = sqlite3.connect(DB)
with open(os.path.join(HERE, '00_setup_sqlite.sql'), encoding='utf-8') as f:
    con.executescript(f.read())

def load(table, filename):
    with open(os.path.join(DATA, filename), newline='', encoding='utf-8') as f:
        rows = list(csv.reader(f))
    header, body = rows[0], rows[1:]
    body = [[None if v == '' else v for v in r] for r in body]
    marks = ','.join('?' * len(header))
    con.executemany(f'INSERT INTO {table} ({",".join(header)}) VALUES ({marks})', body)

load('loan_tape', 'ashcombe_loan_tape.csv')
load('servicer_balances', 'servicer_balances.csv')
load('periods', 'ashcombe_periods.csv')
load('loan_history', 'ashcombe_loan_history.csv')
con.commit()
n, bal = con.execute('SELECT COUNT(*), SUM(current_balance) FROM loan_tape').fetchone()
print(f'Loans: {n:,}  Balance: {bal:,.0f}')
print('Database created:', DB)
con.close()
