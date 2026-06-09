"""SolidJobs Public API — Example usage (Python 3.8+, requires: requests)"""

from client import SolidJobsClient
from helpers import format_salary


def main():
    client = SolidJobsClient()
    campaign = "python-client"

    # 1) Basic listing — first page of IT offers
    first_page = client.get_offers("IT", campaign, page_size=5)
    print(f"Found {first_page['totalCount']} offers (pages: {first_page['totalPages']}).")

    for job in first_page["jobs"]:
        print(f"{job['title']} @ {job['company']} [{job['experienceLevel']}] ({format_salary(job['salary'])})")

    # 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
    senior_java = client.get_offers(
        "IT",
        campaign,
        search_terms=["java"],
        cities=["Warszawa"],
        sub_categories=["Java"],
        experiences=["Senior"],
        minimum_salary=15_000,
        sort_active="salaryTo",
        sort_direction="desc",
        page_size=10,
    )

    print(f"\nSenior Java in Warsaw: {senior_java['totalCount']} offers")
    for job in senior_java["jobs"]:
        print(f"- {job['title']} ({format_salary(job['salary'])})")

    # 3) Iterate all .NET offers using generator
    print("\nAll .NET offers:")
    counter = 0
    for job in client.get_all_offers("IT", campaign, sub_categories=["DotNet"]):
        counter += 1
        print(f"{counter:3}. {job['title']} @ {job['company']}")
    print(f"Total: {counter}")


if __name__ == "__main__":
    main()
