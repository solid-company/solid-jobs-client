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
