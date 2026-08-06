from typing import Any, Dict, Optional

from client import SolidJobsClient

CAMPAIGN = "python-raport"
ROLE = "ManualTester"


# ─────────────────────────────────────────────────────────────────────────────
#  Printing helpers — walk every field the endpoint can return.
# ─────────────────────────────────────────────────────────────────────────────

def print_bucket(label: str, bucket: Dict[str, Any], total: int) -> None:
    print(f"    {label:<16} {bucket['count']:>5} offers  ({bucket['percentage']}% of {total})")


def print_salary(label: str, salary: Optional[Dict[str, Any]]) -> None:
    # salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
    if not salary:
        print(f"    {label}: (no data for this year)")
        return
    print(f"    {label}: median={salary['median']}  average={salary['average']}  ranges={salary['salaryRangeCount']}")


def print_year(year: Dict[str, Any]) -> None:
    print(f"\n[{year['year']}]  offerCount={year['offerCount']}")

    # NOTE: `total` is the denominator of every `percentage` below — and it is NOT `offerCount`.
    # Offers proposing neither B2B nor a permanent contract fall outside contractType, and offers
    # with no declared experience level fall outside seniority.
    contract = year["contractType"]
    print(f"  contractType (total={contract['total']}, offerCount={year['offerCount']}):")
    print_bucket("b2bOnly", contract["b2bOnly"], contract["total"])
    print_bucket("permanentOnly", contract["permanentOnly"], contract["total"])
    print_bucket("both", contract["both"], contract["total"])

    seniority = year["seniority"]
    print(f"  seniority (total={seniority['total']}, offerCount={year['offerCount']}):")
    print_bucket("junior", seniority["junior"], seniority["total"])
    print_bucket("regular", seniority["regular"], seniority["total"])
    print_bucket("senior", seniority["senior"], seniority["total"])

    print("  salary (monthly, PLN):")
    print_salary("B2B", year.get("salaryB2B"))
    print_salary("UoP", year.get("salaryUoP"))


def main() -> None:
    client = SolidJobsClient()

    # Yearly market report for a single role — up to 3 calendar years, oldest first.
    # There is no `fields` parameter here: the report always comes back whole.
    raport = client.get_market_raport(ROLE, CAMPAIGN)

    print(f"Role:         {raport['scopeKey']}")
    print(f"Generated at: {raport['generatedAt']}")
    print(f"Years:        {len(raport['years'])}")

    for year in raport["years"]:
        print_year(year)


if __name__ == "__main__":
    main()
