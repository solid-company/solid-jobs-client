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

        // NOTE: every "total" below is an independent denominator — none of them equal offerCount
        // or each other. Offers proposing neither B2B nor a permanent contract fall outside
        // contractType, and offers with no declared experience level fall outside seniority.
        var contract = JsonHelper.extractObject(year, "contractType");
        long contractTotal = JsonHelper.getLong(contract, "total");
        System.out.printf("  contractType (total=%d, offerCount=%d):%n", contractTotal, offerCount);
        printBucket("b2bOnly", JsonHelper.extractObject(contract, "b2bOnly"), contractTotal);
        printBucket("permanentOnly", JsonHelper.extractObject(contract, "permanentOnly"), contractTotal);
        printBucket("both", JsonHelper.extractObject(contract, "both"), contractTotal);

        var seniority = JsonHelper.extractObject(year, "seniority");
        long seniorityTotal = JsonHelper.getLong(seniority, "total");
        System.out.printf("  seniority (total=%d, offerCount=%d):%n", seniorityTotal, offerCount);
        printSeniorityNode("junior", JsonHelper.extractObject(seniority, "junior"));
        printSeniorityNode("regular", JsonHelper.extractObject(seniority, "regular"));
        printSeniorityNode("senior", JsonHelper.extractObject(seniority, "senior"));

        System.out.println("  salary (PLN, per seniority - lower..upper band):");
        printSalary("B2B", JsonHelper.extractObject(year, "salaryB2B"));
        printSalary("UoP", JsonHelper.extractObject(year, "salaryUoP"));

        var topSkills = JsonHelper.extractArray(year, "topSkills");
        var skillObjects = topSkills == null ? java.util.List.<String>of() : JsonHelper.getObjectsInArray(topSkills);
        System.out.printf("  topSkills (%d):%n", skillObjects.size());
        for (int i = 0; i < skillObjects.size() && i < 10; i++) {
            var skill = skillObjects.get(i);
            System.out.printf("    %-20s %d offers%n", JsonHelper.getString(skill, "name"), JsonHelper.getLong(skill, "count"));
        }
    }

    private static void printBucket(String label, String bucket, long total) {
        System.out.printf("    %-16s %5d offers  (%d%% of %d)%n",
                label, JsonHelper.getLong(bucket, "count"), JsonHelper.getLong(bucket, "percentage"), total);
    }

    private static void printSeniorityNode(String label, String node) {
        System.out.printf("    %-16s %5d offers  (%d%% of seniority.total)%n",
                label, JsonHelper.getLong(node, "count"), JsonHelper.getLong(node, "percentage"));
        // Nested contractType has its own independent total — not the seniority level's count.
        var contract = JsonHelper.extractObject(node, "contractType");
        long total = JsonHelper.getLong(contract, "total");
        printBucket("  b2bOnly", JsonHelper.extractObject(contract, "b2bOnly"), total);
        printBucket("  permanentOnly", JsonHelper.extractObject(contract, "permanentOnly"), total);
        printBucket("  both", JsonHelper.extractObject(contract, "both"), total);
    }

    private static void printSalary(String label, String salary) {
        // salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
        if (salary == null) {
            System.out.printf("    %s: (no data for this year)%n", label);
            return;
        }

        printSalaryBand(label + " junior", JsonHelper.extractObject(salary, "junior"));
        printSalaryBand(label + " regular", JsonHelper.extractObject(salary, "regular"));
        printSalaryBand(label + " senior", JsonHelper.extractObject(salary, "senior"));
    }

    private static void printSalaryBand(String label, String band) {
        // Zero fields mean this seniority has no salary data that year — the object is still present.
        System.out.printf("    %-14s median=%.0f..%.0f  average=%.0f..%.0f  ranges=%d%n",
                label,
                JsonHelper.getDouble(band, "medianLower"),
                JsonHelper.getDouble(band, "medianUpper"),
                JsonHelper.getDouble(band, "averageLower"),
                JsonHelper.getDouble(band, "averageUpper"),
                JsonHelper.getLong(band, "salaryRangeCount"));
    }
}
