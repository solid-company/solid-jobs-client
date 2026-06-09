using Microsoft.Extensions.DependencyInjection;
using SolidJobs;
using SolidJobs.Models;

var services = new ServiceCollection();

services.AddHttpClient<SolidJobsClient>(http =>
{
    http.BaseAddress = new Uri("https://solid.jobs/");
    http.DefaultRequestHeaders.Add("X-Api-Version", "1.0");
    http.Timeout = TimeSpan.FromSeconds(30);
});

var provider = services.BuildServiceProvider();
var client = provider.GetRequiredService<SolidJobsClient>();

using var cts = new CancellationTokenSource(TimeSpan.FromMinutes(2));
const string campaign = "dotnet-client";

var firstPage = await client.GetOffersAsync(
    Division.IT,
    campaign,
    new OfferQuery { PageSize = 5 },
    cts.Token);

Console.WriteLine($"Found {firstPage.TotalCount} offers (pages: {firstPage.TotalPages}).");

foreach (var job in firstPage.Jobs)
{
    Console.WriteLine($"{job.Title} @ {job.Company} [{job.ExperienceLevel}] ({FormatSalary(job.Salary)})");
}

var seniorJava = await client.GetOffersAsync(
    Division.IT,
    campaign,
    new OfferQuery
    {
        SearchTerms = ["java"],
        Cities = ["Warszawa"],
        SubCategories = [JobSubCategory.Java],
        Experiences = [ExperienceLevel.Senior],
        MinimumSalary = 15_000,
        Sort = SortField.SalaryTo,
        Direction = SortDirection.Desc,
        PageSize = 10,
    },
    cts.Token);

Console.WriteLine($"\nSenior Java in Warsaw: {seniorJava.TotalCount} offers");
foreach (var job in seniorJava.Jobs)
{
    Console.WriteLine($"- {job.Title} ({FormatSalary(job.Salary)})");
}

Console.WriteLine("\nAll .NET offers:");
var counter = 0;
await foreach (var job in client.GetAllOffersAsync(
    Division.IT,
    campaign,
    new OfferQuery { SubCategories = [JobSubCategory.DotNet] },
    cts.Token))
{
    counter++;
    Console.WriteLine($"{counter,3}. {job.Title} @ {job.Company}");
}
Console.WriteLine($"Total: {counter}");

static string FormatSalary(Salary salary) =>
    salary is { From: null, To: null }
        ? $"no range ({salary.Currency})"
        : $"{salary.From:0}-{salary.To:0} {salary.Currency}/{salary.Period}";
