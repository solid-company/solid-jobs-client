# SOLID.Jobs - Public API Client

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PL](https://img.shields.io/badge/lang-PL-red.svg)](README.pl.md)

A sample client for fetching public job offers from the [SOLID.Jobs](https://solid.jobs) portal.

The API is designed for external integrators, job aggregators, and anyone who wants to build custom interfaces or IT market analyses.

## API Features

* **No classic authorization** — The API does not require API Keys or OAuth tokens. Access is controlled via a mandatory `campaign` parameter used for traffic tracking (see below).
* **Advanced filtering** — Search by cities, technologies, experience levels, and salary ranges.
* **Pagination and sorting** — Full control over the data you retrieve.
* **Standardization** — Clear and predictable data format (JSON).

## Main Endpoint

```http
GET https://solid.jobs/public-api/offers/{division}
```

*Available divisions: `IT`, `Engineering`, `Marketing`, `Sales`, `HR`, `Logistics`, `Finances`, `Other`.*

### API Versioning

The API is versioned. The current version is `1.0`. You can specify the version in the request header:

```http
X-Api-Version: 1.0
```

Omitting the header means the latest available version will be used.

### Required Parameter: `campaign`

Every request **must** include the `campaign` query parameter. It is used solely for traffic analytics — it is not an authorization token.

* Value: Your unique identifier (e.g. company name, bot name, integration id).
* Format: Lowercase letters, digits, and hyphens only. Maximum 64 characters.
* Example: `?campaign=my-awesome-aggregator`

### Rate Limits

The API enforces rate limiting. Exceeding the limit returns a `429 Too Many Requests` status.

| Limit | Value |
| :--- | :--- |
| Requests per minute (per IP) | **300** (fixed window) |
| Queue limit | **10** |

We recommend handling the `429` status with a retry mechanism (e.g. exponential backoff).

### Optional Search Parameters (Query Params)

> **For a detailed list of allowed values for each parameter, see [DICTIONARIES.md](DICTIONARIES.md).**

| Parameter | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `pageIndex` | int | Page index (starting from 0, default 0). | `0` |
| `pageSize` | int | Page size (default 30, max 500). | `50` |
| `sortActive` | string | Sort field (`validFrom`, `validTo`, `title`, `company`, `salaryFrom`, `salaryTo`, `experienceLevel`). | `validFrom` |
| `sortDirection` | string | Sort direction (`asc` or `desc`). | `desc` |
| `search.cities` | string | Comma-separated cities. | `Poznań,Warszawa` |
| `search.categories` | string[] | Main categories (e.g. `Developer`, `Tester`). | `Developer` |
| `search.subCategories` | string[] | Subcategories (e.g. `DotNet`, `Java`). | `DotNet,Java` |
| `search.experiences` | string[] | Experience level. | `Regular,Senior` |
| `search.searchTerm` | string[] | Full-text search phrases. | `Angular` |
| `search.minimumSalary` | int | Minimum salary — lower bound of salary range ≥ value. | `20000` |

---

## Example Response

A successful `200 OK` response returns a JSON object with the following structure:

```json
{
  "pageIndex": 0,
  "pageSize": 30,
  "totalCount": 142,
  "totalPages": 5,
  "jobs": [
    {
      "jobOfferKey": "abc-123-def",
      "title": "Senior .NET Developer",
      "division": "IT",
      "category": "Developer",
      "subCategory": "DotNet",
      "company": "Acme Corp",
      "companyLogoUrl": "https://solid.jobs/images/company/acme.png",
      "salary": {
        "from": 18000,
        "to": 25000,
        "currency": "PLN",
        "period": "Month",
        "employmentType": "B2B"
      },
      "secondarySalary": {
        "from": 15000,
        "to": 20000,
        "currency": "PLN",
        "period": "Month",
        "employmentType": "Employment"
      },
      "contractTime": "FullTime",
      "locations": ["Warszawa", "Kraków"],
      "benefits": ["Private healthcare", "Sport card"],
      "isRemote": true,
      "isHybrid": false,
      "url": "https://solid.jobs/offer/abc-123-def",
      "experienceLevel": "Senior",
      "skills": [
        { "name": ".NET", "level": "Advanced" },
        { "name": "Azure", "level": "Regular" }
      ],
      "languages": [
        { "name": "English", "level": "B2" }
      ],
      "description": "We are looking for a Senior .NET Developer...",
      "validFrom": "2026-05-01T00:00:00+00:00",
      "validTo": "2026-06-01T00:00:00+00:00",
      "updatedAt": "2026-05-15T12:30:00+00:00"
    }
  ]
}
```

#### Response fields

| Field | Description |
| :--- | :--- |
| `pageIndex` | Current page index (starting from 0). |
| `pageSize` | Number of offers per page. |
| `totalCount` | Total number of offers matching the query. |
| `totalPages` | Total number of pages. |
| `jobs` | Array of job offer objects. |

#### Job offer fields

| Field | Description |
| :--- | :--- |
| `jobOfferKey` | Unique offer identifier. |
| `title` | Job title. |
| `division` | Division (e.g. `IT`, `Engineering`). |
| `category` | Main category (e.g. `Developer`). |
| `subCategory` | Subcategory (e.g. `DotNet`). |
| `company` | Company name. |
| `companyLogoUrl` | Company logo URL (nullable). |
| `salary` | Primary salary object. |
| `secondarySalary` | Secondary salary object, e.g. different contract type (nullable). |
| `contractTime` | Contract time (e.g. `FullTime`, `PartTime`). |
| `locations` | Array of city names. |
| `benefits` | Array of benefit descriptions. |
| `isRemote` | Whether the position is fully remote. |
| `isHybrid` | Whether the position is hybrid. |
| `url` | Direct link to the offer on SOLID.Jobs. |
| `experienceLevel` | Required experience level. |
| `skills` | Array of required skills (`name` + `level`). |
| `languages` | Array of required languages (`name` + `level`). |
| `description` | Job offer description. |
| `validFrom` | Offer publication date. |
| `validTo` | Offer expiration date. |
| `updatedAt` | Last update timestamp (nullable). |

#### Salary fields

| Field | Description |
| :--- | :--- |
| `from` | Lower bound of salary range (nullable). |
| `to` | Upper bound of salary range (nullable). |
| `currency` | Currency code (e.g. `PLN`, `EUR`, `USD`). |
| `period` | Payment period (e.g. `Month`, `Hour`). |
| `employmentType` | Employment type (e.g. `B2B`, `Employment`). |

### Error Responses

**400 Bad Request** — invalid or missing `campaign`:

```
Make sure that campaign parameter exist and contains only letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — invalid `division`:

```
Division not allowed: 'InvalidValue'. Avialable values are: IT, Engineering, Marketing, Sales, HR, Logistics, Finances, Other.
```

**429 Too Many Requests** — rate limit exceeded. Retry after a short delay.

---

## Usage Examples

In the `/examples` directory you will find ready-to-run scripts showing how to integrate with the API. Each example works after cloning the repository — just navigate to the directory and run a single command.

| Language | Requirements | Directory | Command |
| :--- | :--- | :--- | :--- |
| [JavaScript / Node.js](examples/javascript/fetch_offers.mjs) | Node.js 18+ | `examples/javascript` | `node fetch_offers.mjs` |
| [C# / .NET](examples/csharp/Program.cs) | .NET 9 SDK | `examples/csharp` | `dotnet run` |
| [Python](examples/python/fetch_offers.py) | Python 3.8+ | `examples/python` | `pip install -r requirements.txt && python fetch_offers.py` |
| [Go](examples/go/main.go) | Go 1.21+ | `examples/go` | `go run .` |
| [Java](examples/java/FetchOffers.java) | Java 11+ | `examples/java` | `javac *.java && java FetchOffers` |
| [PHP](examples/php/fetch_offers.php) | PHP 7.4+ | `examples/php` | `php fetch_offers.php` |
| [Ruby](examples/ruby/fetch_offers.rb) | Ruby 2.7+ | `examples/ruby` | `ruby fetch_offers.rb` |
| [Rust](examples/rust/src/main.rs) | Rust 1.70+ | `examples/rust` | `cargo run` |
| [Swift](examples/swift/Sources/main.swift) | Swift 5.9+ | `examples/swift` | `swift run` |

## Contributions and Bug Reports

If you have an idea for extending the public API with new endpoints or found a bug in the documentation, please open an **Issue**.

## License

This project is licensed under the [MIT](LICENSE) license.
