use reqwest::header::HeaderValue;
use std::time::Duration;

use crate::models::{JobOffer, OffersResponse};

pub struct SolidJobsClient {
    base_url: String,
    api_version: String,
    max_retries: u32,
    http: reqwest::Client,
}

impl SolidJobsClient {
    pub fn new() -> Self {
        Self {
            base_url: "https://solid.jobs".into(),
            api_version: "1.0".into(),
            max_retries: 3,
            http: reqwest::Client::builder()
                .timeout(Duration::from_secs(30))
                .build()
                .expect("Failed to build HTTP client"),
        }
    }

    pub async fn get_offers(
        &self,
        division: &str,
        campaign: &str,
        query: &[(&str, &str)],
    ) -> Result<OffersResponse, Box<dyn std::error::Error>> {
        let url = format!("{}/public-api/offers/{}", self.base_url, division);

        let mut params: Vec<(&str, &str)> = vec![("campaign", campaign)];
        params.extend_from_slice(query);

        for attempt in 0..=self.max_retries {
            let resp = self
                .http
                .get(&url)
                .query(&params)
                .header("X-Api-Version", &self.api_version)
                .send()
                .await?;

            if resp.status() == reqwest::StatusCode::TOO_MANY_REQUESTS && attempt < self.max_retries
            {
                let delay = resp
                    .headers()
                    .get("Retry-After")
                    .and_then(|v: &HeaderValue| v.to_str().ok())
                    .and_then(|s| s.parse::<u64>().ok())
                    .unwrap_or(2u64.pow(attempt));
                eprintln!("Rate limited (429). Retrying in {}s...", delay);
                tokio::time::sleep(Duration::from_secs(delay)).await;
                continue;
            }

            let resp = resp.error_for_status()?;
            return Ok(resp.json::<OffersResponse>().await?);
        }

        Err("Max retries exceeded".into())
    }

    pub async fn get_all_offers(
        &self,
        division: &str,
        campaign: &str,
        base_query: &[(&str, &str)],
    ) -> Result<Vec<JobOffer>, Box<dyn std::error::Error>> {
        let mut all = Vec::new();
        let mut page_index: u32 = 0;

        loop {
            let page_str = page_index.to_string();
            let mut query: Vec<(&str, &str)> = base_query.to_vec();
            query.push(("pageIndex", &page_str));

            let page = self.get_offers(division, campaign, &query).await?;
            let done = page.jobs.is_empty() || page_index + 1 >= page.total_pages;
            all.extend(page.jobs);
            if done {
                break;
            }
            page_index += 1;
        }

        Ok(all)
    }
}
