"""Formatting helpers for SolidJobs API responses."""

from typing import Any, Dict


def format_salary(salary: Dict[str, Any]) -> str:
    if salary.get("from") is None and salary.get("to") is None:
        return f"no range ({salary['currency']})"
    return f"{salary['from']}-{salary['to']} {salary['currency']}/{salary['period']}"
