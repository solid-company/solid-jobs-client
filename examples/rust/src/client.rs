use reqwest::header::HeaderValue;
use std::time::Duration;

use crate::models::{JobOffer, MarketRaportResponse, MarketStatisticsResponse, OffersResponse};

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

    /// Fetches labour-market statistics for the given scope. `fields` is an optional
    /// subset of sections; an empty slice returns all sections available for the scope.
    pub async fn get_market_statistics(
        &self,
        scope_kind: &str,
        scope_key: &str,
        campaign: &str,
        fields: &[&str],
    ) -> Result<MarketStatisticsResponse, Box<dyn std::error::Error>> {
        if campaign.is_empty()
            || campaign.len() > 64
            || !campaign
                .bytes()
                .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'-')
        {
            return Err(
                "campaign must contain only lowercase letters, digits and hyphens (max 64 chars)".into(),
            );
        }

        let url = format!(
            "{}/public-api/market-statistics/{}/{}",
            self.base_url, scope_kind, scope_key
        );

        let fields_joined = fields.join(",");
        let mut params: Vec<(&str, &str)> = vec![("campaign", campaign)];
        if !fields.is_empty() {
            params.push(("fields", &fields_joined));
        }

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

            let status = resp.status();
            if !status.is_success() {
                let body = resp.text().await.unwrap_or_default();
                return Err(format!("HTTP {}: {}", status.as_u16(), body.trim()).into());
            }
            return Ok(resp.json::<MarketStatisticsResponse>().await?);
        }

        Err("Max retries exceeded".into())
    }

    /// Fetches the yearly market report for a single role. Unlike `get_market_statistics`
    /// there is no scope kind and no `fields` filter — the report always comes back whole,
    /// spanning up to 3 calendar years, oldest first.
    pub async fn get_market_raport(
        &self,
        scope_key: &str,
        campaign: &str,
    ) -> Result<MarketRaportResponse, Box<dyn std::error::Error>> {
        if campaign.is_empty()
            || campaign.len() > 64
            || !campaign
                .bytes()
                .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'-')
        {
            return Err(
                "campaign must contain only lowercase letters, digits and hyphens (max 64 chars)".into(),
            );
        }

        let url = format!(
            "{}/public-api/market-statistics/raport/{}",
            self.base_url, scope_key
        );

        let params: Vec<(&str, &str)> = vec![("campaign", campaign)];

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

            let status = resp.status();
            if !status.is_success() {
                let body = resp.text().await.unwrap_or_default();
                return Err(format!("HTTP {}: {}", status.as_u16(), body.trim()).into());
            }
            return Ok(resp.json::<MarketRaportResponse>().await?);
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
