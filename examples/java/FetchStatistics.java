import java.util.List;

/**
 * Market-statistics example. Run after compiling: {@code java FetchStatistics}.
 * Prints every field the endpoint can return for a scope, then demonstrates the `fields` filter.
 */
public class FetchStatistics {

    public static void main(String[] args) throws Exception {
        var client = new SolidJobsClient();
        var campaign = "java-stats";

        // 1) Full snapshot — every section available for the React specialization
        var body = client.fetchMarketStatistics("subcategory", "React", campaign, null);
        printStatistics(body);

        // 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
        //    includedSections in the response confirms exactly what came back.
        System.out.println("\n───────────────────────────────────────────────");
        System.out.println("Partial fetch with fields=demand,salary:");
        var partial = client.fetchMarketStatistics("subcategory", "React", campaign, "demand,salary");
        System.out.println("Included sections: " + String.join(", ", JsonHelper.getStringArray(partial, "includedSections")));
    }

    private static void printStatistics(String body) {
        System.out.println("Scope:            " + JsonHelper.getString(body, "scopeKind") + " / " + JsonHelper.getString(body, "scopeKey"));
        System.out.println("Generated at:     " + JsonHelper.getString(body, "generatedAt"));
        System.out.println("Included sections: " + String.join(", ", JsonHelper.getStringArray(body, "includedSections")));

        var demand = JsonHelper.extractObject(body, "demand");
        if (demand != null) {
            System.out.println("\n[demand]");
            System.out.printf("  activeOffers=%d  distinctEmployers=%d  remoteOffers=%d  remotePercentage=%d%%%n",
                    JsonHelper.getLong(demand, "activeOffers"),
                    JsonHelper.getLong(demand, "distinctEmployers"),
                    JsonHelper.getLong(demand, "remoteOffers"),
                    JsonHelper.getLong(demand, "remotePercentage"));
            System.out.println("  offerTrend (quarterly):");
            var trend = JsonHelper.extractArray(demand, "offerTrend");
            for (var point : JsonHelper.getObjectsInArray(trend == null ? "" : trend)) {
                System.out.printf("    %s: %d offers%n",
                        JsonHelper.getString(point, "period"), JsonHelper.getLong(point, "offerCount"));
            }
        }

        var salary = JsonHelper.extractObject(body, "salary");
        if (salary != null) {
            System.out.println("\n[salary] currency=" + JsonHelper.getString(salary, "currency"));
            System.out.println("  overall (live percentiles):");
            printBand(JsonHelper.extractObject(salary, "overall"));
            printContractSalary("b2b       ", JsonHelper.extractObject(salary, "b2b"));
            printContractSalary("permanent ", JsonHelper.extractObject(salary, "permanent"));
        }

        printBuckets("experience", JsonHelper.extractArray(body, "experience"));
        printBuckets("topLocations", JsonHelper.extractArray(body, "topLocations"));
        printBuckets("topSkills", JsonHelper.extractArray(body, "topSkills"));
    }

    private static void printBand(String band) {
        if (band == null) {
            System.out.println("    (no offers with a declared salary)");
            return;
        }
        System.out.printf("    min=%.0f  p25=%.0f  median=%.0f  p75=%.0f  max=%.0f%n",
                JsonHelper.getDouble(band, "min"), JsonHelper.getDouble(band, "p25"),
                JsonHelper.getDouble(band, "median"), JsonHelper.getDouble(band, "p75"),
                JsonHelper.getDouble(band, "max"));
    }

    private static void printContractSalary(String label, String stat) {
        if (stat == null) {
            System.out.printf("    %s: (no precomputed data)%n", label);
            return;
        }
        System.out.printf("    %s: median=%.0f  average=%.0f  offers=%d%n",
                label, JsonHelper.getDouble(stat, "median"), JsonHelper.getDouble(stat, "average"),
                JsonHelper.getLong(stat, "offerCount"));
    }

    private static void printBuckets(String section, String array) {
        if (array == null) return;
        System.out.println("\n[" + section + "]");
        List<String> buckets = JsonHelper.getObjectsInArray(array);
        for (var b : buckets) {
            System.out.printf("    %-24s %5d offers  (%d%%)%n",
                    JsonHelper.getString(b, "label"),
                    JsonHelper.getLong(b, "offerCount"),
                    JsonHelper.getLong(b, "percentage"));
        }
    }
}
