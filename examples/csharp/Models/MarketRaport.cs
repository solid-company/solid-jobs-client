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

    /// <summary>Split by required experience level, with its own contract-type split nested inside each level.</summary>
    public required SeniorityBreakdown Seniority { get; init; }

    /// <summary>B2B salary levels by seniority. Null when the year has no B2B data at all (the API omits the field).</summary>
    [JsonPropertyName("salaryB2B")]
    public RaportSalaryStat? SalaryB2B { get; init; }

    /// <summary>Permanent-contract (UoP) salary levels by seniority. Null when the year has no UoP data at all.</summary>
    [JsonPropertyName("salaryUoP")]
    public RaportSalaryStat? SalaryUoP { get; init; }

    /// <summary>Most required skills that year, descending by count, up to 100 entries. Empty (never omitted) when there's no data.</summary>
    public required IReadOnlyList<RaportSkill> TopSkills { get; init; }
}

/// <summary>
/// Contract-type split. <see cref="Total"/> is the denominator of every percentage here and is
/// <b>not</b> <see cref="RaportYear.OfferCount"/> — offers proposing neither B2B nor a permanent
/// contract (a mandate contract, for instance) fall outside all three buckets. Used both at year
/// level and nested inside each <see cref="SeniorityNode"/>.
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
/// Experience-level split. <see cref="Total"/> is the sum of the three levels' <see cref="SeniorityNode.Count"/>
/// and is <b>not</b> <see cref="RaportYear.OfferCount"/> — offers with no declared experience level fall
/// outside all three levels.
/// </summary>
public sealed record SeniorityBreakdown
{
    /// <summary>Offers requiring a junior level.</summary>
    public required SeniorityNode Junior { get; init; }

    /// <summary>Offers requiring a regular level.</summary>
    public required SeniorityNode Regular { get; init; }

    /// <summary>Offers requiring a senior level.</summary>
    public required SeniorityNode Senior { get; init; }

    /// <summary>Sum of the three levels' counts — the denominator of their percentages.</summary>
    public required int Total { get; init; }
}

/// <summary>One experience level's count, percentage, and its own independent contract-type split.</summary>
public sealed record SeniorityNode
{
    /// <summary>Number of offers at this seniority level.</summary>
    public required int Count { get; init; }

    /// <summary>Share against <see cref="SeniorityBreakdown.Total"/> (0–100). Rounded independently per level.</summary>
    public required int Percentage { get; init; }

    /// <summary>Contract-type split within this seniority level only — its <c>Total</c> is an independent denominator.</summary>
    public required ContractTypeBreakdown ContractType { get; init; }
}

/// <summary>One bucket of a <see cref="ContractTypeBreakdown"/>: absolute count plus its share of the breakdown's total.</summary>
public sealed record CountWithPercentage
{
    /// <summary>Number of offers in this bucket.</summary>
    public required int Count { get; init; }

    /// <summary>Share against the breakdown's own total (0–100). Rounded independently per bucket.</summary>
    public required int Percentage { get; init; }
}

/// <summary>
/// Salary levels for one contract type in one year, keyed by seniority. When present, all three
/// seniority keys are always populated — a seniority with no matching offers still appears, with
/// every field at zero.
/// </summary>
public sealed record RaportSalaryStat
{
    /// <summary>Salary band for junior offers that year.</summary>
    public required RaportSalaryBand Junior { get; init; }

    /// <summary>Salary band for regular offers that year.</summary>
    public required RaportSalaryBand Regular { get; init; }

    /// <summary>Salary band for senior offers that year.</summary>
    public required RaportSalaryBand Senior { get; init; }
}

/// <summary>
/// Salary band for one seniority level in one year. Monthly amounts in PLN. Figures are a range,
/// not a single point estimate — pooled from both ends of every matching salary range.
/// </summary>
public sealed record RaportSalaryBand
{
    /// <summary>Lower edge of the median salary range.</summary>
    public required decimal MedianLower { get; init; }

    /// <summary>Upper edge of the median salary range.</summary>
    public required decimal MedianUpper { get; init; }

    /// <summary>Lower edge of the average salary range.</summary>
    public required decimal AverageLower { get; init; }

    /// <summary>Upper edge of the average salary range.</summary>
    public required decimal AverageUpper { get; init; }

    /// <summary>
    /// Number of salary ranges behind the figures for this seniority — <b>not</b> a distinct offer count.
    /// An offer declaring both a primary and a secondary range of the same contract type counts twice.
    /// All fields are zero when this seniority has no salary data that year.
    /// </summary>
    public required int SalaryRangeCount { get; init; }
}

/// <summary>One skill and how many offers required it in a given year.</summary>
public sealed record RaportSkill
{
    /// <summary>Skill name.</summary>
    public required string Name { get; init; }

    /// <summary>Number of offers requiring this skill that year — not a count of occurrences.</summary>
    public required int Count { get; init; }
}
