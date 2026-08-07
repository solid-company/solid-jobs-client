import Foundation

enum SolidJobsError: Error {
    case invalidCampaign
    case invalidURL
    case invalidResponse
    case httpError(status: Int, body: String)
    case maxRetriesExceeded
}

class SolidJobsClient {
    let baseURL: String
    let apiVersion: String
    let maxRetries: Int
    private let decoder = JSONDecoder()

    init(baseURL: String = "https://solid.jobs", apiVersion: String = "1.0", maxRetries: Int = 3) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.maxRetries = maxRetries
    }

    func getOffers(division: String, campaign: String, query: [(String, String)] = []) async throws -> OffersResponse {
        var params = [("campaign", campaign)]
        params.append(contentsOf: query)

        let queryString = params
            .map { "\($0.0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)=\($0.1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }
            .joined(separator: "&")

        guard let url = URL(string: "\(baseURL)/public-api/offers/\(division)?\(queryString)") else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "X-Api-Version")
        request.timeoutInterval = 30

        for attempt in 0...maxRetries {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Invalid response")
            }

            if httpResponse.statusCode == 429, attempt < maxRetries {
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    .flatMap { Int($0) } ?? Int(pow(2.0, Double(attempt)))
                fputs("Rate limited (429). Retrying in \(retryAfter)s...\n", stderr)
                try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
                continue
            }

            guard httpResponse.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                fatalError("HTTP \(httpResponse.statusCode): \(body)")
            }

            return try decoder.decode(OffersResponse.self, from: data)
        }

        fatalError("Max retries exceeded")
    }

    func getMarketStatistics(
        scopeKind: String,
        scopeKey: String,
        campaign: String,
        fields: [String] = []
    ) async throws -> MarketStatisticsResponse {
        guard campaign.range(of: "^[a-z0-9-]{1,64}$", options: .regularExpression) != nil else {
            throw SolidJobsError.invalidCampaign
        }

        var params = [("campaign", campaign)]
        if !fields.isEmpty {
            params.append(("fields", fields.joined(separator: ",")))
        }

        let queryString = params
            .map { "\($0.0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)=\($0.1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }
            .joined(separator: "&")

        guard let url = URL(string: "\(baseURL)/public-api/market-statistics/\(scopeKind)/\(scopeKey)?\(queryString)") else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "X-Api-Version")
        request.timeoutInterval = 30

        for attempt in 0...maxRetries {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Invalid response")
            }

            if httpResponse.statusCode == 429, attempt < maxRetries {
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    .flatMap { Int($0) } ?? Int(pow(2.0, Double(attempt)))
                fputs("Rate limited (429). Retrying in \(retryAfter)s...\n", stderr)
                try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
                continue
            }

            guard httpResponse.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                fatalError("HTTP \(httpResponse.statusCode): \(body)")
            }

            return try decoder.decode(MarketStatisticsResponse.self, from: data)
        }

        fatalError("Max retries exceeded")
    }

    /// Fetches the yearly market report for a single role. Unlike `getMarketStatistics` there is
    /// no scope kind and no `fields` filter — the report always comes back whole, spanning up to
    /// 3 calendar years, oldest first.
    ///
    /// Note: unlike the older methods above, this one reports failures by throwing `SolidJobsError`
    /// rather than calling `fatalError`, so a caller can actually recover.
    func getMarketRaport(
        scopeKey: String,
        campaign: String
    ) async throws -> MarketRaportResponse {
        guard campaign.range(of: "^[a-z0-9-]{1,64}$", options: .regularExpression) != nil else {
            throw SolidJobsError.invalidCampaign
        }

        let params = [("campaign", campaign)]

        let queryString = params
            .map { "\($0.0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)=\($0.1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }
            .joined(separator: "&")

        guard let url = URL(string: "\(baseURL)/public-api/market-statistics/raport/\(scopeKey)?\(queryString)") else {
            throw SolidJobsError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "X-Api-Version")
        request.timeoutInterval = 30

        for attempt in 0...maxRetries {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SolidJobsError.invalidResponse
            }

            if httpResponse.statusCode == 429, attempt < maxRetries {
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    .flatMap { Int($0) } ?? Int(pow(2.0, Double(attempt)))
                fputs("Rate limited (429). Retrying in \(retryAfter)s...\n", stderr)
                try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
                continue
            }

            guard httpResponse.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                throw SolidJobsError.httpError(status: httpResponse.statusCode, body: body)
            }

            return try decoder.decode(MarketRaportResponse.self, from: data)
        }

        throw SolidJobsError.maxRetriesExceeded
    }

    func getAllOffers(division: String, campaign: String, query: [(String, String)] = []) async throws -> [JobOffer] {
        var all: [JobOffer] = []
        var pageIndex = 0

        while true {
            var pageQuery = query
            pageQuery.append(("pageIndex", String(pageIndex)))

            let page = try await getOffers(division: division, campaign: campaign, query: pageQuery)
            all.append(contentsOf: page.jobs)

            pageIndex += 1
            if page.jobs.isEmpty || pageIndex >= page.totalPages {
                break
            }
        }

        return all
    }
}
