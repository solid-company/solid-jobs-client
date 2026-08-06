# API Dictionaries and Allowed Values

[![PL](https://img.shields.io/badge/lang-PL-red.svg)](DICTIONARIES.pl.md)

This file contains all allowed text values (enums) used by the SOLID.Jobs public API. Sections 1–3 are search parameters; Sections 4–8 document the values returned in response fields (not filterable); Sections 9–10 cover the [Market Statistics endpoint](README.md#market-statistics-endpoint).

Search-parameter values must be passed in English exactly as defined below.

---

## 1. Experience Levels (`search.experiences`)

Available experience levels:

* `Intern`
* `Junior`
* `Regular`
* `Senior`

---

## 2. Divisions (path parameter `{division}`)

Defines the main industry area for job offers:

* `IT`
* `Engineering`
* `Marketing`
* `Sales`
* `HR`
* `Logistics`
* `Finances`
* `Other`

---

## 3. Categories and Subcategories (`search.categories` and `search.subCategories`)

Below is a hierarchical list of **Categories** and their **Subcategories**. Use these values to narrow search results.

### Categories for Division: IT

* **`Developer`**
  * *Subcategories:* `JavaScript`, `Python`, `DotNet`, `Java`, `PHP`, `Android`, `IOS`, `Scala`, `Ruby`, `CCPlusPlus`, `Angular`, `React`, `NodeJs`, `Golang`, `OtherDeveloper`
* **`Administrator`**
  * *Subcategories:* `SystemsAdministrator`, `NetworkAdministrator`, `DatabaseAdministrator`, `CloudAdministrator`, `OtherAdministrator`
* **`ItManager`**
  * *Subcategories:* `ProjectManager`, `ProductManager`, `ScrumMaster`, `ProductOwner`, `OtherItManager`
* **`Tester`**
  * *Subcategories:* `ManualTester`, `TestAutomationEngineer`, `OtherTester`
* **`Analyst`** → *Subcategory:* `Analyst`
* **`Architect`** → *Subcategory:* `Architect`
* **`DataScience`** → *Subcategory:* `DataScience`
* **`DevOps`** → *Subcategory:* `DevOps`
* **`Security`** → *Subcategory:* `Security`
* **`Support`** → *Subcategory:* `Support`
* **`UXUIDesigner`** → *Subcategory:* `UXUIDesigner`
* **`OtherIT`** → *Subcategories:* `ERP`, `OtherIT`

### Categories for Division: Engineering

* **`AutomationAndRobotics`** → *Subcategory:* `AutomationAndRobotics`
* **`Mechatronics`** → *Subcategory:* `Mechatronics`
* **`TechnologicalEngineering`** → *Subcategory:* `TechnologicalEngineering`
* **`QualityEngineering`** → *Subcategory:* `QualityEngineering`
* **`ProductionEngineering`** → *Subcategory:* `ProductionEngineering`
* **`ConstructionAndDesign`** → *Subcategory:* `ConstructionAndDesign`
* **`MaintenanceEngineering`** → *Subcategory:* `MaintenanceEngineering`
* **`ElectronicsAndTelecommunication`** → *Subcategory:* `ElectronicsAndTelecommunication`
* **`OtherEngineering`** → *Subcategory:* `OtherEngineering`

### Categories for Division: Marketing

* **`Marketing`** → *Subcategory:* `Marketing`
* **`Copywriter`** → *Subcategory:* `Copywriter`
* **`SocialMediaSpecialist`** → *Subcategory:* `SocialMediaSpecialist`
* **`SEO`** → *Subcategory:* `SEO`
* **`EmployerBrandingSpecialist`** → *Subcategory:* `EmployerBrandingSpecialist`
* **`MediaAndJournalism`** → *Subcategory:* `MediaAndJournalism`
* **`ECommerce`** → *Subcategory:* `ECommerce`
* **`OtherMarketing`** → *Subcategory:* `OtherMarketing`

### Categories for Division: Sales

* **`B2BSales`** → *Subcategory:* `B2BSales`
* **`B2CSales`** → *Subcategory:* `B2CSales`
* **`AccountManager`** → *Subcategory:* `AccountManager`
* **`CustomerSuccess`** → *Subcategory:* `CustomerSuccess`
* **`OtherSales`** → *Subcategory:* `OtherSales`

### Categories for Division: HR

* **`Recruiter`** → *Subcategory:* `Recruiter`
* **`HRSpecialist`** → *Subcategory:* `HRSpecialist`
* **`GrowthAndCourses`** → *Subcategory:* `GrowthAndCourses`
* **`OtherHr`** → *Subcategory:* `OtherHr`

### Categories for Division: Logistics

* **`SupplyChain`** → *Subcategory:* `SupplyChain`
* **`Transport`** → *Subcategory:* `Transport`
* **`PurchasesAndSupplies`** → *Subcategory:* `PurchasesAndSupplies`
* **`ProductionPlanning`** → *Subcategory:* `ProductionPlanning`
* **`OtherLogistics`** → *Subcategory:* `OtherLogistics`

### Categories for Division: Finances

* **`Accounting`** → *Subcategory:* `Accounting`
* **`AnalyticsAndControlling`** → *Subcategory:* `AnalyticsAndControlling`
* **`AccountingConsulting`** → *Subcategory:* `AccountingConsulting`
* **`AuditsAndCompliance`** → *Subcategory:* `AuditsAndCompliance`
* **`Insurance`** → *Subcategory:* `Insurance`
* **`OtherFinances`** → *Subcategory:* `OtherFinances`

### Categories for Division: Other

* **`Management`** → *Subcategory:* `Management`
* **`ResearchAndDevelopment`** → *Subcategory:* `ResearchAndDevelopment`
* **`LawAndAdministration`** → *Subcategory:* `LawAndAdministration`
* **`OtherOther`**
  * *Subcategories:* `GraphicDesigner`, `Backoffice`, `OtherOther`

---

## 4. Skill and Language Levels (`skills[].level`, `languages[].level`)

Both the `skills` and `languages` arrays use the same level enum:

* `NiceToHave`
* `Basic`
* `Advanced`
* `Expert`

---

## 5. Salary Currency (`salary.currency`)

Currency code returned in the `salary` and `secondarySalary` objects:

* `PLN`
* `EUR`
* `USD`
* `GBP`
* `CHF`

---

## 6. Salary Period (`salary.period`)

Payment period returned in the `salary` and `secondarySalary` objects:

* `Month`
* `Year`
* `Day`
* `Hour`
* `Fixed`

---

## 7. Employment Type (`salary.employmentType`)

Type of contract returned in the `salary` and `secondarySalary` objects:

* `UoP` — employment contract
* `B2B`
* `UoD` — contract for specific work
* `UZ` — contract of mandate
* `Praktyka` — internship contract
* `Staż` — traineeship contract
* `Kontrakt` — managerial contract
* `Inne` — other (e.g. agency agreement)

---

## 8. Contract Time (`contractTime`)

Working-time dimension returned at the offer level:

* `full_time`
* `part_time`

---

## 9. Market Statistics Scope Kinds (`scopeKind` path parameter)

Used by the [Market Statistics endpoint](README.md#market-statistics-endpoint). `scopeKind` selects the kind of scope the statistics describe; `scopeKey` then names a concrete value within it.

| `scopeKind` | Meaning | `scopeKey` — allowed values |
| :--- | :--- | :--- |
| `division` | A whole division | A Division from Section 2 (e.g. `IT`) |
| `mainCategory` | A main category | A Category from Section 3 (e.g. `Developer`) |
| `subcategory` | A single specialization | A Subcategory from Section 3 (e.g. `React`) |
| `subcategoryGroup` | A group of related specializations | `Frontend` or `Mobile` (see below) |
| `city` | A single city | The city slug, lowercased (e.g. `warszawa`) |

`scopeKind` is case-insensitive. For enum-based kinds the `scopeKey` must be a defined value (an unknown key returns `404`); for `city` any non-empty slug is accepted and normalized to lowercase.

> `raport` is **not** a `scopeKind`. It is a separate path (`/market-statistics/raport/{scopeKey}`) returning a different, year-by-year payload — see the [Market Raport endpoint](README.md#market-raport-endpoint).

**Subcategory groups** (`scopeKey` for `subcategoryGroup`):

* `Frontend` — aggregates `JavaScript`, `Angular`, `React`
* `Mobile` — aggregates `Android`, `IOS`

---

## 10. Market Statistics Sections (`fields` query parameter)

Comma-separated subset of sections returned by the Market Statistics endpoint (case-insensitive). Omit `fields` to get every section available for the scope.

* `demand` — active offers, distinct employers, remote share and quarterly offer trend
* `salary` — overall salary band (percentiles) plus precomputed B2B / permanent stats
* `experience` — distribution of active offers by experience level
* `topLocations` — most common cities (**not available** for the `city` scope)
* `topSkills` — most demanded skills
