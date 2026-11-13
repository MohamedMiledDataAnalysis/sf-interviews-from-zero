"""Chapter 18, section 18.6: the Ashcombe revenue and principal waterfall as a function."""
import sys
if hasattr(sys.stdout, "reconfigure"):  # consoles only; notebooks print £ already
    sys.stdout.reconfigure(errors="replace")


def run_waterfall(pool, class_a, class_b, reserve, revenue, principal, losses,
                  expenses=30_000, fee_rate=0.0025, coupon_a=0.045, coupon_b=0.06,
                  reserve_required=2_400_000, pdl_open=0):
    """One period of the Ashcombe waterfall. Returns a dict of results.
    pdl_open is any PDL left uncleared from earlier periods."""
    cash = revenue + reserve                       # available revenue
    paid, dues = {}, {}

    def pay(item, due):
        nonlocal cash
        amount = min(due, cash)                    # pay what is due, up to what is left
        cash -= amount
        paid[item] = amount
        dues[item] = due
        return amount

    to_debit = losses + pdl_open
    pdl_b = min(to_debit, class_b)                 # losses hit Class B first
    pdl_a = max(0, to_debit - class_b)

    pay("1 Senior expenses", expenses)
    pay("2 Servicing fee", round(pool * fee_rate / 12))
    pay("3 Class A interest", round(class_a * coupon_a / 12))
    pay("4 Class A PDL", pdl_a)
    pay("5 Class B interest", round(class_b * coupon_b / 12))
    pay("6 Class B PDL", pdl_b)
    pay("7 Reserve fund", reserve_required)
    pay("8 Residual", cash)

    available_principal = principal + paid["4 Class A PDL"] + paid["6 Class B PDL"]
    to_a = min(available_principal, class_a)
    to_b = min(available_principal - to_a, class_b)

    result = {
        **paid,
        "Excess spread": revenue - sum(dues[k] for k in
                                       ["1 Senior expenses", "2 Servicing fee",
                                        "3 Class A interest", "5 Class B interest"]),
        "Class A principal": to_a,
        "Class B principal": to_b,
        "Closing pool": pool - principal - losses,
        "Closing Class A": class_a - to_a,
        "Closing Class B": class_b - to_b,
        "Closing reserve": paid["7 Reserve fund"],
        "PDL outstanding": losses + pdl_open - paid["4 Class A PDL"] - paid["6 Class B PDL"],
    }
    # The reconciliation check of Chapter 9
    notes = result["Closing Class A"] + result["Closing Class B"]
    assert notes - result["Closing pool"] == result["PDL outstanding"], "Notes do not reconcile"
    return result


if __name__ == "__main__":
    m1 = run_waterfall(236_900_000, 203_300_000, 33_600_000, 2_400_000, 1_045_000, 2_880_000, 52_000)
    m2 = run_waterfall(m1["Closing pool"], m1["Closing Class A"], m1["Closing Class B"],
                       m1["Closing reserve"], 1_038_000, 3_150_000, 260_000)
    no_res = run_waterfall(m1["Closing pool"], m1["Closing Class A"], m1["Closing Class B"],
                           0, 1_038_000, 3_150_000, 260_000)
    for name, r in [("Month 1", m1), ("Month 2", m2), ("Month 2, no reserve", no_res)]:
        print(f"\n{name}")
        for k, v in r.items():
            print(f"  {k:<22} {v:>14,.0f}")
