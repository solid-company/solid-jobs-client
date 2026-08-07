import Foundation

private func printBucket(_ label: String, _ bucket: CountWithPercentage, total: Int) {
    let padded = label.padding(toLength: 16, withPad: " ", startingAt: 0)
    print("    \(padded) \(String(format: "%5d", bucket.count)) offers  (\(bucket.percentage)% of \(total))")
}

private func printContractType(_ prefix: String, _ contract: ContractTypeBreakdown) {
    printBucket("\(prefix)b2bOnly", contract.b2bOnly, total: contract.total)
    printBucket("\(prefix)permanentOnly", contract.permanentOnly, total: contract.total)
    printBucket("\(prefix)both", contract.both, total: contract.total)
}

private func printSeniorityNode(_ label: String, _ node: SeniorityNode) {
    let padded = label.padding(toLength: 16, withPad: " ", startingAt: 0)
    print("    \(padded) \(String(format: "%5d", node.count)) offers  (\(node.percentage)% of seniority.total)")
    // Nested contractType has its own independent total — not the seniority level's count.
    printContractType("  ", node.contractType)
}

private func printSalaryBand(_ label: String, _ band: RaportSalaryBand) {
    let padded = label.padding(toLength: 14, withPad: " ", startingAt: 0)
    // Zero fields mean this seniority has no salary data that year — the object is still present.
    print("    \(padded) median=\(Int(band.medianLower))..\(Int(band.medianUpper))  average=\(Int(band.averageLower))..\(Int(band.averageUpper))  ranges=\(band.salaryRangeCount)")
}

private func printSalary(_ label: String, _ salary: RaportSalaryStat?) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
    guard let salary else {
        print("    \(label): (no data for this year)")
        return
    }
    printSalaryBand("\(label) junior", salary.junior)
    printSalaryBand("\(label) regular", salary.regular)
    printSalaryBand("\(label) senior", salary.senior)
}

private func printYear(_ year: RaportYear) {
    print("\n[\(year.year)]  offerCount=\(year.offerCount)")

    // NOTE: every total below is an independent denominator — none of them equal offerCount
    // or each other. Offers proposing neither B2B nor a permanent contract fall outside
    // contractType, and offers with no declared experience level fall outside seniority.
    let contract = year.contractType
    print("  contractType (total=\(contract.total), offerCount=\(year.offerCount)):")
    printContractType("", contract)

    let seniority = year.seniority
    print("  seniority (total=\(seniority.total), offerCount=\(year.offerCount)):")
    printSeniorityNode("junior", seniority.junior)
    printSeniorityNode("regular", seniority.regular)
    printSeniorityNode("senior", seniority.senior)

    print("  salary (PLN, per seniority — lower..upper band):")
    printSalary("B2B", year.salaryB2B)
    printSalary("UoP", year.salaryUoP)

    print("  topSkills (\(year.topSkills.count)):")
    for skill in year.topSkills.prefix(10) {
        // padding(toLength:) truncates longer strings, so only pad names that are actually short.
        let padded = skill.name.count < 20 ? skill.name.padding(toLength: 20, withPad: " ", startingAt: 0) : skill.name
        print("    \(padded) \(skill.count) offers")
    }
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
