/**
 * Yearly market report for a single role — up to 3 calendar years, oldest first.
 * There is no `fields` parameter here: the report always comes back whole.
 */
public class FetchRaport {

    private static final String CAMPAIGN = "java-raport";
    private static final String ROLE = "ManualTester";

    public static void main(String[] args) throws Exception {
        var client = new SolidJobsClient();
        var body = client.fetchMarketRaport(ROLE, CAMPAIGN);

        System.out.println("Role:         " + JsonHelper.getString(body, "scopeKey"));
        System.out.println("Generated at: " + JsonHelper.getString(body, "generatedAt"));

        var years = JsonHelper.extractArray(body, "years");
        var yearObjects = years == null ? java.util.List.<String>of() : JsonHelper.getObjectsInArray(years);
        System.out.println("Years:        " + yearObjects.size());

        for (var year : yearObjects) {
            printYear(year);
        }
    }

    private static void printYear(String year) {
        long offerCount = JsonHelper.getLong(year, "offerCount");
        System.out.printf("%n[%d]  offerCount=%d%n", JsonHelper.getLong(year, "year"), offerCount);

        // NOTE: `total` is the denominator of every percentage below — and it is NOT `offerCount`.
        // Offers proposing neither B2B nor a permanent contract fall outside contractType, and
        // offers with no declared experience level fall outside seniority.
        var contract = JsonHelper.extractObject(year, "contractType");
        long contractTotal = JsonHelper.getLong(contract, "total");
        System.out.printf("  contractType (total=%d, offerCount=%d):%n", contractTotal, offerCount);
        printBucket("b2bOnly", JsonHelper.extractObject(contract, "b2bOnly"), contractTotal);
        printBucket("permanentOnly", JsonHelper.extractObject(contract, "permanentOnly"), contractTotal);
        printBucket("both", JsonHelper.extractObject(contract, "both"), contractTotal);

        var seniority = JsonHelper.extractObject(year, "seniority");
        long seniorityTotal = JsonHelper.getLong(seniority, "total");
        System.out.printf("  seniority (total=%d, offerCount=%d):%n", seniorityTotal, offerCount);
        printBucket("junior", JsonHelper.extractObject(seniority, "junior"), seniorityTotal);
        printBucket("regular", JsonHelper.extractObject(seniority, "regular"), seniorityTotal);
        printBucket("senior", JsonHelper.extractObject(seniority, "senior"), seniorityTotal);

        System.out.println("  salary (monthly, PLN):");
        printSalary("B2B", JsonHelper.extractObject(year, "salaryB2B"));
        printSalary("UoP", JsonHelper.extractObject(year, "salaryUoP"));
    }

    private static void printBucket(String label, String bucket, long total) {
        System.out.printf("    %-16s %5d offers  (%d%% of %d)%n",
                label, JsonHelper.getLong(bucket, "count"), JsonHelper.getLong(bucket, "percentage"), total);
    }

    private static void printSalary(String label, String salary) {
        // salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
        if (salary == null) {
            System.out.printf("    %s: (no data for this year)%n", label);
            return;
        }

        System.out.printf("    %s: median=%.0f  average=%.0f  ranges=%d%n",
                label,
                JsonHelper.getDouble(salary, "median"),
                JsonHelper.getDouble(salary, "average"),
                JsonHelper.getLong(salary, "salaryRangeCount"));
    }
}
