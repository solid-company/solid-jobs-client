import Foundation

private func printBucket(_ label: String, _ bucket: CountWithPercentage, total: Int) {
    let padded = label.padding(toLength: 16, withPad: " ", startingAt: 0)
    print("    \(padded) \(String(format: "%5d", bucket.count)) offers  (\(bucket.percentage)% of \(total))")
}

private func printSalary(_ label: String, _ salary: RaportSalary?) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
    guard let salary else {
        print("    \(label): (no data for this year)")
        return
    }
    print("    \(label): median=\(Int(salary.median))  average=\(Int(salary.average))  ranges=\(salary.salaryRangeCount)")
}

private func printYear(_ year: RaportYear) {
    print("\n[\(year.year)]  offerCount=\(year.offerCount)")

    // NOTE: `total` is the denominator of every percentage below — and it is NOT `offerCount`.
    // Offers proposing neither B2B nor a permanent contract fall outside contractType, and
    // offers with no declared experience level fall outside seniority.
    let contract = year.contractType
    print("  contractType (total=\(contract.total), offerCount=\(year.offerCount)):")
    printBucket("b2bOnly", contract.b2bOnly, total: contract.total)
    printBucket("permanentOnly", contract.permanentOnly, total: contract.total)
    printBucket("both", contract.both, total: contract.total)

    let seniority = year.seniority
    print("  seniority (total=\(seniority.total), offerCount=\(year.offerCount)):")
    printBucket("junior", seniority.junior, total: seniority.total)
    printBucket("regular", seniority.regular, total: seniority.total)
    printBucket("senior", seniority.senior, total: seniority.total)

    print("  salary (monthly, PLN):")
    printSalary("B2B", year.salaryB2B)
    printSalary("UoP", year.salaryUoP)
}

func runRaport() async throws {
    let client = SolidJobsClient()
    let campaign = "swift-raport"

    // Yearly market report for a single role — up to 3 calendar years, oldest first.
    // There is no `fields` parameter here: the report always comes back whole.
    let raport = try await client.getMarketRaport(scopeKey: "ManualTester", campaign: campaign)

    print("Role:         \(raport.scopeKey)")
    print("Generated at: \(raport.generatedAt)")
    print("Years:        \(raport.years.count)")

    for year in raport.years {
        printYear(year)
    }
}
