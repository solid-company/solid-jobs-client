using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

using var client = new HttpClient();
client.DefaultRequestHeaders.Add("X-Api-Version", "1.0");

var url = "https://solid.jobs/public-api/offers/IT?campaign=dotnet-client&pageSize=5";

var httpResponse = await client.GetAsync(url);

if (httpResponse.StatusCode == HttpStatusCode.TooManyRequests)
{
    Console.Error.WriteLine("Przekroczono limit zapytań (429). Spróbuj ponownie za chwilę.");
    return;
}

httpResponse.EnsureSuccessStatusCode();

var response = await httpResponse.Content.ReadFromJsonAsync<JsonElement>();

Console.WriteLine($"Znaleziono {response.GetProperty("totalCount").GetInt32()} ofert.");

foreach (var job in response.GetProperty("jobs").EnumerateArray())
{
    var title = job.GetProperty("title").GetString();
    var company = job.GetProperty("company").GetString();
    var salary = job.GetProperty("salary");

    Console.WriteLine($"{title} @ {company} ({salary.GetProperty("from")}-{salary.GetProperty("to")} {salary.GetProperty("currency")})");
}
