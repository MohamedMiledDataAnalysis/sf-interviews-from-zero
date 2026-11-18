"""Structured Finance Interviews from Zero: every Python script printed in the solutions,
in the book's order, one function per exercise or question.
Generated from the book: do not edit. Run from the repository root:
    python python/ch18_11_solutions.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def solution_01():
    '''Chapter 9, Exercise 1: month 1 with less revenue'''
    import sys
    sys.path.append("python")   # notebook only
    from ch18_05_waterfall import run_waterfall

    r = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                      2_400_000, 1_000_000, 2_880_000, 52_000)
    print(r["Excess spread"], r["Closing reserve"],
          r["Closing Class A"])


def solution_02():
    '''Chapter 10, Exercise 2: SMM and CPR'''
    smm = 1_500_000 / (200_000_000 - 500_000)
    cpr = 1 - (1 - smm) ** 12
    print(f"SMM {smm:.3%}  CPR {cpr:.1%}")


def solution_03():
    '''Chapter 14, Exercise 1: the checks that catch a loss not debited to the PDL'''
    import sys
    sys.path.append("python")   # notebook only
    from ch18_05_waterfall import run_waterfall

    m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                       2_400_000, 1_045_000, 2_880_000, 52_000)

    args = (m1["Closing pool"], m1["Closing Class A"],
            m1["Closing Class B"], m1["Closing reserve"],
            1_038_000, 3_150_000)
    ok = run_waterfall(*args, 260_000)
    bad = run_waterfall(*args, 0)


def solution_04():
    '''Chapter 15, Exercise 1: a stored LTV that does not match'''
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    recalc = tape["current_balance"] / tape["indexed_valuation"]
    diff = (tape["indexed_ltv"] - recalc).abs()

    fails = tape[diff > 0.005]
    print(fails[["loan_id", "current_balance",
                 "indexed_valuation", "indexed_ltv"]])
    print(tape["indexed_valuation"].isna().sum())


def solution_05():
    '''Chapter 18, Exercise 1: WA interest rate by rate type'''
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")

    g = (tape.assign(w=tape["interest_rate"] * tape["current_balance"])
             .groupby("rate_type")[["w", "current_balance"]]
             .sum())

    wa = g["w"] / g["current_balance"]
    print(wa.map("{:.3%}".format))

    print(g["w"].sum() / g["current_balance"].sum())


def solution_06():
    '''Chapter 18, Exercise 2: a balance-size strat with pd.cut'''
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    edges = [0, 100_000, 200_000, 300_000, 500_000, 10_000_000]
    labels = ["£100k or less", ">£100k to £200k", ">£200k to £300k",
              ">£300k to £500k", "Over £500k"]

    tape["size_bucket"] = pd.cut(tape["current_balance"],
                                 bins=edges, labels=labels)

    size = (tape.groupby("size_bucket", observed=False)
                .agg(loans=("loan_id", "size"),
                     balance=("current_balance", "sum")))
    size["pct_of_pool"] = size["balance"] / size["balance"].sum()

    assert size["loans"].sum() == len(tape)
    assert size["balance"].sum() == tape["current_balance"].sum()
    print(size)


def solution_07():
    '''Chapter 18, Exercise 3: validate="one_to_one"'''
    # the files the solution assumes are already loaded
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    serv = pd.read_csv("data/servicer_balances.csv")

    try:  # the book shows that this raises pandas.errors.MergeError
        rec = tape[["loan_id", "current_balance"]].merge(
            serv[["loan_id", "current_balance"]], on="loan_id",
            how="outer", suffixes=("_tape", "_servicer"),
            indicator=True, validate="one_to_one")
    except pd.errors.MergeError as e:
        print("Raises", type(e).__name__ + ":", e)

    dups = tape[tape["loan_id"].duplicated(keep=False)]
    print(dups[["loan_id", "origination_date",
                "current_balance"]])


def solution_08():
    '''Chapter 18, Exercise 4: the smallest month 2 loss that empties the reserve'''
    import sys
    sys.path.append("python")   # notebook only
    from ch18_05_waterfall import run_waterfall

    m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000,
                       2_400_000, 1_045_000, 2_880_000, 52_000)

    def month2(losses):
        return run_waterfall(m1["Closing pool"], m1["Closing Class A"],
                             m1["Closing Class B"], m1["Closing reserve"],
                             1_038_000, 3_150_000, losses)

    loss = 260_000
    while month2(loss)["Closing reserve"] > 0:
        loss += 1_000
    print(loss, month2(loss - 1_000)["Closing reserve"])


def solution_09():
    '''Chapter 18, Exercise 5: the ten largest loans with cumulative share'''
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    cols = ["loan_id", "region", "current_balance"]
    top = (tape.sort_values("current_balance", ascending=False)
               .head(10)[cols])

    total = tape["current_balance"].sum()
    top["cum_pct"] = top["current_balance"].cumsum() / total
    print(top)


def solution_10():
    '''Chapter 18, Exercise 6: correct the 53.7% rate'''
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    fixed = tape.copy()

    row = fixed["loan_id"] == "ASH100602"
    print(fixed.loc[row, "interest_rate"])
    fixed.loc[row, "interest_rate"] = 0.0537

    def wa_rate(df):
        bal = df["current_balance"]
        return (df["interest_rate"] * bal).sum() / bal.sum()

    print(f"before {wa_rate(tape):.3%}  after {wa_rate(fixed):.3%}")


def solution_11():
    '''Chapter 18, Exercise 7: 3+ months arrears by month'''
    import pandas as pd
    hist = pd.read_csv("data/ashcombe_loan_history.csv")
    a = hist[hist["status"] == "Active"]

    late = a["arrears_months"] >= 3
    a = a.assign(b3=a["current_balance"].where(late, 0))

    g = a.groupby("month_end")[["b3", "current_balance"]].sum()
    pct = g["b3"] / g["current_balance"]
    print(pct.map("{:.2%}".format))


def solution_12():
    '''Chapter 18, Exercise 8: the CPR for a 4-year WAL'''
    import sys
    sys.path.append("python")   # notebook only
    from ch18_08_cashflow_projection import project, wal

    for cpr in [0.10 + 0.005 * i for i in range(11)]:
        cf = project(cpr=cpr)
        print(f"{cpr:.1%}", round(wal(cf, "class_a_principal"), 3))

    lo, hi = 0.10, 0.20
    for _ in range(40):
        mid = (lo + hi) / 2
        if wal(project(cpr=mid), "class_a_principal") > 4:
            lo = mid
        else:
            hi = mid
    print(f"{mid:.2%}")


def solution_13():
    '''Chapter 19, E4: month 1 in Python'''
    import sys
    sys.path.append("python")   # notebook only
    from ch18_05_waterfall import run_waterfall

    r = run_waterfall(150_000_000, 129_000_000, 21_000_000,
                      1_500_000, 720_000, 1_700_000, 90_000,
                      expenses=25_000, fee_rate=0.003,
                      coupon_a=0.0475, coupon_b=0.065,
                      reserve_required=1_500_000)


def solution_14():
    '''Chapter 20, Question 7: code'''
    # the files the solution assumes are already loaded
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    serv = pd.read_csv("data/servicer_balances.csv")

    missing = serv[~serv["loan_id"].isin(tape["loan_id"])]


def solution_15():
    '''Chapter 20, E3: the reconciliation in pandas'''
    # the files the solution assumes are already loaded
    import pandas as pd
    tape = pd.read_csv("data/ashcombe_loan_tape.csv")
    serv = pd.read_csv("data/servicer_balances.csv")

    rec = tape[["loan_id", "current_balance"]].merge(
        serv[["loan_id", "current_balance"]],
        on="loan_id", how="outer",
        suffixes=("_tape", "_servicer"), indicator=True)
    rec["difference"] = (rec["current_balance_tape"]
                         - rec["current_balance_servicer"])
    print(rec[(rec["_merge"] != "both")
              | (rec["difference"] != 0)])


if __name__ == "__main__":
    print('\n===== Chapter 9, Exercise 1: month 1 with less revenue')
    solution_01()
    print('\n===== Chapter 10, Exercise 2: SMM and CPR')
    solution_02()
    print('\n===== Chapter 14, Exercise 1: the checks that catch a loss not debited to the PDL')
    solution_03()
    print('\n===== Chapter 15, Exercise 1: a stored LTV that does not match')
    solution_04()
    print('\n===== Chapter 18, Exercise 1: WA interest rate by rate type')
    solution_05()
    print('\n===== Chapter 18, Exercise 2: a balance-size strat with pd.cut')
    solution_06()
    print('\n===== Chapter 18, Exercise 3: validate="one_to_one"')
    solution_07()
    print('\n===== Chapter 18, Exercise 4: the smallest month 2 loss that empties the reserve')
    solution_08()
    print('\n===== Chapter 18, Exercise 5: the ten largest loans with cumulative share')
    solution_09()
    print('\n===== Chapter 18, Exercise 6: correct the 53.7% rate')
    solution_10()
    print('\n===== Chapter 18, Exercise 7: 3+ months arrears by month')
    solution_11()
    print('\n===== Chapter 18, Exercise 8: the CPR for a 4-year WAL')
    solution_12()
    print('\n===== Chapter 19, E4: month 1 in Python')
    solution_13()
    print('\n===== Chapter 20, Question 7: code')
    solution_14()
    print('\n===== Chapter 20, E3: the reconciliation in pandas')
    solution_15()
