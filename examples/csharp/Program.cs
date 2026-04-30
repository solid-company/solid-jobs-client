using System.Net.Http.Json;
using System.Text.Json;

using var client = new HttpClient();
var url = "https://solid.jobs/public-api/offers/IT?campaign=dotnet-client&pageSize=5";

var response = await client.GetFromJsonAsync<JsonElement>(url);

Console.WriteLine($"Znaleziono {response.GetProperty("totalCount").GetInt32()} ofert.");

foreach (var job in response.GetProperty("jobs").EnumerateArray())
{
    var title = job.GetProperty("title").GetString();
    var company = job.GetProperty("company").GetString();
    var salary = job.GetProperty("salary");
    
    Console.WriteLine($"{title} @ {company} ({salary.GetProperty("from")}-{salary.GetProperty("to")} {salary.GetProperty("currency")})");
}