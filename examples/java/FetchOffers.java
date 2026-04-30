import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class FetchOffers {
    public static void main(String[] args) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://solid.jobs/public-api/offers/IT?campaign=java-client&pageSize=5"))
                .header("Accept", "application/json")
                .header("X-Api-Version", "1.0")
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        
        // W prawdziwym projekcie użyj np. Jackson lub Gson do parsowania:
        System.out.println("Surowy JSON:");
        System.out.println(response.body());
    }
}
