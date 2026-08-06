import Foundation

struct OffersResponse: Decodable {
    let jobs: [JobOffer]
    let pageIndex: Int
    let pageSize: Int
    let totalCount: Int
    let totalPages: Int
}

struct JobOffer: Decodable {
    let jobOfferKey: String
    let title: String
    let division: String
    let category: String
    let subCategory: String
    let company: String
    let companyLogoUrl: String?
    let salary: Salary
    let secondarySalary: Salary?
    let contractTime: String
    let locations: [String]
    let benefits: [String]
    let isRemote: Bool
    let isHybrid: Bool
    let url: String
    let experienceLevel: String
    let skills: [SkillTag]
    let languages: [SkillTag]
    let description: String
    let validFrom: String
    let validTo: String
}

struct Salary: Decodable {
    let from: Double?
    let to: Double?
    let currency: String
    let period: String
    let employmentType: String
}

struct SkillTag: Decodable {
    let level: String
    let name: String
}

// MARK: - Market statistics

struct MarketStatisticsResponse: Decodable {
    let scopeKind: String
    let scopeKey: String
    let generatedAt: String
    let includedSections: [String]
    let demand: DemandStats?
    let salary: SalaryStats?
    let experience: [Bucket]?
    let topLocations: [Bucket]?
    let topSkills: [Bucket]?
}

struct DemandStats: Decodable {
    let activeOffers: Int
    let distinctEmployers: Int
    let remoteOffers: Int
    let remotePercentage: Int
    let offerTrend: [TrendPoint]
}

struct TrendPoint: Decodable {
    let period: String
    let offerCount: Int
}

struct SalaryStats: Decodable {
    let currency: String
    let overall: SalaryBand?
    let b2b: SalaryStat?
    let permanent: SalaryStat?
}

struct SalaryBand: Decodable {
    let min: Double
    let p25: Double
    let median: Double
    let p75: Double
    let max: Double
}

struct SalaryStat: Decodable {
    let median: Double
    let average: Double
    let offerCount: Int
}

struct Bucket: Decodable {
    let label: String
    let offerCount: Int
    let percentage: Int
}

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET RAPORT
// ─────────────────────────────────────────────────────────────────────────────
//  No `keyDecodingStrategy` is set on the decoder, so property names match the
//  JSON keys verbatim — including `b2bOnly`, `salaryB2B` and `salaryUoP`.

struct MarketRaportResponse: Decodable {
    let scopeKey: String
    let generatedAt: String
    let years: [RaportYear]
}

struct RaportYear: Decodable {
    let year: Int
    let offerCount: Int
    let contractType: ContractTypeBreakdown
    let seniority: SeniorityBreakdown
    // Omitted by the API when the year has no data for that contract type.
    let salaryB2B: RaportSalary?
    let salaryUoP: RaportSalary?
}

/// `total` is the denominator of every percentage here — it is NOT `offerCount`.
/// Offers proposing neither B2B nor a permanent contract fall outside all three buckets.
struct ContractTypeBreakdown: Decodable {
    let b2bOnly: CountWithPercentage
    let permanentOnly: CountWithPercentage
    let both: CountWithPercentage
    let total: Int
}

/// `total` is the denominator of every percentage here — it is NOT `offerCount`.
/// Offers with no declared experience level fall outside all three buckets.
struct SeniorityBreakdown: Decodable {
    let junior: CountWithPercentage
    let regular: CountWithPercentage
    let senior: CountWithPercentage
    let total: Int
}

struct CountWithPercentage: Decodable {
    let count: Int
    let percentage: Int
}

struct RaportSalary: Decodable {
    let median: Double
    let average: Double
    /// Number of salary ranges behind the figures — NOT a distinct offer count.
    let salaryRangeCount: Int
}
