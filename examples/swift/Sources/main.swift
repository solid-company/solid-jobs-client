import Foundation

let urlString = "https://solid.jobs/public-api/offers/IT?campaign=swift-client&pageSize=5"
guard let url = URL(string: urlString) else {
    fatalError("Niepoprawny adres URL")
}

var request = URLRequest(url: url)
request.setValue("1.0", forHTTPHeaderField: "X-Api-Version")

let (data, response) = try await URLSession.shared.data(for: request)

guard let httpResponse = response as? HTTPURLResponse else {
    fatalError("Nieprawidłowa odpowiedź serwera")
}

if httpResponse.statusCode == 429 {
    fputs("Przekroczono limit zapytań (429). Spróbuj ponownie za chwilę.\n", stderr)
    exit(1)
}

guard httpResponse.statusCode == 200 else {
    fputs("Błąd HTTP: \(httpResponse.statusCode)\n", stderr)
    exit(1)
}

guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let totalCount = json["totalCount"] as? Int,
      let jobs = json["jobs"] as? [[String: Any]]
else {
    fatalError("Błąd parsowania JSON")
}

print("Znaleziono \(totalCount) ofert.")

for job in jobs {
    let title = job["title"] as? String ?? ""
    let company = job["company"] as? String ?? ""
    if let salary = job["salary"] as? [String: Any],
       let from = salary["from"] as? Int,
       let to = salary["to"] as? Int,
       let currency = salary["currency"] as? String {
        print("\(title) @ \(company) (\(from)-\(to) \(currency))")
    }
}
