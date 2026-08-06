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
GET https://solid.jobs/public-api/offers/{division}?campaign=my-awesome-aggregator
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
        "employmentType": "UoP"
      },
      "contractTime": "full_time",
      "locations": ["Warszawa", "Kraków"],
      "benefits": ["Private healthcare", "Sport card"],
      "isRemote": true,
      "isHybrid": false,
      "url": "https://solid.jobs/offer/abc-123-def",
      "experienceLevel": "Senior",
      "skills": [
        { "name": ".NET", "level": "Advanced" },
        { "name": "Azure", "level": "NiceToHave" }
      ],
      "languages": [
        { "name": "English", "level": "Advanced" }
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
| `contractTime` | Contract time (e.g. `full_time`, `part_time`). |
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
| `employmentType` | Employment type (e.g. `B2B`, `UoP`). |

### Error Responses

**400 Bad Request** — invalid or missing `campaign`:

```
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — invalid `division`:

```
Division not allowed: 'InvalidValue'. Avialable values are: IT, Engineering, Marketing, Sales, HR, Logistics, Finances, Other.
```

**429 Too Many Requests** — rate limit exceeded. Retry after a short delay.

---

## Market Statistics Endpoint

Aggregated labour-market statistics for a single **scope** — a division, a main category, a specialization (subcategory), a subcategory group, or a city. Like the offers endpoint it needs no authorization (only the `campaign` parameter) and returns a flat, stable JSON contract. Responses are cacheable for up to 1 hour.

```http
GET https://solid.jobs/public-api/market-statistics/{scopeKind}/{scopeKey}?campaign=my-awesome-aggregator
```

The same `X-Api-Version: 1.0` header, the `campaign` rules, and the rate limits (300 req/min per IP, queue 10) described above apply here too.

### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `scopeKind` | string | Kind of scope (case-insensitive). One of `division`, `mainCategory`, `subcategory`, `subcategoryGroup`, `city`. |
| `scopeKey` | string | Concrete value within the kind — see the mapping below. |

**`scopeKey` allowed values** (an unknown kind or key returns `404`):

| `scopeKind` | `scopeKey` value | Example | Allowed values |
| :--- | :--- | :--- | :--- |
| `division` | Division name | `IT` | [DICTIONARIES §2](DICTIONARIES.md#2-divisions-path-parameter-division) |
| `mainCategory` | Main category name | `Developer` | [DICTIONARIES §3](DICTIONARIES.md#3-categories-and-subcategories-searchcategories-and-searchsubcategories) (categories) |
| `subcategory` | Subcategory name | `React` | [DICTIONARIES §3](DICTIONARIES.md#3-categories-and-subcategories-searchcategories-and-searchsubcategories) (subcategories) |
| `subcategoryGroup` | Subcategory group | `Frontend` | `Frontend`, `Mobile` ([DICTIONARIES §9](DICTIONARIES.md#9-market-statistics-scope-kinds-scopekind-path-parameter)) |
| `city` | City slug (lowercased) | `warszawa` | Any city served by the portal |

### Query Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `campaign` | string | **yes** | Traffic identifier — lowercase letters, digits and hyphens, max 64 chars. |
| `fields` | string | no | Comma-separated subset of sections to return (case-insensitive): `demand`, `salary`, `experience`, `topLocations`, `topSkills`. When omitted, all sections available for the scope are returned. |

### Section Availability

`topLocations` is **not available** for the `city` scope (the scope is already a single city). Requesting it explicitly for a city returns `400`; omitting `fields` simply skips it. All other sections are available for every scope kind.

### Example Response

A successful `200 OK` response for `subcategory/React` (all sections):

```json
{
  "scopeKind": "subcategory",
  "scopeKey": "React",
  "generatedAt": "2026-07-08T09:15:00.1234567+00:00",
  "includedSections": ["demand", "salary", "experience", "topLocations", "topSkills"],
  "demand": {
    "activeOffers": 312,
    "distinctEmployers": 148,
    "remoteOffers": 121,
    "remotePercentage": 39,
    "offerTrend": [
      { "period": "2025-Q2", "offerCount": 268 },
      { "period": "2025-Q3", "offerCount": 274 },
      { "period": "2025-Q4", "offerCount": 289 },
      { "period": "2026-Q1", "offerCount": 312 }
    ]
  },
  "salary": {
    "currency": "PLN",
    "overall": { "min": 8000, "p25": 14000, "median": 18000, "p75": 23000, "max": 38000 },
    "b2b": { "median": 20000, "average": 20450, "offerCount": 176 },
    "permanent": { "median": 15000, "average": 15200, "offerCount": 92 }
  },
  "experience": [
    { "label": "Senior", "offerCount": 168, "percentage": 54 },
    { "label": "Regular", "offerCount": 108, "percentage": 35 },
    { "label": "Junior", "offerCount": 36, "percentage": 11 }
  ],
  "topLocations": [
    { "label": "Warszawa", "offerCount": 98, "percentage": 31 },
    { "label": "Kraków", "offerCount": 54, "percentage": 17 },
    { "label": "Wrocław", "offerCount": 41, "percentage": 13 }
  ],
  "topSkills": [
    { "label": "React", "offerCount": 312, "percentage": 100 },
    { "label": "TypeScript", "offerCount": 254, "percentage": 81 },
    { "label": "Redux", "offerCount": 120, "percentage": 38 }
  ]
}
```

#### Top-level fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `scopeKind` | string | Scope kind the statistics describe (echoes the request, normalized). |
| `scopeKey` | string | Scope key within the kind. Enum-based kinds keep canonical casing; `city` is a lowercased slug. |
| `generatedAt` | string | Generation timestamp (UTC, ISO-8601 with a `+00:00` offset). |
| `includedSections` | string[] | Section names actually present in this response — lets you confirm what came back when some were skipped. |
| `demand` | object | Demand & hiring metrics. Omitted when the section was not requested. |
| `salary` | object | Salary metrics. Omitted when the section was not requested. |
| `experience` | object[] | Experience-level distribution. Omitted when not requested. |
| `topLocations` | object[] | Top cities distribution. Omitted when not requested or unavailable (`city` scope). |
| `topSkills` | object[] | Top skills distribution. Omitted when not requested. |

#### `demand` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `activeOffers` | int | Number of active offers in the scope. |
| `distinctEmployers` | int | Number of unique employers publishing in the scope. |
| `remoteOffers` | int | Number of fully remote offers. |
| `remotePercentage` | int | Share of fully remote offers (0–100). |
| `offerTrend` | object[] | Quarterly offer-count trend (precomputed), up to the 8 most recent quarters, oldest first. |

#### `offerTrend[]` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `period` | string | Quarter label in `YYYY-Qn` format (e.g. `2026-Q1`). |
| `offerCount` | int | Number of offers in that quarter. |

#### `salary` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `currency` | string | Currency of every amount below. Always `PLN`. |
| `overall` | object \| null | Salary band computed live from active offers (percentiles). `null` when no offer in the scope declares a salary. |
| `b2b` | object \| null | Precomputed B2B salary stat. `null` when there is no precomputed data. |
| `permanent` | object \| null | Precomputed permanent-contract (UoP) salary stat. `null` when there is no precomputed data. |

#### `salary.overall` fields (salary band)

| Field | Type | Description |
| :--- | :--- | :--- |
| `min` | number | Minimum — lower edge of the range. |
| `p25` | number | 25th percentile. |
| `median` | number | Median (50th percentile). |
| `p75` | number | 75th percentile. |
| `max` | number | Maximum — upper edge of the range. |

#### `salary.b2b` / `salary.permanent` fields (salary stat)

| Field | Type | Description |
| :--- | :--- | :--- |
| `median` | number | Median salary for the contract type. |
| `average` | number | Average salary for the contract type. |
| `offerCount` | int | Number of offers behind the stat. |

#### `experience[]`, `topLocations[]`, `topSkills[]` fields (bucket)

All three sections share the same bucket shape:

| Field | Type | Description |
| :--- | :--- | :--- |
| `label` | string | Entry label — experience level (`experience`), city name (`topLocations`) or skill name (`topSkills`). |
| `offerCount` | int | Number of active offers in this entry. |
| `percentage` | int | Share against all active offers of the scope (0–100). |

### Error Responses

**400 Bad Request** — invalid or missing `campaign`:

```
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — unknown section in `fields`:

```
Unknown section 'foo'. Available sections: Demand, Salary, Experience, TopLocations, TopSkills.
```

**400 Bad Request** — a requested section is not available for the scope (e.g. `topLocations` for a city):

```
Section(s) not available for scope kind 'City': TopLocations. Available for this scope: Demand, Salary, Experience, TopSkills.
```

**404 Not Found** — unknown `scopeKind` or `scopeKey` (empty body).

**429 Too Many Requests** — rate limit exceeded. Retry after a short delay.

---

## Market Raport Endpoint

A year-by-year market report for a **single role** — offer volume, contract-type split, seniority split and salary levels, one entry per calendar year. Unlike the statistics endpoint above there is **no `scopeKind`** (the path segment is always `raport`) and **no `fields`** parameter — the report is always returned whole. Responses are cacheable for up to 1 hour.

```http
GET https://solid.jobs/public-api/market-statistics/raport/{scopeKey}?campaign=my-awesome-aggregator
```

The same `X-Api-Version: 1.0` header, the `campaign` rules, and the rate limits (300 req/min per IP, queue 10) described above apply here too.

### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `scopeKey` | string | Role (specialization) the report describes, e.g. `ManualTester`. Case-insensitive; an unknown value returns `404`. Allowed values: [DICTIONARIES §3](DICTIONARIES.md#3-categories-and-subcategories-searchcategories-and-searchsubcategories) (subcategories). |

### Query Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `campaign` | string | **yes** | Traffic identifier — lowercase letters, digits and hyphens, max 64 chars. |

### Coverage

The report spans up to **3 calendar years**, oldest first: the current year plus the two before it. The current year is year-to-date, so its counts are naturally lower than a completed year's.

### Example Response

A successful `200 OK` response for `ManualTester` (trimmed here to two years):

```json
{
  "scopeKey": "ManualTester",
  "generatedAt": "2026-08-06T07:39:45.4839069+00:00",
  "years": [
    {
      "year": 2024,
      "offerCount": 170,
      "contractType": {
        "b2bOnly": { "count": 133, "percentage": 81 },
        "permanentOnly": { "count": 22, "percentage": 13 },
        "both": { "count": 10, "percentage": 6 },
        "total": 165
      },
      "seniority": {
        "junior": { "count": 31, "percentage": 19 },
        "regular": { "count": 107, "percentage": 65 },
        "senior": { "count": 27, "percentage": 16 },
        "total": 165
      },
      "salaryB2B": { "median": 13450, "average": 13173, "salaryRangeCount": 142 },
      "salaryUoP": { "median": 6000, "average": 7330, "salaryRangeCount": 32 }
    },
    {
      "year": 2025,
      "offerCount": 177,
      "contractType": {
        "b2bOnly": { "count": 140, "percentage": 82 },
        "permanentOnly": { "count": 6, "percentage": 4 },
        "both": { "count": 25, "percentage": 15 },
        "total": 171
      },
      "seniority": {
        "junior": { "count": 25, "percentage": 14 },
        "regular": { "count": 115, "percentage": 66 },
        "senior": { "count": 33, "percentage": 19 },
        "total": 173
      },
      "salaryB2B": { "median": 13050, "average": 13097, "salaryRangeCount": 165 },
      "salaryUoP": { "median": 9000, "average": 9082, "salaryRangeCount": 31 }
    }
  ]
}
```

#### Top-level fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `scopeKey` | string | Role the report describes (echoes the request, canonical casing). |
| `generatedAt` | string | Generation timestamp (UTC, ISO-8601 with a `+00:00` offset). |
| `years` | object[] | One entry per calendar year, oldest first. |

#### `years[]` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `year` | int | Calendar year the entry describes. |
| `offerCount` | int | All offers published in the role that year. |
| `contractType` | object | Split by the contract types an offer proposes. |
| `seniority` | object | Split by required experience level. |
| `salaryB2B` | object | B2B salary levels for the year. **Omitted** when the year has no B2B data. |
| `salaryUoP` | object | Permanent-contract (UoP) salary levels. **Omitted** when the year has no UoP data. |

#### `contractType` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `b2bOnly` | object | Offers proposing **only** B2B. |
| `permanentOnly` | object | Offers proposing **only** a permanent contract (UoP). |
| `both` | object | Offers proposing **both** B2B and UoP. |
| `total` | int | Sum of the three buckets — the denominator of their `percentage`. Read the note below: this is **not** `offerCount`. |

#### `seniority` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `junior` | object | Offers requiring a junior level. |
| `regular` | object | Offers requiring a regular level. |
| `senior` | object | Offers requiring a senior level. |
| `total` | int | Sum of the three buckets — the denominator of their `percentage`. Read the note below: this is **not** `offerCount`. |

#### `contractType` / `seniority` bucket fields

Every bucket in both breakdowns shares the same shape:

| Field | Type | Description |
| :--- | :--- | :--- |
| `count` | int | Number of offers in this bucket. |
| `percentage` | int | Share against the breakdown's own `total` (0–100). |

#### `salaryB2B` / `salaryUoP` fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `median` | number | Median monthly salary in PLN for the contract type that year. |
| `average` | number | Average monthly salary in PLN for the contract type that year. |
| `salaryRangeCount` | int | Number of salary ranges behind the figures — **not** a distinct offer count, see the note below. |

### Reading the Numbers

Three things will trip up a naive integration:

* **`total` is not `offerCount`.** An offer proposing neither B2B nor a permanent contract (a mandate contract, for instance) lands in no `contractType` bucket, and an offer with no declared experience level lands in no `seniority` bucket. Always divide by the breakdown's own `total`, never by `offerCount`. In the example above 2024 has `offerCount` 170 but `contractType.total` 165.
* **Percentages are rounded independently**, so the three values of a breakdown can add up to 99 or 101 rather than exactly 100.
* **`salaryRangeCount` counts salary ranges, not offers.** An offer declaring both a primary and a secondary range of the same contract type contributes twice, so this number can exceed the year's offer count.

### Error Responses

**400 Bad Request** — invalid or missing `campaign`:

```
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**404 Not Found** — unknown `scopeKey` (empty body).

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

### Market Statistics Examples

Every language directory also ships a market-statistics example. It fetches all sections for the `subcategory/React` scope, prints every returned value, then makes a second call with `fields=demand,salary` to show the section filter in action.

| Language | Directory | Command |
| :--- | :--- | :--- |
| [JavaScript / Node.js](examples/javascript/fetch_statistics.mjs) | `examples/javascript` | `node fetch_statistics.mjs` |
| [C# / .NET](examples/csharp/StatisticsDemo.cs) | `examples/csharp` | `dotnet run stats` |
| [Python](examples/python/fetch_statistics.py) | `examples/python` | `python fetch_statistics.py` |
| [Go](examples/go/statistics.go) | `examples/go` | `go run . stats` |
| [Java](examples/java/FetchStatistics.java) | `examples/java` | `javac *.java && java FetchStatistics` |
| [PHP](examples/php/fetch_statistics.php) | `examples/php` | `php fetch_statistics.php` |
| [Ruby](examples/ruby/fetch_statistics.rb) | `examples/ruby` | `ruby fetch_statistics.rb` |
| [Rust](examples/rust/src/statistics.rs) | `examples/rust` | `cargo run -- stats` |
| [Swift](examples/swift/Sources/Statistics.swift) | `examples/swift` | `swift run solidjobs-example stats` |

### Market Raport Examples

Every language directory also ships a market-raport example. It fetches the yearly report for the `ManualTester` role and prints, for each year, the offer count, the contract-type and seniority splits, and the B2B / UoP salary levels.

| Language | Directory | Command |
| :--- | :--- | :--- |
| [JavaScript / Node.js](examples/javascript/fetch_raport.mjs) | `examples/javascript` | `node fetch_raport.mjs` |
| [C# / .NET](examples/csharp/RaportDemo.cs) | `examples/csharp` | `dotnet run raport` |
| [Python](examples/python/fetch_raport.py) | `examples/python` | `python fetch_raport.py` |
| [Go](examples/go/raport.go) | `examples/go` | `go run . raport` |
| [Java](examples/java/FetchRaport.java) | `examples/java` | `javac *.java && java FetchRaport` |
| [PHP](examples/php/fetch_raport.php) | `examples/php` | `php fetch_raport.php` |
| [Ruby](examples/ruby/fetch_raport.rb) | `examples/ruby` | `ruby fetch_raport.rb` |
| [Rust](examples/rust/src/raport.rs) | `examples/rust` | `cargo run -- raport` |
| [Swift](examples/swift/Sources/Raport.swift) | `examples/swift` | `swift run solidjobs-example raport` |

## Contributions and Bug Reports

If you have an idea for extending the public API with new endpoints or found a bug in the documentation, please open an **Issue**.

## License

This project is licensed under the [MIT](LICENSE) license.
