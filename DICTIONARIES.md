# API Dictionaries and Allowed Values

[![PL](https://img.shields.io/badge/lang-PL-red.svg)](DICTIONARIES.pl.md)

This file contains all allowed text values (enums) used by the SOLID.Jobs public API. Sections 1–3 are search parameters; Sections 4–8 document the values returned in response fields (not filterable).

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
