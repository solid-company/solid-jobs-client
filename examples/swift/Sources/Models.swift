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
