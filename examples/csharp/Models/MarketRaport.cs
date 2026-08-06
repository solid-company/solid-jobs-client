using System.Text.Json.Serialization;

namespace SolidJobs.Models;

/// <summary>
/// Year-by-year market report for a single role. Unlike <see cref="MarketStatisticsResponse"/>
/// there is no scope kind and no section filter — the report always comes back whole,
/// spanning up to 3 calendar years, oldest first.
/// </summary>
public sealed record MarketRaportResponse
{
    /// <summary>Role (specialization) the report describes, e.g. <c>ManualTester</c>.</summary>
    public required string ScopeKey { get; init; }

    /// <summary>Moment the response was generated (UTC).</summary>
    public required DateTimeOffset GeneratedAt { get; init; }

    /// <summary>One entry per calendar year, oldest first.</summary>
    public required IReadOnlyList<RaportYear> Years { get; init; }
}

/// <summary>A single calendar year of the report.</summary>
public sealed record RaportYear
{
    /// <summary>Calendar year the entry describes.</summary>
    public required int Year { get; init; }

    /// <summary>All offers published in the role that year.</summary>
    public required int OfferCount { get; init; }

    /// <summary>Split by the contract types an offer proposes.</summary>
    public required ContractTypeBreakdown ContractType { get; init; }

    /// <summary>Split by required experience level.</summary>
    public required SeniorityBreakdown Seniority { get; init; }

    /// <summary>B2B salary levels. Null when the year has no B2B data (the API omits the field).</summary>
    [JsonPropertyName("salaryB2B")]
    public RaportSalary? SalaryB2B { get; init; }

    /// <summary>Permanent-contract (UoP) salary levels. Null when the year has no UoP data.</summary>
    [JsonPropertyName("salaryUoP")]
    public RaportSalary? SalaryUoP { get; init; }
}

/// <summary>
/// Contract-type split. <see cref="Total"/> is the denominator of every percentage here and is
/// <b>not</b> <see cref="RaportYear.OfferCount"/> — offers proposing neither B2B nor a permanent
/// contract (a mandate contract, for instance) fall outside all three buckets.
/// </summary>
public sealed record ContractTypeBreakdown
{
    /// <summary>Offers proposing only B2B.</summary>
    [JsonPropertyName("b2bOnly")]
    public required CountWithPercentage B2BOnly { get; init; }

    /// <summary>Offers proposing only a permanent contract (UoP).</summary>
    public required CountWithPercentage PermanentOnly { get; init; }

    /// <summary>Offers proposing both B2B and UoP.</summary>
    public required CountWithPercentage Both { get; init; }

    /// <summary>Sum of the three buckets — the denominator of their percentages.</summary>
    public required int Total { get; init; }
}

/// <summary>
/// Experience-level split. <see cref="Total"/> is the denominator of every percentage here and is
/// <b>not</b> <see cref="RaportYear.OfferCount"/> — offers with no declared experience level fall
/// outside all three buckets.
/// </summary>
public sealed record SeniorityBreakdown
{
    /// <summary>Offers requiring a junior level.</summary>
    public required CountWithPercentage Junior { get; init; }

    /// <summary>Offers requiring a regular level.</summary>
    public required CountWithPercentage Regular { get; init; }

    /// <summary>Offers requiring a senior level.</summary>
    public required CountWithPercentage Senior { get; init; }

    /// <summary>Sum of the three buckets — the denominator of their percentages.</summary>
    public required int Total { get; init; }
}

/// <summary>One bucket of a breakdown: absolute count plus its share of the breakdown's total.</summary>
public sealed record CountWithPercentage
{
    /// <summary>Number of offers in this bucket.</summary>
    public required int Count { get; init; }

    /// <summary>Share against the breakdown's own total (0–100). Rounded independently per bucket.</summary>
    public required int Percentage { get; init; }
}

/// <summary>Salary levels for one contract type in one year. Monthly amounts in PLN.</summary>
public sealed record RaportSalary
{
    /// <summary>Median monthly salary.</summary>
    public required decimal Median { get; init; }

    /// <summary>Average monthly salary.</summary>
    public required decimal Average { get; init; }

    /// <summary>
    /// Number of salary ranges behind the figures — <b>not</b> a distinct offer count.
    /// An offer declaring both a primary and a secondary range of the same contract type counts twice.
    /// </summary>
    public required int SalaryRangeCount { get; init; }
}
