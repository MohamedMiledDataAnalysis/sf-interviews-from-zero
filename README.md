# Structured Finance Interviews from Zero: companion files

The data, workbooks and scripts for the book *Structured Finance Interviews from Zero: A Step-by-Step Guide for Analyst and Data Roles* by Mohamed Miled.

All deals, loans and people in these files are fictional. The loan tape contains deliberate data errors for practice (Chapter 15 and Practice test 2).

## Getting started

Chapter 0 of the book walks through every step. In short:

1. Download this repository (green **Code** button → **Download ZIP**) and extract it, or `git clone` it.
2. Open `excel/ch16_excel_workbook.xlsx` and check that `=SUM(Tape!H2:H1201)` gives 240,000,000.
3. SQL Server 2017 or later: copy the four CSV files from `data/` (all except `ashcombe_deal_inputs.csv`) to `C:\temp\` and run `sql/00_setup.sql`. No SQL Server? Run `python sql/sqlite_version/build_db.py` instead.
4. Python 3.12 or later: from this folder, `python -m venv .venv`, switch it on (`.venv\Scripts\activate` on Windows, `source .venv/bin/activate` on macOS), then `python -m pip install -r requirements.txt` and `python python/00_check_setup.py`. It should print **Setup OK**. Tested with pandas 2.2 to 3.1.

## What is inside

| Folder | Files | Book chapters |
|---|---|---|
| `data/` | `ashcombe_loan_tape.csv` (1,200 loans), `servicer_balances.csv`, `ashcombe_loan_history.csv` (7,426 rows), `ashcombe_periods.csv`, `ashcombe_deal_inputs.csv` | 9–20 |
| `excel/` | `ch16_excel_workbook.xlsx`; `test1_blank.xlsx` and `test1_solution.xlsx`; `test2_blank.xlsx` and `test2_solution.xlsx` | 16, 19, 20 |
| `sql/` | `00_setup.sql`; `ch17_01` to `ch17_10` query scripts (SQL Server) | 0, 17 |
| `sql/sqlite_version/` | The same queries for SQLite; `build_db.py` and `run_query.py` | 0, 17 |
| `python/` | `00_check_setup.py`; `ch18_01` to `ch18_09` scripts; `ch11_stress_12_months.py` | 0, 11, 18 |

Do not open the solution workbooks before you have tried the tests.

## Running the SQLite version

```
python sql/sqlite_version/build_db.py
python sql/sqlite_version/run_query.py sql/sqlite_version/ch17_02_aggregates.sql
python sql/sqlite_version/run_query.py "SELECT COUNT(*) FROM loan_tape"
```

## Tested on SQL Server

Every SQL Server script in `sql/` runs on SQL Server 2025 each time this repository changes. The workflow `.github/workflows/run-sql.yml` starts SQL Server in Docker, builds the `ashcombe` database from `data/`, runs `00_setup.sql` and each `ch17_*.sql` script on a fresh database, then runs `tests/checks.sql`, which compares the results with the numbers printed in the book. The report appears on the run's summary page in the **Actions** tab.

`ch17_08_keys_indexes.sql` fails twice on purpose (queries 8.1 and 8.4); `tests/expected_messages.txt` lists those error numbers so the run does not count them.

To run the same test on your own computer (Docker required): `bash tests/run_all.sh`

## Corrections

If you find an error, please open an issue on this repository. Corrections are listed here as they are made.
