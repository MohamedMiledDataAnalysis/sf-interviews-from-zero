"""Checks every number that Chapters 0, 11, 18, 19 and 20 print from Python.
Run from the companion folder:  python -m pytest python"""
import os
import subprocess
import sys
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

import numpy as np
import pandas as pd
import pytest

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
DATA = ROOT / "data"
sys.path.insert(0, str(HERE))
from ch18_05_waterfall import run_waterfall            # noqa: E402
from ch18_08_cashflow_projection import project, wal   # noqa: E402

ALLOWED = ["East Midlands", "East of England", "London", "North East",
           "North West", "Scotland", "South East", "South West", "Wales",
           "West Midlands", "Yorkshire and the Humber"]
MAPPING = {name.lower(): name for name in ALLOWED}
MAPPING["greater london"] = "London"


def run(*args):
    """Run a companion script as a reader does; return stdout + stderr."""
    env = dict(os.environ, MPLBACKEND="Agg", PYTHONIOENCODING="utf-8")
    r = subprocess.run([sys.executable, *map(str, args)], cwd=ROOT, env=env,
                       capture_output=True, text=True, encoding="utf-8")
    assert r.returncode == 0, r.stderr
    return r.stdout + r.stderr


def pct(x, d=1):
    return f"{x:.{d}%}"


@pytest.fixture(scope="module")
def tape():
    t = pd.read_csv(DATA / "ashcombe_loan_tape.csv",
                    parse_dates=["origination_date", "maturity_date"])
    t["region_clean"] = t["region"].str.strip().str.lower().map(MAPPING)
    return t


@pytest.fixture(scope="module")
def hist():
    return pd.read_csv(DATA / "ashcombe_loan_history.csv", parse_dates=["month_end"])


@pytest.fixture(scope="module")
def m1():
    return run_waterfall(236_900_000, 203_300_000, 33_600_000, 2_400_000,
                         1_045_000, 2_880_000, 52_000)


def month2(m1, reserve, losses=260_000):
    return run_waterfall(m1["Closing pool"], m1["Closing Class A"], m1["Closing Class B"],
                         reserve, 1_038_000, 3_150_000, losses)


# Chapter 0 -----------------------------------------------------------------
def test_ch00_setup_check():
    out = run("python/00_check_setup.py")
    for line in ["Loans: 1,200", "Pool balance: £240,000,000", "Setup OK"]:
        assert line in out


def test_ch00_build_db():
    out = run("sql/sqlite_version/build_db.py")
    assert "Loans: 1,200  Balance: 240,000,000" in out


# Chapter 18, section 18.1 --------------------------------------------------
def test_18_1_just_enough_python():
    assert round(152661 * 0.05186 / 12, 2) == 659.75
    assert f"Loan ASH100001 owes £{152661:,.0f}" == "Loan ASH100001 owes £152,661"
    assert 200_000 * 0.045 / 12 == 750.0
    assert [x * x for x in range(4)] == [0, 1, 4, 9]
    assert f"{0.05444:.2%}  {240000000:,.0f}" == "5.44%  240,000,000"


# 18.2 -----------------------------------------------------------------------
def test_18_2_explore(tape):
    assert tape.drop(columns="region_clean").shape == (1200, 23)
    assert tape["loan_id"].iloc[0] == "ASH100001"
    d = tape["current_balance"].describe()
    assert round(d["mean"]) == 200_000 and d["max"] == 840_940
    assert tape["rate_type"].value_counts().to_dict() == {"Fixed": 853, "Tracker": 203, "SVR": 144}
    blanks = tape.drop(columns="region_clean").isna().sum()
    assert blanks[blanks > 0].to_dict() == {"indexed_valuation": 1}
    arrears3 = tape[tape["arrears_months"] >= 3]
    assert (len(arrears3), arrears3["current_balance"].sum()) == (24, 4_648_983)
    assert "24 loans 3+ months in arrears; balance £4,648,983" in run("python/ch18_01_explore.py")


# 18.3 -----------------------------------------------------------------------
def test_18_3_metrics_and_strat(tape):
    bal = tape["current_balance"]
    assert round((tape["interest_rate"] * bal).sum() / bal.sum(), 5) == 0.05444
    assert round((tape["original_ltv"] * bal).sum() / bal.sum(), 4) == 0.6919
    edges = [0, 0.5, 0.6, 0.7, 0.8, 0.9, 10]
    strat = (tape.groupby(pd.cut(tape["indexed_ltv"], bins=edges), observed=False)
                 .agg(loans=("loan_id", "size"), balance=("current_balance", "sum")))
    assert (strat["loans"].iloc[0], strat["balance"].iloc[0]) == (325, 63_960_160)
    pivot = pd.pivot_table(tape, values="current_balance", index="rate_type",
                           columns="repayment_type", aggfunc="sum",
                           margins=True, margins_name="Total")
    assert pivot.loc["Total", "Total"] == 240_000_000
    out = run("python/ch18_02_metrics_strats.py")
    assert "5.444%" in out and "Strat ties to the tape." in out


# 18.4 -----------------------------------------------------------------------
def test_18_4_data_quality():
    out = run("python/ch18_03_data_quality.py")
    expected = {"Duplicate loan_id": 2, "Missing indexed valuation": 1,
                "Stored indexed LTV differs by more than 0.5%": 1,
                "Interest rate outside 0.5% to 15%": 1,
                "Maturity not origination + term": 1, "Region not in allowed list": 3,
                "Repayment loan above original balance": 1, "Term does not add up": 0}
    for rule, n in expected.items():
        assert f"{rule:<48} {n:>3}" in out
    assert "10 exceptions written" in out


# 18.5 -----------------------------------------------------------------------
def test_18_5_reconciliation(tape):
    serv = pd.read_csv(DATA / "servicer_balances.csv")
    t = tape[["loan_id", "current_balance"]]
    s = serv[["loan_id", "current_balance"]]
    rec = t.merge(s, on="loan_id", how="outer", suffixes=("_tape", "_servicer"), indicator=True)
    rec["difference"] = rec["current_balance_tape"] - rec["current_balance_servicer"]
    exc = rec[(rec["_merge"] != "both") | (rec["difference"] != 0)].set_index("loan_id")
    assert exc["difference"].fillna(0).to_dict() == {
        "ASH100213": -207_390, "ASH100500": 1_250, "ASH100501": -1_250, "ASH100888": 0}
    assert exc.loc["ASH100888", "_merge"] == "right_only"
    with pytest.raises(pd.errors.MergeError):
        t.merge(s, on="loan_id", how="outer", validate="one_to_one")


# 18.6 and exercise 4 ----------------------------------------------------------
def test_18_6_waterfall_month2(m1):
    m2 = month2(m1, m1["Closing reserve"])
    assert m2["Excess spread"] == 39_877 and m2["Closing reserve"] == 2_163_148
    assert month2(m1, 0)["PDL outstanding"] == 220_123


def test_18_exercise4(m1):
    assert 39_877 + m1["Closing reserve"] == 2_423_148
    assert month2(m1, m1["Closing reserve"], 2_423_000)["Closing reserve"] == 148
    assert month2(m1, m1["Closing reserve"], 2_423_148)["Closing reserve"] == 0
    assert month2(m1, m1["Closing reserve"], 2_424_000)["Closing reserve"] == 0


# 18.7 -----------------------------------------------------------------------
def test_18_7_regions(tape):
    assert tape["region_clean"].notna().all()
    s = tape.groupby("region_clean")["current_balance"].sum()
    assert s["London"] == 39_409_228 and pct(s["London"] / s.sum()) == "16.4%"
    no_gl = tape["region"].str.strip().str.lower().map({n.lower(): n for n in ALLOWED})
    assert tape.groupby(no_gl)["current_balance"].sum().sum() == 239_706_414
    out = run("python/ch18_06_report_to_excel.py")
    assert "39409228" in out


# 18.8 -----------------------------------------------------------------------
def test_18_8_history(hist, tape):
    h = hist.sort_values(["loan_id", "month_end"]).copy()
    h["prev_balance"] = h.groupby("loan_id")["current_balance"].shift(1)
    m = h.dropna(subset=["prev_balance"])
    m = m.assign(redemptions=m["prev_balance"].where(m["status"] == "Redeemed", 0),
                 other_principal=(m["prev_balance"] - m["current_balance"])
                 .where(m["status"] == "Active", 0))
    cols = ["prev_balance", "redemptions", "other_principal", "current_balance"]
    s = m.groupby("month_end")[cols].sum()
    assert s.loc["2026-06-30"].tolist() == [242_582_325, 2_222_401, 359_924, 240_000_000]
    assert (s["prev_balance"] - s["redemptions"] - s["other_principal"]
            - s["current_balance"]).abs().max() < 0.5
    out = run("python/ch18_07_history_roll_rates.py")
    assert "31.8" in out and "40.9" in out
    with pytest.raises(ValueError, match="duplicate entries"):
        tape.pivot(index="loan_id", columns="rate_type", values="current_balance")


# 18.9 and exercise 8 ----------------------------------------------------------
def test_18_9_wal_table():
    book = {0.00: (12.28, 22.62, 3.28), 0.05: (7.43, 20.57, 2.22),
            0.10: (4.91, 17.19, 1.59), 0.15: (3.55, 13.83, 1.20),
            0.20: (2.73, 11.15, 0.94), 0.25: (2.19, 9.13, 0.76)}
    for cpr, row in book.items():
        cf = project(cpr=cpr)
        assert (round(wal(cf, "class_a_principal"), 2), round(wal(cf, "class_b_principal"), 2),
                round(cf["losses"].sum() / 1e6, 2)) == row


def test_18_9_price_and_yield():
    cf = project(cpr=0.10)
    bal_a = 206_400_000 - cf["class_a_principal"].cumsum().shift(fill_value=0)
    cash = cf["class_a_principal"] + bal_a * 0.045 / 12

    def price(y):
        return (cash / (1 + y / 12) ** cf["month"]).sum()

    lo, hi = 0.0, 0.20
    for _ in range(60):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if price(mid) > 206_400_000 else (lo, mid)
    assert f"{mid:.3%}" == "4.500%"
    assert pct(price(0.05) / 206_400_000, 2) == "97.95%"


def test_18_exercise8():
    wals = {round(0.10 + 0.005 * i, 3): wal(project(cpr=0.10 + 0.005 * i), "class_a_principal")
            for i in range(11)}
    best = min(wals, key=lambda c: abs(wals[c] - 4))
    assert best == 0.13 and round(wals[best], 3) == 4.006


# 18.10 ----------------------------------------------------------------------
def test_18_10_sql_and_logging():
    run("sql/sqlite_version/build_db.py")
    out = run("python/ch18_09_sql_and_logging.py")
    for text in ["INFO Loaded 1,200 loans, balance £240,000,000", "INFO Control total agreed",
                 "INFO Loan IDs unique", "INFO 3+ months arrears: 1.94% of the pool"]:
        assert text in out


# 18.11 ----------------------------------------------------------------------
def test_18_11_pool_cut(tape):
    criteria = {
        "Up to date": tape["arrears_months"] == 0,
        "Remaining term": tape["remaining_term_months"] <= 420,
        "No possession": tape["possession_flag"] == "N",
        "Seasoned": tape["seasoning_months"] >= 3,
        "Indexed LTV": tape["indexed_ltv"] <= 0.90,
        "Balance": tape["current_balance"] <= 750_000,
        "Owner-occupied": tape["occupancy"] == "Owner-occupied",
    }
    eligible = pd.concat(criteria, axis=1).all(axis=1)
    assert (eligible.sum(), tape.loc[eligible, "current_balance"].sum()) == (892, 175_064_566)


# 18.12 ----------------------------------------------------------------------
def test_18_12_read_excel():
    serv = pd.read_excel(ROOT / "excel" / "test2_blank.xlsx", sheet_name="Servicer",
                         dtype={"loan_id": str})
    assert len(serv) == 1200 and serv["current_balance"].sum() == 240_000_000
    sheets = pd.read_excel(ROOT / "excel" / "test2_blank.xlsx", sheet_name=None)
    assert list(sheets) == ["Answers", "Tape", "Servicer"]


def test_18_12_more_pandas(tape, hist):
    stage = np.select([tape["arrears_months"] >= 3, tape["arrears_months"] >= 1],
                      ["Stage 3", "Stage 2"], default="Stage 1")
    assert pd.Series(stage).value_counts().to_dict() == {"Stage 1": 1102, "Stage 2": 74, "Stage 3": 24}
    assert pct(tape["rate_type"].value_counts(normalize=True)["Fixed"]) == "71.1%"
    assert len(tape.drop_duplicates("loan_id")) == 1199
    by_region = tape.groupby("region_clean")["current_balance"]
    share = tape["current_balance"] / by_region.transform("sum")
    assert (share.groupby(tape["region_clean"]).sum() - 1).abs().max() < 1e-9
    monthly = hist[hist["status"] == "Active"].groupby("month_end")["current_balance"].sum()
    assert pct(monthly.pct_change().iloc[-1], 2) == "-1.06%"
    assert round((1 + monthly.pct_change().fillna(0)).cumprod().iloc[-1], 3) == 0.940


def test_18_12_vintage(tape, hist):
    h = hist.merge(tape[["loan_id", "origination_date"]].drop_duplicates("loan_id"), on="loan_id")
    h["vintage"] = h["origination_date"].astype(str).str[:4]
    act = h[h["status"] == "Active"]
    keys = ["vintage", "month_end"]
    late = act[act["arrears_months"] >= 3]
    curve = (late.groupby(keys)["current_balance"].sum()
             / act.groupby(keys)["current_balance"].sum()).fillna(0).unstack("month_end")
    june = curve[pd.Timestamp("2026-06-30")]
    assert pct(june["2016"], 2) == "6.80%" and pct(june["2025"], 2) == "1.24%"


def test_18_12_dates():
    days = pd.date_range("2026-07-31", periods=12, freq="ME").to_series().diff().dt.days
    assert days.iloc[1:].tolist() == [31, 30, 31, 30, 31, 31, 28, 31, 30, 31, 30]
    if int(pd.__version__.split(".")[0]) >= 3:
        with pytest.raises(ValueError):
            pd.date_range("2026-07-31", periods=2, freq="M")


def test_18_mistakes_rounding():
    assert (round(2.5), round(3.5)) == (2, 4)
    assert Decimal("2.5").quantize(Decimal("1"), rounding=ROUND_HALF_UP) == 3


# 18.13 practice answers --------------------------------------------------------
def test_18_practice(tape, hist, tmp_path):
    x = pd.crosstab(tape["occupancy"], tape["repayment_type"])
    assert x.loc["Buy-to-let"].tolist() == [183, 0, 33]
    assert x.loc["Owner-occupied"].tolist() == [62, 64, 858]
    g = (tape.assign(w=tape["indexed_ltv"] * tape["current_balance"])
             .groupby("region_clean")[["w", "current_balance"]].sum())
    ltv = (g["w"] / g["current_balance"]).sort_values(ascending=False)
    assert (ltv.index[0], pct(ltv.iloc[0])) == ("East of England", "62.4%")
    assert (ltv.index[-1], pct(ltv.iloc[-1])) == ("North East", "56.2%")
    late = tape[tape["arrears_months"] >= 3].groupby("region_clean")["current_balance"].sum()
    assert late.nlargest(5).to_dict() == {"North West": 1_049_319, "London": 784_026,
                                          "West Midlands": 638_866, "Scotland": 483_699,
                                          "South East": 457_367}
    ratio = tape["monthly_payment"] * 12 / tape["borrower_income"]
    assert (ratio > 0.30).sum() == 190 and pct(ratio.median()) == "24.7%"
    wide = hist[hist["status"] == "Active"].pivot(index="loan_id", columns="month_end",
                                                  values="current_balance")
    both = wide[["2026-05-31", "2026-06-30"]].dropna()
    assert (both["2026-05-31"] == both["2026-06-30"]).sum() == 293
    h = hist.sort_values(["loan_id", "month_end"]).copy()
    h["prev"] = h.groupby("loan_id")["current_balance"].shift(1)
    h = h.dropna(subset=["prev"])
    h = h.assign(red=h["prev"].where(h["status"] == "Redeemed", 0))
    gm = h.groupby("month_end")[["red", "prev"]].sum()
    cpr = 1 - (1 - gm["red"] / gm["prev"]) ** 12
    assert [pct(v) for v in cpr] == ["14.7%", "11.7%", "12.8%", "11.5%", "10.5%"]
    run("python/ch18_03_data_quality.py")
    exceptions = pd.read_csv(HERE / "output" / "dq_exceptions.csv")
    with pd.ExcelWriter(tmp_path / "dq_by_rule.xlsx") as xl:
        for i, (rule, group) in enumerate(exceptions.groupby("rule_failed"), start=1):
            group.to_excel(xl, sheet_name=f"Rule {i}", index=False)
    assert len(pd.read_excel(tmp_path / "dq_by_rule.xlsx", sheet_name=None)) == 7


# 18.17 corrections -------------------------------------------------------------
def test_18_corrections(tape, hist):
    edges = [0, 100_000, 200_000, 300_000, 500_000, 10_000_000]
    s = tape.groupby(pd.cut(tape["current_balance"], bins=edges), observed=False)["current_balance"]
    assert (s.size().sum(), s.sum().sum()) == (1200, 240_000_000)
    top = tape.sort_values("current_balance", ascending=False).head(10)
    assert pct(top["current_balance"].cumsum().iloc[-1] / tape["current_balance"].sum(), 2) == "2.67%"
    fixed = tape.copy()
    fixed.loc[fixed["loan_id"] == "ASH100602", "interest_rate"] = 0.0537
    bal = fixed["current_balance"]
    assert pct((fixed["interest_rate"] * bal).sum() / bal.sum(), 3) == "5.400%"
    a = hist[hist["status"] == "Active"]
    a = a.assign(b3=a["current_balance"].where(a["arrears_months"] >= 3, 0))
    g = a.groupby("month_end")[["b3", "current_balance"]].sum()
    r = g["b3"] / g["current_balance"]
    assert (pct(r["2026-05-31"], 2), pct(r["2026-06-30"], 2)) == ("1.47%", "1.94%")


# Chapter 11 --------------------------------------------------------------------
def test_ch11_stress_table():
    lines = run("python/ch11_stress_12_months.py").splitlines()[1:]
    rows = {int(l.split()[0]): [int(v.replace(",", "")) for v in l.split()[1:]] for l in lines}
    book = {1: (576_395, 21_761, 1_608_514, 0, 194.71), 2: (570_774, 20_846, 1_058_586, 0, 192.48),
            3: (565_207, 19_940, 513_319, 0, 190.28), 4: (559_695, 19_043, 0, 27_333, 188.12),
            6: (548_831, 15_164, 0, 1_097_183, 184.89), 9: (532_930, 6_601, 0, 2_683_441, 180.18),
            12: (517_489, -1_806, 0, 4_246_489, 175.62)}
    for month, (loss, es, reserve, pdl, class_a_m) in book.items():
        got = rows[month]
        assert got[:4] == [loss, es, reserve, pdl] and round(got[4] / 1e6, 2) == class_a_m


# Chapters 19 and 20 ------------------------------------------------------------
def test_ch19_e4_calder():
    kw = dict(expenses=25_000, fee_rate=0.003, coupon_a=0.0475, coupon_b=0.065,
              reserve_required=1_500_000)
    r1 = run_waterfall(150_000_000, 129_000_000, 21_000_000, 1_500_000,
                       720_000, 1_700_000, 90_000, **kw)
    assert (r1["Excess spread"], r1["Closing reserve"], r1["Closing Class A"]) == \
        (33_125, 1_443_125, 127_210_000)
    r2 = run_waterfall(r1["Closing pool"], r1["Closing Class A"], r1["Closing Class B"],
                       r1["Closing reserve"], 640_000, 1_865_000, 1_600_000, **kw)
    assert (r2["2 Servicing fee"], r2["PDL outstanding"]) == (37_052, 196_217)


def test_ch20_q7(tape):
    serv = pd.read_csv(DATA / "servicer_balances.csv")
    missing = serv[~serv["loan_id"].isin(tape["loan_id"])]
    assert missing[["loan_id", "current_balance"]].values.tolist() == [["ASH100888", 73_590]]


# Regression guards ---------------------------------------------------------------
@pytest.mark.parametrize("script", ["00_check_setup.py"] + sorted(p.name for p in HERE.glob("ch*.py")))
def test_scripts_run_with_a_notebook_stream(script, monkeypatch):
    """A Jupyter kernel's sys.stdout has no reconfigure(); every script must still run."""
    import io
    import runpy
    if script.startswith("ch18_09"):
        run("sql/sqlite_version/build_db.py")
    monkeypatch.chdir(ROOT)
    monkeypatch.setattr(sys, "stdout", io.StringIO())
    runpy.run_path(str(HERE / script), run_name="__main__")


def test_sqlite_route_totals():
    run("sql/sqlite_version/build_db.py")
    out = run("sql/sqlite_version/run_query.py",
              "SELECT COUNT(*) AS n, SUM(current_balance) AS b FROM loan_tape")
    assert "1200" in out and "240000000" in out
