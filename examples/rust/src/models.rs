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
    pub offer_count: i64,
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
