import Foundation

private func printBand(_ band: SalaryBand?) {
    guard let b = band else {
        print("    (no offers with a declared salary)")
        return
    }
    print("    min=\(Int(b.min))  p25=\(Int(b.p25))  median=\(Int(b.median))  p75=\(Int(b.p75))  max=\(Int(b.max))")
}

private func printContractSalary(_ label: String, _ stat: SalaryStat?) {
    guard let s = stat else {
        print("    \(label): (no precomputed data)")
        return
    }
    print("    \(label): median=\(Int(s.median))  average=\(Int(s.average))  offers=\(s.offerCount)")
}

private func printBuckets(_ buckets: [Bucket]) {
    for b in buckets {
        let label = b.label.count < 24 ? b.label + String(repeating: " ", count: 24 - b.label.count) : b.label
        print("    \(label) \(String(format: "%5d", b.offerCount)) offers  (\(b.percentage)%)")
    }
}

private func printStatistics(_ stats: MarketStatisticsResponse) {
    print("Scope:            \(stats.scopeKind) / \(stats.scopeKey)")
    print("Generated at:     \(stats.generatedAt)")
    print("Included sections: \(stats.includedSections.joined(separator: ", "))")

    if let d = stats.demand {
        print("\n[demand]")
        print("  activeOffers=\(d.activeOffers)  distinctEmployers=\(d.distinctEmployers)  remoteOffers=\(d.remoteOffers)  remotePercentage=\(d.remotePercentage)%")
        print("  offerTrend (quarterly):")
        for point in d.offerTrend {
            print("    \(point.period): \(point.offerCount) offers")
        }
    }

    if let s = stats.salary {
        print("\n[salary] currency=\(s.currency)")
        print("  overall (live percentiles):")
        printBand(s.overall)
        printContractSalary("b2b       ", s.b2b)
        printContractSalary("permanent ", s.permanent)
    }

    if let experience = stats.experience {
        print("\n[experience]")
        printBuckets(experience)
    }

    if let topLocations = stats.topLocations {
        print("\n[topLocations]")
        printBuckets(topLocations)
    }

    if let topSkills = stats.topSkills {
        print("\n[topSkills]")
        printBuckets(topSkills)
    }
}

func runStatistics() async throws {
    let client = SolidJobsClient()
    let campaign = "swift-stats"

    // 1) Full snapshot — every section available for the React specialization
    let full = try await client.getMarketStatistics(scopeKind: "subcategory", scopeKey: "React", campaign: campaign)
    printStatistics(full)

    // 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
    //    includedSections in the response confirms exactly what came back.
    print("\n───────────────────────────────────────────────")
    print("Partial fetch with fields=demand,salary:")
    let partial = try await client.getMarketStatistics(
        scopeKind: "subcategory", scopeKey: "React", campaign: campaign, fields: ["demand", "salary"]
    )
    print("Included sections: \(partial.includedSections.joined(separator: ", "))")
}
