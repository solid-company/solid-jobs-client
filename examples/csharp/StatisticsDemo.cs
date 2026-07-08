using SolidJobs.Models;

namespace SolidJobs;

/// <summary>Prints every field the market-statistics endpoint can return for a scope.</summary>
public static class StatisticsDemo
{
    public static async Task RunAsync(SolidJobsClient client, string campaign, CancellationToken cancellationToken)
    {
        // 1) Full snapshot — every section available for the React specialization.
        var full = await client.GetMarketStatisticsAsync("subcategory", "React", campaign, fields: null, cancellationToken);
        PrintStatistics(full);

        // 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
        //    IncludedSections in the response confirms exactly what came back.
        Console.WriteLine("\n───────────────────────────────────────────────");
        Console.WriteLine("Partial fetch with fields=demand,salary:");
        var partial = await client.GetMarketStatisticsAsync(
            "subcategory", "React", campaign, fields: ["demand", "salary"], cancellationToken);
        Console.WriteLine($"Included sections: {string.Join(", ", partial.IncludedSections)}");
    }

    private static void PrintStatistics(MarketStatisticsResponse stats)
    {
        Console.WriteLine($"Scope:            {stats.ScopeKind} / {stats.ScopeKey}");
        Console.WriteLine($"Generated at:     {stats.GeneratedAt:o}");
        Console.WriteLine($"Included sections: {string.Join(", ", stats.IncludedSections)}");

        if (stats.Demand is { } d)
        {
            Console.WriteLine("\n[demand]");
            Console.WriteLine($"  activeOffers={d.ActiveOffers}  distinctEmployers={d.DistinctEmployers}" +
                $"  remoteOffers={d.RemoteOffers}  remotePercentage={d.RemotePercentage}%");
            Console.WriteLine("  offerTrend (quarterly):");
            foreach (var point in d.OfferTrend)
            {
                Console.WriteLine($"    {point.Period}: {point.OfferCount} offers");
            }
        }

        if (stats.Salary is { } s)
        {
            Console.WriteLine($"\n[salary] currency={s.Currency}");
            Console.WriteLine("  overall (live percentiles):");
            PrintBand(s.Overall);
            PrintContractSalary("b2b       ", s.B2B);
            PrintContractSalary("permanent ", s.Permanent);
        }

        if (stats.Experience is { } experience)
        {
            Console.WriteLine("\n[experience]");
            PrintBuckets(experience);
        }

        if (stats.TopLocations is { } topLocations)
        {
            Console.WriteLine("\n[topLocations]");
            PrintBuckets(topLocations);
        }

        if (stats.TopSkills is { } topSkills)
        {
            Console.WriteLine("\n[topSkills]");
            PrintBuckets(topSkills);
        }
    }

    private static void PrintBand(SalaryBand? band)
    {
        if (band is null)
        {
            Console.WriteLine("    (no offers with a declared salary)");
            return;
        }

        Console.WriteLine($"    min={band.Min}  p25={band.P25}  median={band.Median}  p75={band.P75}  max={band.Max}");
    }

    private static void PrintContractSalary(string label, SalaryStat? stat)
    {
        if (stat is null)
        {
            Console.WriteLine($"    {label}: (no precomputed data)");
            return;
        }

        Console.WriteLine($"    {label}: median={stat.Median}  average={stat.Average}  offers={stat.OfferCount}");
    }

    private static void PrintBuckets(IReadOnlyList<Bucket> buckets)
    {
        foreach (var b in buckets)
        {
            Console.WriteLine($"    {b.Label,-24} {b.OfferCount,5} offers  ({b.Percentage}%)");
        }
    }
}
