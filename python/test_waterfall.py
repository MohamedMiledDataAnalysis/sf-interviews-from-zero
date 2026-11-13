"""Chapter 18, section 18.15: tests for the waterfall function.
Run from the companion folder:  python -m pytest python"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ch18_05_waterfall import run_waterfall


def test_month1_matches_chapter9():
    r = run_waterfall(236_900_000, 203_300_000, 33_600_000, 2_400_000,
                      1_045_000, 2_880_000, 52_000)
    assert r["Excess spread"] == 35_271


def test_notes_reconcile_to_pool():
    r = run_waterfall(236_900_000, 203_300_000, 33_600_000, 2_400_000,
                      1_045_000, 2_880_000, 52_000)
    notes = r["Closing Class A"] + r["Closing Class B"]
    assert notes - r["Closing pool"] == r["PDL outstanding"]
