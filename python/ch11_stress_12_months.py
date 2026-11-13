"""Chapter 11: a twelve-month stress of Ashcombe from its October 2026 position,
running the Chapter 18 waterfall function month by month."""
import sys
sys.stdout.reconfigure(errors="replace")  # print £ safely on any console
from ch18_05_waterfall import run_waterfall

pool, a, b, reserve, pdl = 230_558_000, 196_958_000, 33_600_000, 2_163_148, 0
print(f"{'Month':>5} {'Losses':>10} {'Excess spread':>14} {'Reserve':>11} {'PDL':>11} {'Class A':>13}")
for month in range(1, 13):
    revenue = round(pool * 0.054 / 12 * 0.97)          # 3% of interest not collected
    scheduled = round(pool * 0.003)
    prepay = round((pool - scheduled) * (1 - (1 - 0.05) ** (1 / 12)))   # 5% CPR
    loss = round(pool * 0.0025)                          # 0.25% of the pool a month
    r = run_waterfall(pool, a, b, reserve, revenue, scheduled + prepay, loss, pdl_open=pdl)
    print(f"{month:>5} {loss:>10,} {r['Excess spread']:>14,} {r['Closing reserve']:>11,} "
          f"{r['PDL outstanding']:>11,} {r['Closing Class A']:>13,}")
    pool, a, b = r["Closing pool"], r["Closing Class A"], r["Closing Class B"]
    reserve, pdl = r["Closing reserve"], r["PDL outstanding"]
