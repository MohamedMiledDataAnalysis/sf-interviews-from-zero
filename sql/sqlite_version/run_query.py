"""Runs every query in a .sql file (or one query typed in quotes) against ashcombe.db
and prints the results. Usage (from the companion folder):
    python sql/sqlite_version/run_query.py sql/sqlite_version/ch17_02_aggregates.sql
    python sql/sqlite_version/run_query.py "SELECT COUNT(*) FROM loan_tape"
Statements that fail are reported and the script continues; changes are saved."""
import os, re, sqlite3, sys
HERE = os.path.dirname(os.path.abspath(__file__))
if len(sys.argv) != 2:
    sys.exit('Usage: python sql/sqlite_version/run_query.py <file.sql or "SELECT ...">')
con = sqlite3.connect(os.path.join(HERE, 'ashcombe.db'))
con.create_function('POWER', 2, pow)  # in case this SQLite build lacks maths functions
con.execute('PRAGMA foreign_keys = ON')  # enforce foreign keys (Chapter 17, query 8.4)
arg = sys.argv[1]
if arg.endswith('.sql'):
    with open(arg, encoding='utf-8') as f:
        text = f.read()
else:
    text = arg
for stmt in [s.strip() for s in re.split(r';[ \t]*(?:\n|$)', text)]:
    lines = [l for l in stmt.splitlines() if not l.strip().startswith('--')]
    if not ''.join(lines).strip():
        continue
    title = [l for l in stmt.splitlines() if l.strip().startswith('--')]
    print('\n' + '\n'.join(title))
    try:
        cur = con.execute(stmt)
    except sqlite3.Error as e:
        print(f'ERROR: {e}')
        continue
    if cur.description:
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        widths = [max(len(str(c)), *(len(f'{r[i]}') for r in rows)) if rows else len(c) for i, c in enumerate(cols)]
        print('  '.join(c.ljust(w) for c, w in zip(cols, widths)))
        for r in rows[:30]:
            print('  '.join(f'{v}'.ljust(w) for v, w in zip(r, widths)))
        if len(rows) > 30:
            print(f'... {len(rows)} rows in total')

con.commit()
con.close()
