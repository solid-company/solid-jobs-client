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
    // Omitted by the API when the year has no data at all for that contract type.
    let salaryB2B: RaportSalaryStat?
    let salaryUoP: RaportSalaryStat?
    /// Most required skills that year, descending by count, up to 100 entries.
    /// Empty (never omitted) when there's no data.
    let topSkills: [RaportSkill]
    /// Per-quarter breakdown of the same year, oldest first.
    let quarters: [RaportQuarter]
}

/// A single calendar quarter within a `RaportYear`. Same shape and omission rules as the
/// year itself, just scoped to the quarter — there is no `topSkills` at this level.
struct RaportQuarter: Decodable {
    let quarter: Int
    let offerCount: Int
    let contractType: ContractTypeBreakdown
    let seniority: SeniorityBreakdown
    // Omitted by the API when the quarter has no data at all for that contract type.
    let salaryB2B: RaportSalaryStat?
    let salaryUoP: RaportSalaryStat?
}

/// `total` is the denominator of every percentage here — it is NOT `offerCount`.
/// Offers proposing neither B2B nor a permanent contract fall outside all three buckets.
/// Used both at year level and nested inside each `SeniorityNode`.
struct ContractTypeBreakdown: Decodable {
    let b2bOnly: CountWithPercentage
    let permanentOnly: CountWithPercentage
    let both: CountWithPercentage
    let total: Int
}

/// `total` is the sum of the three levels' `count` — it is NOT `offerCount`.
/// Offers with no declared experience level fall outside all three levels.
struct SeniorityBreakdown: Decodable {
    let junior: SeniorityNode
    let regular: SeniorityNode
    let senior: SeniorityNode
    let total: Int
}

/// One experience level's count, percentage, and its own independent contract-type split.
struct SeniorityNode: Decodable {
    let count: Int
    let percentage: Int
    let contractType: ContractTypeBreakdown
}

struct CountWithPercentage: Decodable {
    let count: Int
    let percentage: Int
}

/// Salary levels for one contract type in one year, keyed by seniority. When present, all three
/// seniority keys are always populated — a seniority with no matching offers still appears, with
/// every field at zero.
struct RaportSalaryStat: Decodable {
    let junior: RaportSalaryBand
    let regular: RaportSalaryBand
    let senior: RaportSalaryBand
}

/// Salary band for one seniority level in one year. Monthly amounts in PLN. Figures are a range,
/// not a single point estimate — pooled from both ends of every matching salary range.
struct RaportSalaryBand: Decodable {
    let medianLower: Double
    let medianUpper: Double
    let averageLower: Double
    let averageUpper: Double
    /// Number of salary ranges behind the figures for this seniority — NOT a distinct offer count.
    /// All fields are zero when this seniority has no salary data that year.
    let salaryRangeCount: Int
}

/// One skill and how many offers required it in a given year.
struct RaportSkill: Decodable {
    let name: String
    let count: Int
}
