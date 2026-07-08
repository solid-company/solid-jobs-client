import Foundation

// `swift run solidjobs-example stats` runs the market-statistics demo instead of the offers demo.
if CommandLine.arguments.contains("stats") {
    try await runStatistics()
    exit(0)
}

func formatSalary(_ salary: Salary) -> String {
    if salary.from == nil, salary.to == nil {
        return "no range (\(salary.currency))"
    }
    return "\(Int(salary.from ?? 0))-\(Int(salary.to ?? 0)) \(salary.currency)/\(salary.period)"
}

let client = SolidJobsClient()
let campaign = "swift-client"

// 1) Basic listing — first page of IT offers
let firstPage = try await client.getOffers(division: "IT", campaign: campaign, query: [("pageSize", "5")])
print("Found \(firstPage.totalCount) offers (pages: \(firstPage.totalPages)).")

for job in firstPage.jobs {
    print("\(job.title) @ \(job.company) [\(job.experienceLevel)] (\(formatSalary(job.salary)))")
}

// 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
let seniorJava = try await client.getOffers(division: "IT", campaign: campaign, query: [
    ("search.searchTerm", "java"),
    ("search.cities", "Warszawa"),
    ("search.subCategories", "Java"),
    ("search.experiences", "Senior"),
    ("search.minimumSalary", "15000"),
    ("sortActive", "salaryTo"),
    ("sortDirection", "desc"),
    ("pageSize", "10"),
])

print("\nSenior Java in Warsaw: \(seniorJava.totalCount) offers")
for job in seniorJava.jobs {
    print("- \(job.title) (\(formatSalary(job.salary)))")
}

// 3) Iterate all .NET offers
print("\nAll .NET offers:")
let allDotNet = try await client.getAllOffers(
    division: "IT", campaign: campaign, query: [("search.subCategories", "DotNet")]
)
for (i, job) in allDotNet.enumerated() {
    print(String(format: "%3d. %@ @ %@", i + 1, job.title, job.company))
}
print("Total: \(allDotNet.count)")
