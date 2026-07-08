import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;
import java.util.StringJoiner;
import java.util.regex.Pattern;

/**
 * Reusable client for the SolidJobs public API.
 * Uses built-in java.net.http (Java 11+), no external dependencies.
 */
public class SolidJobsClient {

    static final String BASE_URL = "https://solid.jobs";
    static final String API_VERSION = "1.0";
    static final int MAX_RETRIES = 3;
    static final Pattern CAMPAIGN_RE = Pattern.compile("^[a-z0-9-]{1,64}$");

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public String fetchOffers(String division, String campaign, Map<String, String> extraParams) throws Exception {
        if (!CAMPAIGN_RE.matcher(campaign).matches()) {
            throw new IllegalArgumentException("Invalid campaign format.");
        }

        var uri = buildUri(division, campaign, extraParams);

        for (int attempt = 0; ; attempt++) {
            var request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .header("Accept", "application/json")
                    .header("X-Api-Version", API_VERSION)
                    .timeout(Duration.ofSeconds(30))
                    .build();

            var response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 429 || attempt >= MAX_RETRIES) {
                if (response.statusCode() != 200) {
                    throw new RuntimeException("HTTP " + response.statusCode() + ": " + response.body());
                }
                return response.body();
            }

            var retryAfter = response.headers().firstValue("Retry-After");
            long delay = retryAfter.map(Long::parseLong).orElse((long) Math.pow(2, attempt));
            System.err.printf("Rate limited (429). Retrying in %ds...%n", delay);
            Thread.sleep(delay * 1000);
        }
    }

    public String fetchMarketStatistics(String scopeKind, String scopeKey, String campaign, String fields) throws Exception {
        if (!CAMPAIGN_RE.matcher(campaign).matches()) {
            throw new IllegalArgumentException("Invalid campaign format.");
        }

        var query = new StringJoiner("&");
        query.add("campaign=" + encode(campaign));
        if (fields != null && !fields.isEmpty()) {
            query.add("fields=" + encode(fields));
        }
        var uri = BASE_URL + "/public-api/market-statistics/" + encode(scopeKind) + "/" + encode(scopeKey) + "?" + query;

        for (int attempt = 0; ; attempt++) {
            var request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .header("Accept", "application/json")
                    .header("X-Api-Version", API_VERSION)
                    .timeout(Duration.ofSeconds(30))
                    .build();

            var response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 429 || attempt >= MAX_RETRIES) {
                if (response.statusCode() != 200) {
                    throw new RuntimeException("HTTP " + response.statusCode() + ": " + response.body());
                }
                return response.body();
            }

            var retryAfter = response.headers().firstValue("Retry-After");
            long delay = retryAfter.map(Long::parseLong).orElse((long) Math.pow(2, attempt));
            System.err.printf("Rate limited (429). Retrying in %ds...%n", delay);
            Thread.sleep(delay * 1000);
        }
    }

    private static String buildUri(String division, String campaign, Map<String, String> params) {
        var sb = new StringJoiner("&");
        sb.add("campaign=" + encode(campaign));
        for (var entry : params.entrySet()) {
            sb.add(encode(entry.getKey()) + "=" + encode(entry.getValue()));
        }
        return BASE_URL + "/public-api/offers/" + division + "?" + sb;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
