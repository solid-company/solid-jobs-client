using SolidJobs.Models;

namespace SolidJobs;

/// <summary>Prints every field the market-raport endpoint can return for a role.</summary>
public static class RaportDemo
{
    public static async Task RunAsync(SolidJobsClient client, string campaign, CancellationToken cancellationToken)
    {
        // Yearly market report for a single role — up to 3 calendar years, oldest first.
        // There is no `fields` parameter here: the report always comes back whole.
        var raport = await client.GetMarketRaportAsync("ManualTester", campaign, cancellationToken);

        Console.WriteLine($"Role:         {raport.ScopeKey}");
        Console.WriteLine($"Generated at: {raport.GeneratedAt:o}");
        Console.WriteLine($"Years:        {raport.Years.Count}");

        foreach (var year in raport.Years)
        {
            PrintYear(year);
        }
    }

    private static void PrintYear(RaportYear year)
    {
        Console.WriteLine($"\n[{year.Year}]  offerCount={year.OfferCount}");

        // NOTE: every `Total` below is an independent denominator — none of them equal OfferCount
        // or each other. Offers proposing neither B2B nor a permanent contract fall outside
        // ContractType, and offers with no declared experience level fall outside Seniority.
        var contract = year.ContractType;
        Console.WriteLine($"  contractType (total={contract.Total}, offerCount={year.OfferCount}):");
        PrintBucket("b2bOnly", contract.B2BOnly, contract.Total);
        PrintBucket("permanentOnly", contract.PermanentOnly, contract.Total);
        PrintBucket("both", contract.Both, contract.Total);

        var seniority = year.Seniority;
        Console.WriteLine($"  seniority (total={seniority.Total}, offerCount={year.OfferCount}):");
        PrintSeniorityNode("junior", seniority.Junior);
        PrintSeniorityNode("regular", seniority.Regular);
        PrintSeniorityNode("senior", seniority.Senior);

        Console.WriteLine("  salary (PLN, per seniority — lower..upper band):");
        PrintSalary("B2B", year.SalaryB2B);
        PrintSalary("UoP", year.SalaryUoP);

        Console.WriteLine($"  topSkills ({year.TopSkills.Count}):");
        foreach (var skill in year.TopSkills.Take(10))
        {
            Console.WriteLine($"    {skill.Name,-20} {skill.Count} offers");
        }

        Console.WriteLine($"  quarters ({year.Quarters.Count}):");
        foreach (var quarter in year.Quarters)
        {
            PrintQuarter(quarter);
        }
    }

    private static void PrintQuarter(RaportQuarter quarter)
    {
        Console.WriteLine($"    Q{quarter.Quarter}  offerCount={quarter.OfferCount}");

        // Same independent-denominator caveat as at year level, scoped to the quarter.
        var contract = quarter.ContractType;
        Console.WriteLine($"      contractType (total={contract.Total}, offerCount={quarter.OfferCount}):");
        PrintBucket("b2bOnly", contract.B2BOnly, contract.Total);
        PrintBucket("permanentOnly", contract.PermanentOnly, contract.Total);
        PrintBucket("both", contract.Both, contract.Total);

        var seniority = quarter.Seniority;
        Console.WriteLine($"      seniority (total={seniority.Total}, offerCount={quarter.OfferCount}):");
        PrintSeniorityNode("junior", seniority.Junior);
        PrintSeniorityNode("regular", seniority.Regular);
        PrintSeniorityNode("senior", seniority.Senior);

        Console.WriteLine("      salary (PLN, per seniority — lower..upper band):");
        PrintSalary("B2B", quarter.SalaryB2B);
        PrintSalary("UoP", quarter.SalaryUoP);
    }

    private static void PrintBucket(string label, CountWithPercentage bucket, int total) =>
        Console.WriteLine($"    {label,-16} {bucket.Count,5} offers  ({bucket.Percentage}% of {total})");

    private static void PrintSeniorityNode(string label, SeniorityNode node)
    {
        Console.WriteLine($"    {label,-16} {node.Count,5} offers  ({node.Percentage}% of seniority.total)");
        // Nested contractType has its own independent total — not the seniority level's Count.
        var contract = node.ContractType;
        PrintBucket("  b2bOnly", contract.B2BOnly, contract.Total);
        PrintBucket("  permanentOnly", contract.PermanentOnly, contract.Total);
        PrintBucket("  both", contract.Both, contract.Total);
    }

    private static void PrintSalary(string label, RaportSalaryStat? salary)
    {
        // SalaryB2B / SalaryUoP are omitted entirely when the year has no data for that contract type.
        if (salary is null)
        {
            Console.WriteLine($"    {label}: (no data for this year)");
            return;
        }

        PrintSalaryBand($"{label} junior", salary.Junior);
        PrintSalaryBand($"{label} regular", salary.Regular);
        PrintSalaryBand($"{label} senior", salary.Senior);
    }

    private static void PrintSalaryBand(string label, RaportSalaryBand band) =>
        // Zero fields mean this seniority has no salary data that year — the object is still present.
        Console.WriteLine($"    {label,-14} median={band.MedianLower:0}..{band.MedianUpper:0}  average={band.AverageLower:0}..{band.AverageUpper:0}  ranges={band.SalaryRangeCount}");
}
