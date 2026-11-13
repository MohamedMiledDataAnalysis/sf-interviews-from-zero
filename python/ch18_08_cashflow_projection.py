"""Chapter 18, section 18.9: project the pool and the notes under CPR, CDR and severity,
and build a WAL table for Class A."""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")
import pandas as pd


def project(pool=240_000_000, rate=0.054, months_left=284, cpr=0.10, cdr=0.005,
            severity=0.20, class_a=206_400_000, class_b=33_600_000, max_months=600):
    """Monthly projection. Scheduled principal from a level-payment schedule;
    prepayments and defaults at constant annual rates; losses = defaults x severity.
    Principal and recoveries repay Class A then Class B (sequential).
    Losses are assumed to be covered by excess spread (no PDL), to keep it simple."""
    smm = 1 - (1 - cpr) ** (1 / 12)
    mdr = 1 - (1 - cdr) ** (1 / 12)
    r = rate / 12
    rows = []
    bal, a, b = pool, class_a, class_b
    for t in range(1, max_months + 1):
        if bal < 1 or months_left <= 0:
            break
        payment = bal * r / (1 - (1 + r) ** -months_left)
        scheduled = payment - bal * r
        defaults = (bal - scheduled) * mdr
        prepay = (bal - scheduled - defaults) * smm
        loss = defaults * severity
        principal = scheduled + prepay + defaults        # recoveries + loss covered from revenue
        to_a = min(principal, a)
        to_b = min(principal - to_a, b)
        rows.append({"month": t, "opening_pool": bal, "scheduled": scheduled, "prepayments": prepay,
                     "defaults": defaults, "losses": loss, "class_a_principal": to_a,
                     "class_b_principal": to_b})
        bal -= scheduled + prepay + defaults
        a -= to_a
        b -= to_b
        months_left -= 1
    return pd.DataFrame(rows)


def wal(cashflows, column):
    """Weighted average life in years of a principal column."""
    return (cashflows[column] * cashflows["month"] / 12).sum() / cashflows[column].sum()


if __name__ == "__main__":
    base = project()
    print(base.head(3).round(0).to_string(index=False))
    print(f"\nClass A WAL at 10% CPR: {wal(base, 'class_a_principal'):.2f} years")
    print(f"Class A repaid in month {int(base.loc[base['class_a_principal'] > 0, 'month'].max())}\n")

    table = []
    for cpr in [0.0, 0.05, 0.10, 0.15, 0.20, 0.25]:
        cf = project(cpr=cpr)
        table.append({"CPR": f"{cpr:.0%}", "Class A WAL (years)": round(wal(cf, "class_a_principal"), 2),
                      "Class B WAL (years)": round(wal(cf, "class_b_principal"), 2),
                      "Lifetime losses (£m)": round(cf["losses"].sum() / 1e6, 2)})
    print(pd.DataFrame(table).to_string(index=False))
