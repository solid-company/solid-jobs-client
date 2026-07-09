"""SolidJobs Public API — Market statistics example (Python 3.8+, requires: requests)"""

from typing import Any, Dict, List, Optional

from client import SolidJobsClient


def print_band(band: Optional[Dict[str, Any]]) -> None:
    if band is None:
        print("    (no offers with a declared salary)")
        return
    print(f"    min={band['min']}  p25={band['p25']}  median={band['median']}  p75={band['p75']}  max={band['max']}")


def print_contract_salary(label: str, stat: Optional[Dict[str, Any]]) -> None:
    if stat is None:
        print(f"    {label}: (no precomputed data)")
        return
    print(f"    {label}: median={stat['median']}  average={stat['average']}  offers={stat['offerCount']}")


def print_buckets(buckets: Optional[List[Dict[str, Any]]]) -> None:
    for b in buckets or []:
        print(f"    {b['label']:<24} {b['offerCount']:>5} offers  ({b['percentage']}%)")


def print_statistics(stats: Dict[str, Any]) -> None:
    print(f"Scope:            {stats['scopeKind']} / {stats['scopeKey']}")
    print(f"Generated at:     {stats['generatedAt']}")
    print(f"Included sections: {', '.join(stats['includedSections'])}")

    demand = stats.get("demand")
    if demand:
        print("\n[demand]")
        print(f"  activeOffers={demand['activeOffers']}  distinctEmployers={demand['distinctEmployers']}"
              f"  remoteOffers={demand['remoteOffers']}  remotePercentage={demand['remotePercentage']}%")
        print("  offerTrend (quarterly):")
        for point in demand["offerTrend"]:
            print(f"    {point['period']}: {point['offerCount']} offers")

    salary = stats.get("salary")
    if salary:
        print(f"\n[salary] currency={salary['currency']}")
        print("  overall (live percentiles):")
        print_band(salary.get("overall"))
        print_contract_salary("b2b       ", salary.get("b2b"))
        print_contract_salary("permanent ", salary.get("permanent"))

    if "experience" in stats:
        print("\n[experience]")
        print_buckets(stats["experience"])

    if "topLocations" in stats:
        print("\n[topLocations]")
        print_buckets(stats["topLocations"])

    if "topSkills" in stats:
        print("\n[topSkills]")
        print_buckets(stats["topSkills"])


def main():
    client = SolidJobsClient()
    campaign = "python-stats"

    # 1) Full snapshot — every section available for the React specialization
    full = client.get_market_statistics("subcategory", "React", campaign)
    print_statistics(full)

    # 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
    #    `includedSections` in the response confirms exactly what came back.
    print("\n───────────────────────────────────────────────")
    print("Partial fetch with fields=demand,salary:")
    partial = client.get_market_statistics("subcategory", "React", campaign, fields=["demand", "salary"])
    print(f"Included sections: {', '.join(partial['includedSections'])}")


if __name__ == "__main__":
    main()
