use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OffersResponse {
    pub jobs: Vec<JobOffer>,
    pub page_index: u32,
    pub page_size: u32,
    pub total_count: u32,
    pub total_pages: u32,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct JobOffer {
    pub job_offer_key: String,
    pub title: String,
    pub division: String,
    pub category: String,
    pub sub_category: String,
    pub company: String,
    pub company_logo_url: Option<String>,
    pub salary: Salary,
    pub secondary_salary: Option<Salary>,
    pub contract_time: String,
    pub locations: Vec<String>,
    pub benefits: Vec<String>,
    pub is_remote: bool,
    pub is_hybrid: bool,
    pub url: String,
    pub experience_level: String,
    pub skills: Vec<SkillTag>,
    pub languages: Vec<SkillTag>,
    pub description: String,
    pub valid_from: String,
    pub valid_to: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Salary {
    pub from: Option<f64>,
    pub to: Option<f64>,
    pub currency: String,
    pub period: String,
    pub employment_type: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SkillTag {
    pub level: String,
    pub name: String,
}

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET STATISTICS
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MarketStatisticsResponse {
    pub scope_kind: String,
    pub scope_key: String,
    pub generated_at: String,
    pub included_sections: Vec<String>,
    pub demand: Option<DemandStats>,
    pub salary: Option<SalaryStats>,
    pub experience: Option<Vec<Bucket>>,
    pub top_locations: Option<Vec<Bucket>>,
    pub top_skills: Option<Vec<Bucket>>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DemandStats {
    pub active_offers: i32,
    pub distinct_employers: i32,
    pub remote_offers: i32,
    pub remote_percentage: i32,
    pub offer_trend: Vec<TrendPoint>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TrendPoint {
    pub period: String,
    pub offer_count: i32,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SalaryStats {
    pub currency: String,
    pub overall: Option<SalaryBand>,
    pub b2b: Option<SalaryStat>,
    pub permanent: Option<SalaryStat>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SalaryBand {
    pub min: f64,
    pub p25: f64,
    pub median: f64,
    pub p75: f64,
    pub max: f64,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SalaryStat {
    pub median: f64,
    pub average: f64,
    pub offer_count: i32,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Bucket {
    pub label: String,
    pub offer_count: i32,
    pub percentage: i32,
}

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET RAPORT
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MarketRaportResponse {
    pub scope_key: String,
    pub generated_at: String,
    pub years: Vec<RaportYear>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RaportYear {
    pub year: i32,
    pub offer_count: i32,
    pub contract_type: ContractTypeBreakdown,
    pub seniority: SeniorityBreakdown,
    // Omitted by the API when the year has no data at all for that contract type.
    // `salaryB2B` / `salaryUoP` do not survive the camelCase rule, hence the explicit renames.
    #[serde(rename = "salaryB2B")]
    pub salary_b2b: Option<RaportSalaryStat>,
    #[serde(rename = "salaryUoP")]
    pub salary_uop: Option<RaportSalaryStat>,
    /// Most required skills that year, descending by count, up to 100 entries.
    /// Empty (never omitted) when there's no data.
    pub top_skills: Vec<RaportSkill>,
    /// Per-quarter breakdown of the same year, oldest first.
    pub quarters: Vec<RaportQuarter>,
}

/// A single calendar quarter within a [`RaportYear`]. Same shape and omission rules as the
/// year itself, just scoped to the quarter — there is no `top_skills` at this level.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RaportQuarter {
    pub quarter: i32,
    pub offer_count: i32,
    pub contract_type: ContractTypeBreakdown,
    pub seniority: SeniorityBreakdown,
    // Omitted by the API when the quarter has no data at all for that contract type.
    #[serde(rename = "salaryB2B")]
    pub salary_b2b: Option<RaportSalaryStat>,
    #[serde(rename = "salaryUoP")]
    pub salary_uop: Option<RaportSalaryStat>,
}

/// `total` is the denominator of every percentage here — it is NOT `offer_count`.
/// Offers proposing neither B2B nor a permanent contract fall outside all three buckets.
/// Used both at year level and nested inside each [`SeniorityNode`].
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ContractTypeBreakdown {
    #[serde(rename = "b2bOnly")]
    pub b2b_only: CountWithPercentage,
    pub permanent_only: CountWithPercentage,
    pub both: CountWithPercentage,
    pub total: i32,
}

/// `total` is the sum of the three levels' `count` — it is NOT `offer_count`.
/// Offers with no declared experience level fall outside all three levels.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SeniorityBreakdown {
    pub junior: SeniorityNode,
    pub regular: SeniorityNode,
    pub senior: SeniorityNode,
    pub total: i32,
}

/// One experience level's count, percentage, and its own independent contract-type split.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SeniorityNode {
    pub count: i32,
    pub percentage: i32,
    pub contract_type: ContractTypeBreakdown,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CountWithPercentage {
    pub count: i32,
    pub percentage: i32,
}

/// Salary levels for one contract type in one year, keyed by seniority. When present, all three
/// seniority keys are always populated — a seniority with no matching offers still appears, with
/// every field at zero.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RaportSalaryStat {
    pub junior: RaportSalaryBand,
    pub regular: RaportSalaryBand,
    pub senior: RaportSalaryBand,
}

/// Salary band for one seniority level in one year. Monthly amounts in PLN. Figures are a range,
/// not a single point estimate — pooled from both ends of every matching salary range.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RaportSalaryBand {
    pub median_lower: f64,
    pub median_upper: f64,
    pub average_lower: f64,
    pub average_upper: f64,
    /// Number of salary ranges behind the figures for this seniority — NOT a distinct offer count.
    /// All fields are zero when this seniority has no salary data that year.
    pub salary_range_count: i32,
}

/// One skill and how many offers required it in a given year.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RaportSkill {
    pub name: String,
    pub count: i32,
}
