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
