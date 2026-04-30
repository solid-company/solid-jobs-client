use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let url = "https://solid.jobs/public-api/offers/IT?campaign=rust-client&pageSize=5";

    let client = reqwest::Client::new();
    let response: Value = client
        .get(url)
        .header("X-Api-Version", "1.0")
        .send()
        .await?
        .json()
        .await?;
    
    println!("Znaleziono {} ofert.", response["totalCount"]);
    
    if let Some(jobs) = response["jobs"].as_array() {
        for job in jobs {
            let title = job["title"].as_str().unwrap_or("Brak tytułu");
            let company = job["company"].as_str().unwrap_or("Brak firmy");
            let salary_from = job["salary"]["from"].as_i64().unwrap_or(0);
            let salary_to = job["salary"]["to"].as_i64().unwrap_or(0);
            let currency = job["salary"]["currency"].as_str().unwrap_or("");
            
            println!("{} @ {} ({}-{} {})", title, company, salary_from, salary_to, currency);
        }
    }
    
    Ok(())
}
