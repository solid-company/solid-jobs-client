import java.util.HashMap;
import java.util.Map;

public class FetchOffers {

    public static void main(String[] args) throws Exception {
        var client = new SolidJobsClient();
        var campaign = "java-client";

        // 1) Basic listing — first page of IT offers
        var body = client.fetchOffers("IT", campaign, Map.of("pageSize", "5"));
        System.out.printf("Found %d offers (pages: %d).%n",
                JsonHelper.getLong(body, "totalCount"),
                JsonHelper.getLong(body, "totalPages"));

        for (var job : JsonHelper.getObjectsInArray(JsonHelper.extractJobsArray(body))) {
            System.out.printf("%s @ %s [%s] (%s)%n",
                    JsonHelper.getString(job, "title"),
                    JsonHelper.getString(job, "company"),
                    JsonHelper.getString(job, "experienceLevel"),
                    JsonHelper.formatSalary(job));
        }

        // 2) Filtering + sorting — Senior Java in Warsaw
        var body2 = client.fetchOffers("IT", campaign, Map.of(
                "search.searchTerm", "java",
                "search.cities", "Warszawa",
                "search.subCategories", "Java",
                "search.experiences", "Senior",
                "search.minimumSalary", "15000",
                "sortActive", "salaryTo",
                "sortDirection", "desc",
                "pageSize", "10"
        ));

        System.out.printf("%nSenior Java in Warsaw: %d offers%n", JsonHelper.getLong(body2, "totalCount"));
        for (var job : JsonHelper.getObjectsInArray(JsonHelper.extractJobsArray(body2))) {
            System.out.printf("- %s (%s)%n", JsonHelper.getString(job, "title"), JsonHelper.formatSalary(job));
        }

        // 3) Paginate all .NET offers
        System.out.println("\nAll .NET offers:");
        int counter = 0;
        int pageIndex = 0;
        while (true) {
            var params = new HashMap<>(Map.of(
                    "search.subCategories", "DotNet",
                    "pageIndex", String.valueOf(pageIndex)
            ));
            var pageBody = client.fetchOffers("IT", campaign, params);
            var pageJobs = JsonHelper.getObjectsInArray(JsonHelper.extractJobsArray(pageBody));
            for (var job : pageJobs) {
                counter++;
                System.out.printf("%3d. %s @ %s%n", counter,
                        JsonHelper.getString(job, "title"),
                        JsonHelper.getString(job, "company"));
            }
            pageIndex++;
            if (pageJobs.isEmpty() || pageIndex >= JsonHelper.getLong(pageBody, "totalPages")) break;
        }
        System.out.printf("Total: %d%n", counter);
    }
}
