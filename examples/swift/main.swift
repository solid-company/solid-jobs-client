import Foundation

let urlString = "https://solid.jobs/public-api/offers/IT?campaign=swift-client&pageSize=5"
guard let url = URL(string: urlString) else {
    fatalError("Niepoprawny adres URL")
}

let group = DispatchGroup()
group.enter()

let task = URLSession.shared.dataTask(with: url) { data, response, error in
    defer { group.leave() }
    
    guard let data = data, error == nil else {
        print("Błąd sieci")
        return
    }
    
    do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let totalCount = json["totalCount"] as? Int,
           let jobs = json["jobs"] as? [[String: Any]] {
            
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
        }
    } catch {
        print("Błąd parsowania JSON")
    }
}

task.resume()
group.wait()