#!/usr/bin/env python3
"""Count Polish working dates after a start date through a deadline date."""

from __future__ import annotations

import argparse
import datetime as dt
import json


def easter_sunday(year: int) -> dt.date:
    """Return Gregorian Easter Sunday using the Meeus/Jones/Butcher algorithm."""
    a = year % 19
    b = year // 100
    c = year % 100
    d = b // 4
    e = b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i = c // 4
    k = c % 4
    ell = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * ell) // 451
    month = (h + ell - 7 * m + 114) // 31
    day = ((h + ell - 7 * m + 114) % 31) + 1
    return dt.date(year, month, day)


def polish_public_holidays(year: int) -> set[dt.date]:
    """Return nationwide Polish public holidays under current 2025+ rules."""
    easter = easter_sunday(year)
    fixed = {
        (1, 1),
        (1, 6),
        (5, 1),
        (5, 3),
        (8, 15),
        (11, 1),
        (11, 11),
        (12, 25),
        (12, 26),
    }
    if year >= 2025:
        fixed.add((12, 24))

    holidays = {dt.date(year, month, day) for month, day in fixed}
    holidays.update(
        {
            easter,
            easter + dt.timedelta(days=1),
            easter + dt.timedelta(days=49),
            easter + dt.timedelta(days=60),
        }
    )
    return holidays


def working_dates_after(start: dt.date, deadline: dt.date) -> list[dt.date]:
    """Return working dates in the interval (start, deadline]."""
    if deadline <= start:
        return []

    holidays: set[dt.date] = set()
    for year in range(start.year, deadline.year + 1):
        holidays.update(polish_public_holidays(year))

    dates: list[dt.date] = []
    current = start + dt.timedelta(days=1)
    while current <= deadline:
        if current.weekday() < 5 and current not in holidays:
            dates.append(current)
        current += dt.timedelta(days=1)
    return dates


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Count Polish working dates strictly after START through DEADLINE. "
            "Dates must use YYYY-MM-DD."
        )
    )
    parser.add_argument("start", type=dt.date.fromisoformat)
    parser.add_argument("deadline", type=dt.date.fromisoformat)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    dates = working_dates_after(args.start, args.deadline)
    print(
        json.dumps(
            {
                "start_exclusive": args.start.isoformat(),
                "deadline_inclusive": args.deadline.isoformat(),
                "working_days_remaining": len(dates),
                "working_dates": [date.isoformat() for date in dates],
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
