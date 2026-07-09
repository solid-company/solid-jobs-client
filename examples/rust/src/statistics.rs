use crate::client::SolidJobsClient;
use crate::models::{Bucket, MarketStatisticsResponse, SalaryBand, SalaryStat};

fn print_band(band: &Option<SalaryBand>) {
    match band {
        None => println!("    (no offers with a declared salary)"),
        Some(b) => println!(
            "    min={:.0}  p25={:.0}  median={:.0}  p75={:.0}  max={:.0}",
            b.min, b.p25, b.median, b.p75, b.max
        ),
    }
}

fn print_contract_salary(label: &str, stat: &Option<SalaryStat>) {
    match stat {
        None => println!("    {}: (no precomputed data)", label),
        Some(s) => println!(
            "    {}: median={:.0}  average={:.0}  offers={}",
            label, s.median, s.average, s.offer_count
        ),
    }
}

fn print_buckets(buckets: &[Bucket]) {
    for b in buckets {
        println!("    {:<24} {:>5} offers  ({}%)", b.label, b.offer_count, b.percentage);
    }
}

fn print_statistics(stats: &MarketStatisticsResponse) {
    println!("Scope:            {} / {}", stats.scope_kind, stats.scope_key);
    println!("Generated at:     {}", stats.generated_at);
    println!("Included sections: {}", stats.included_sections.join(", "));

    if let Some(d) = &stats.demand {
        println!("\n[demand]");
        println!(
            "  activeOffers={}  distinctEmployers={}  remoteOffers={}  remotePercentage={}%",
            d.active_offers, d.distinct_employers, d.remote_offers, d.remote_percentage
        );
        println!("  offerTrend (quarterly):");
        for point in &d.offer_trend {
            println!("    {}: {} offers", point.period, point.offer_count);
        }
    }

    if let Some(s) = &stats.salary {
        println!("\n[salary] currency={}", s.currency);
        println!("  overall (live percentiles):");
        print_band(&s.overall);
        print_contract_salary("b2b       ", &s.b2b);
        print_contract_salary("permanent ", &s.permanent);
    }

    if let Some(experience) = &stats.experience {
        println!("\n[experience]");
        print_buckets(experience);
    }

    if let Some(top_locations) = &stats.top_locations {
        println!("\n[topLocations]");
        print_buckets(top_locations);
    }

    if let Some(top_skills) = &stats.top_skills {
        println!("\n[topSkills]");
        print_buckets(top_skills);
    }
}

pub async fn run() -> Result<(), Box<dyn std::error::Error>> {
    let client = SolidJobsClient::new();
    let campaign = "rust-stats";

    // 1) Full snapshot — every section available for the React specialization
    let full = client
        .get_market_statistics("subcategory", "React", campaign, &[])
        .await?;
    print_statistics(&full);

    // 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
    //    included_sections in the response confirms exactly what came back.
    println!("\n───────────────────────────────────────────────");
    println!("Partial fetch with fields=demand,salary:");
    let partial = client
        .get_market_statistics("subcategory", "React", campaign, &["demand", "salary"])
        .await?;
    println!("Included sections: {}", partial.included_sections.join(", "));

    Ok(())
}
