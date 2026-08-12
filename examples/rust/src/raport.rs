use crate::client::SolidJobsClient;
use crate::models::{ContractTypeBreakdown, CountWithPercentage, RaportQuarter, RaportSalaryBand, RaportSalaryStat, RaportYear, SeniorityNode};

fn print_bucket(label: &str, bucket: &CountWithPercentage, total: i32) {
    println!(
        "    {:<16} {:>5} offers  ({}% of {})",
        label, bucket.count, bucket.percentage, total
    );
}

fn print_contract_type(indent_label_prefix: &str, contract: &ContractTypeBreakdown) {
    print_bucket(&format!("{indent_label_prefix}b2bOnly"), &contract.b2b_only, contract.total);
    print_bucket(&format!("{indent_label_prefix}permanentOnly"), &contract.permanent_only, contract.total);
    print_bucket(&format!("{indent_label_prefix}both"), &contract.both, contract.total);
}

fn print_seniority_node(label: &str, node: &SeniorityNode) {
    println!(
        "    {:<16} {:>5} offers  ({}% of seniority.total)",
        label, node.count, node.percentage
    );
    // Nested contract_type has its own independent total — not the seniority level's count.
    print_contract_type("  ", &node.contract_type);
}

fn print_salary_band(label: &str, band: &RaportSalaryBand) {
    // Zero fields mean this seniority has no salary data that year — the object is still present.
    println!(
        "    {:<14} median={:.0}..{:.0}  average={:.0}..{:.0}  ranges={}",
        label, band.median_lower, band.median_upper, band.average_lower, band.average_upper, band.salary_range_count
    );
}

fn print_salary(label: &str, salary: &Option<RaportSalaryStat>) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
    match salary {
        None => println!("    {}: (no data for this year)", label),
        Some(s) => {
            print_salary_band(&format!("{label} junior"), &s.junior);
            print_salary_band(&format!("{label} regular"), &s.regular);
            print_salary_band(&format!("{label} senior"), &s.senior);
        }
    }
}

fn print_year(year: &RaportYear) {
    println!("\n[{}]  offerCount={}", year.year, year.offer_count);

    // Every `total` below is an independent denominator — none of them equal `offer_count`
    // or each other.
    let c = &year.contract_type;
    println!(
        "  contractType (total={}, offerCount={}):",
        c.total, year.offer_count
    );
    print_contract_type("", c);

    let s = &year.seniority;
    println!(
        "  seniority (total={}, offerCount={}):",
        s.total, year.offer_count
    );
    print_seniority_node("junior", &s.junior);
    print_seniority_node("regular", &s.regular);
    print_seniority_node("senior", &s.senior);

    println!("  salary (PLN, per seniority — lower..upper band):");
    print_salary("B2B", &year.salary_b2b);
    print_salary("UoP", &year.salary_uop);

    println!("  topSkills ({}):", year.top_skills.len());
    for skill in year.top_skills.iter().take(10) {
        println!("    {:<20} {} offers", skill.name, skill.count);
    }

    println!("  quarters ({}):", year.quarters.len());
    for quarter in &year.quarters {
        print_quarter(quarter);
    }
}

fn print_quarter(quarter: &RaportQuarter) {
    println!("    Q{}  offerCount={}", quarter.quarter, quarter.offer_count);

    // Same independent-denominator caveat as at year level, scoped to the quarter.
    let c = &quarter.contract_type;
    println!(
        "      contractType (total={}, offerCount={}):",
        c.total, quarter.offer_count
    );
    print_contract_type("  ", c);

    let s = &quarter.seniority;
    println!(
        "      seniority (total={}, offerCount={}):",
        s.total, quarter.offer_count
    );
    print_seniority_node("  junior", &s.junior);
    print_seniority_node("  regular", &s.regular);
    print_seniority_node("  senior", &s.senior);

    println!("      salary (PLN, per seniority — lower..upper band):");
    print_salary("B2B", &quarter.salary_b2b);
    print_salary("UoP", &quarter.salary_uop);
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
