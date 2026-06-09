mod client;
mod models;

use client::SolidJobsClient;
use models::Salary;

fn format_salary(s: &Salary) -> String {
    match (s.from, s.to) {
        (None, None) => format!("no range ({})", s.currency),
        (from, to) => format!(
            "{:.0}-{:.0} {}/{}",
            from.unwrap_or(0.0),
            to.unwrap_or(0.0),
            s.currency,
            s.period
        ),
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = SolidJobsClient::new();
    let campaign = "rust-client";

    // 1) Basic listing — first page of IT offers
    let first_page = client
        .get_offers("IT", campaign, &[("pageSize", "5")])
        .await?;

    println!(
        "Found {} offers (pages: {}).",
        first_page.total_count, first_page.total_pages
    );
    for job in &first_page.jobs {
        println!(
            "{} @ {} [{}] ({})",
            job.title,
            job.company,
            job.experience_level,
            format_salary(&job.salary)
        );
    }

    // 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
    let senior_java = client
        .get_offers(
            "IT",
            campaign,
            &[
                ("search.searchTerm", "java"),
                ("search.cities", "Warszawa"),
                ("search.subCategories", "Java"),
                ("search.experiences", "Senior"),
                ("search.minimumSalary", "15000"),
                ("sortActive", "salaryTo"),
                ("sortDirection", "desc"),
                ("pageSize", "10"),
            ],
        )
        .await?;

    println!(
        "\nSenior Java in Warsaw: {} offers",
        senior_java.total_count
    );
    for job in &senior_java.jobs {
        println!("- {} ({})", job.title, format_salary(&job.salary));
    }

    // 3) Iterate all .NET offers
    println!("\nAll .NET offers:");
    let all_dotnet = client
        .get_all_offers("IT", campaign, &[("search.subCategories", "DotNet")])
        .await?;

    for (i, job) in all_dotnet.iter().enumerate() {
        println!("{:3}. {} @ {}", i + 1, job.title, job.company);
    }
    println!("Total: {}", all_dotnet.len());

    Ok(())
}
