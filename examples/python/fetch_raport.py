from typing import Any, Dict, Optional

from client import SolidJobsClient

CAMPAIGN = "python-raport"
ROLE = "ManualTester"


# ─────────────────────────────────────────────────────────────────────────────
#  Printing helpers — walk every field the endpoint can return.
# ─────────────────────────────────────────────────────────────────────────────

def print_bucket(label: str, bucket: Dict[str, Any], total: int) -> None:
    print(f"    {label:<16} {bucket['count']:>5} offers  ({bucket['percentage']}% of {total})")


def print_seniority_node(label: str, node: Dict[str, Any]) -> None:
    print(f"    {label:<16} {node['count']:>5} offers  ({node['percentage']}% of seniority.total)")
    # Nested contractType has its own independent total — not the seniority level's count.
    contract = node["contractType"]
    print_bucket("  b2bOnly", contract["b2bOnly"], contract["total"])
    print_bucket("  permanentOnly", contract["permanentOnly"], contract["total"])
    print_bucket("  both", contract["both"], contract["total"])


def print_salary_band(label: str, band: Dict[str, Any]) -> None:
    # Zero fields mean this seniority has no salary data that year — the object is still present.
    print(
        f"    {label:<14} median={band['medianLower']}..{band['medianUpper']}  "
        f"average={band['averageLower']}..{band['averageUpper']}  ranges={band['salaryRangeCount']}"
    )


def print_salary(label: str, salary: Optional[Dict[str, Any]]) -> None:
    # salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
    if not salary:
        print(f"    {label}: (no data for this year)")
        return
    print_salary_band(f"{label} junior", salary["junior"])
    print_salary_band(f"{label} regular", salary["regular"])
    print_salary_band(f"{label} senior", salary["senior"])


def print_year(year: Dict[str, Any]) -> None:
    print(f"\n[{year['year']}]  offerCount={year['offerCount']}")

    # NOTE: every `total` below is an independent denominator — none of them equal `offerCount`
    # or each other. Offers proposing neither B2B nor a permanent contract fall outside
    # contractType, and offers with no declared experience level fall outside seniority.
    contract = year["contractType"]
    print(f"  contractType (total={contract['total']}, offerCount={year['offerCount']}):")
    print_bucket("b2bOnly", contract["b2bOnly"], contract["total"])
    print_bucket("permanentOnly", contract["permanentOnly"], contract["total"])
    print_bucket("both", contract["both"], contract["total"])

    seniority = year["seniority"]
    print(f"  seniority (total={seniority['total']}, offerCount={year['offerCount']}):")
    print_seniority_node("junior", seniority["junior"])
    print_seniority_node("regular", seniority["regular"])
    print_seniority_node("senior", seniority["senior"])

    print("  salary (PLN, per seniority — lower..upper band):")
    print_salary("B2B", year.get("salaryB2B"))
    print_salary("UoP", year.get("salaryUoP"))

    top_skills = year["topSkills"]
    print(f"  topSkills ({len(top_skills)}):")
    for skill in top_skills[:10]:
        print(f"    {skill['name']:<20} {skill['count']} offers")


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
