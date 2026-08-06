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

        // NOTE: `Total` is the denominator of every percentage below — and it is NOT OfferCount.
        // Offers proposing neither B2B nor a permanent contract fall outside ContractType, and
        // offers with no declared experience level fall outside Seniority.
        var contract = year.ContractType;
        Console.WriteLine($"  contractType (total={contract.Total}, offerCount={year.OfferCount}):");
        PrintBucket("b2bOnly", contract.B2BOnly, contract.Total);
        PrintBucket("permanentOnly", contract.PermanentOnly, contract.Total);
        PrintBucket("both", contract.Both, contract.Total);

        var seniority = year.Seniority;
        Console.WriteLine($"  seniority (total={seniority.Total}, offerCount={year.OfferCount}):");
        PrintBucket("junior", seniority.Junior, seniority.Total);
        PrintBucket("regular", seniority.Regular, seniority.Total);
        PrintBucket("senior", seniority.Senior, seniority.Total);

        Console.WriteLine("  salary (monthly, PLN):");
        PrintSalary("B2B", year.SalaryB2B);
        PrintSalary("UoP", year.SalaryUoP);
    }

    private static void PrintBucket(string label, CountWithPercentage bucket, int total) =>
        Console.WriteLine($"    {label,-16} {bucket.Count,5} offers  ({bucket.Percentage}% of {total})");

    private static void PrintSalary(string label, RaportSalary? salary)
    {
        // SalaryB2B / SalaryUoP are omitted entirely when the year has no data for that contract type.
        if (salary is null)
        {
            Console.WriteLine($"    {label}: (no data for this year)");
            return;
        }

        Console.WriteLine($"    {label}: median={salary.Median:0}  average={salary.Average:0}  ranges={salary.SalaryRangeCount}");
    }
}
