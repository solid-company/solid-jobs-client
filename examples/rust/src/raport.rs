use crate::client::SolidJobsClient;
use crate::models::{CountWithPercentage, RaportSalary, RaportYear};

fn print_bucket(label: &str, bucket: &CountWithPercentage, total: i32) {
    println!(
        "    {:<16} {:>5} offers  ({}% of {})",
        label, bucket.count, bucket.percentage, total
    );
}

fn print_salary(label: &str, salary: &Option<RaportSalary>) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
    match salary {
        None => println!("    {}: (no data for this year)", label),
        Some(s) => println!(
            "    {}: median={:.0}  average={:.0}  ranges={}",
            label, s.median, s.average, s.salary_range_count
        ),
    }
}

fn print_year(year: &RaportYear) {
    println!("\n[{}]  offerCount={}", year.year, year.offer_count);

    // NOTE: `total` is the denominator of every percentage below — and it is NOT `offer_count`.
    // Offers proposing neither B2B nor a permanent contract fall outside contract_type, and
    // offers with no declared experience level fall outside seniority.
    let c = &year.contract_type;
    println!(
        "  contractType (total={}, offerCount={}):",
        c.total, year.offer_count
    );
    print_bucket("b2bOnly", &c.b2b_only, c.total);
    print_bucket("permanentOnly", &c.permanent_only, c.total);
    print_bucket("both", &c.both, c.total);

    let s = &year.seniority;
    println!(
        "  seniority (total={}, offerCount={}):",
        s.total, year.offer_count
    );
    print_bucket("junior", &s.junior, s.total);
    print_bucket("regular", &s.regular, s.total);
    print_bucket("senior", &s.senior, s.total);

    println!("  salary (monthly, PLN):");
    print_salary("B2B", &year.salary_b2b);
    print_salary("UoP", &year.salary_uop);
}

pub async fn run() -> Result<(), Box<dyn std::error::Error>> {
    let client = SolidJobsClient::new();
    let campaign = "rust-raport";

    // Yearly market report for a single role — up to 3 calendar years, oldest first.
    // There is no `fields` parameter here: the report always comes back whole.
    let raport = client.get_market_raport("ManualTester", campaign).await?;

    println!("Role:         {}", raport.scope_key);
    println!("Generated at: {}", raport.generated_at);
    println!("Years:        {}", raport.years.len());

    for year in &raport.years {
        print_year(year);
    }

    Ok(())
}
