# Słowniki i dozwolone wartości API

[![EN](https://img.shields.io/badge/lang-EN-blue.svg)](DICTIONARIES.md)

Ten plik zawiera zestawienie wszystkich dozwolonych wartości tekstowych (enumów) używanych w publicznym API SOLID.Jobs. Sekcje 1–3 to parametry wyszukiwania; Sekcje 4–8 opisują wartości zwracane w polach odpowiedzi (niefiltrowalne).

Wartości parametrów wyszukiwania należy przekazywać w języku angielskim, dokładnie tak, jak zdefiniowano poniżej.

---

## 1. Doświadczenie (`search.experiences`)

Możliwe poziomy doświadczenia w ofertach pracy:

* `None` (Brak)
* `Intern` (Staż)
* `Junior`
* `Regular`
* `Senior`

---

## 2. Działy (parametr ścieżki `{division}`)

Określa główny obszar branżowy ofert pracy:

* `IT`
* `Engineering` (Inżynieria i produkcja)
* `Marketing`
* `Sales` (Sprzedaż)
* `HR`
* `Logistics` (Logistyka)
* `Finances` (Finanse)
* `Other` (Inni specjaliści)

---

## 3. Kategorie i Podkategorie (`search.categories` i `search.subCategories`)

Poniżej znajduje się hierarchiczne zestawienie **Kategorii** oraz przypisanych do nich **Podkategorii**. Możesz używać tych wartości do zawężania wyników wyszukiwania.

### Kategorie dla Działu IT

* **`Developer`** (Programista)
  * *Podkategorie:* `JavaScript`, `Python`, `DotNet`, `Java`, `PHP`, `Android`, `IOS`, `Scala`, `Ruby`, `CCPlusPlus`, `Angular`, `React`, `NodeJs`, `Golang`, `OtherDeveloper`
* **`Administrator`**
  * *Podkategorie:* `SystemsAdministrator`, `NetworkAdministrator`, `DatabaseAdministrator`, `CloudAdministrator`, `OtherAdministrator`
* **`ItManager`** (Manager/Agile)
  * *Podkategorie:* `ProjectManager`, `ProductManager`, `ScrumMaster`, `ProductOwner`, `OtherItManager`
* **`Tester`**
  * *Podkategorie:* `ManualTester`, `TestAutomationEngineer`, `OtherTester`
* **`Analyst`** (Analityk) → *Podkategoria:* `Analyst`
* **`Architect`** (Architekt) → *Podkategoria:* `Architect`
* **`DataScience`** → *Podkategoria:* `DataScience`
* **`DevOps`** → *Podkategoria:* `DevOps`
* **`Security`** → *Podkategoria:* `Security`
* **`Support`** → *Podkategoria:* `Support`
* **`UXUIDesigner`** → *Podkategoria:* `UXUIDesigner`
* **`OtherIT`** → *Podkategorie:* `ERP`, `OtherIT`

### Kategorie dla Działu Inżynieria

* **`AutomationAndRobotics`** (Automatyka i Robotyka) → *Podkategoria:* `AutomationAndRobotics`
* **`Mechatronics`** (Mechatronika) → *Podkategoria:* `Mechatronics`
* **`TechnologicalEngineering`** (Inżynieria technologiczna) → *Podkategoria:* `TechnologicalEngineering`
* **`QualityEngineering`** (Inżynieria jakości) → *Podkategoria:* `QualityEngineering`
* **`ProductionEngineering`** (Inżynieria produkcji) → *Podkategoria:* `ProductionEngineering`
* **`ConstructionAndDesign`** (Konstrukcja i projektowanie) → *Podkategoria:* `ConstructionAndDesign`
* **`MaintenanceEngineering`** (Utrzymywanie ruchu) → *Podkategoria:* `MaintenanceEngineering`
* **`ElectronicsAndTelecommunication`** (Elektronika i telekomunikacja) → *Podkategoria:* `ElectronicsAndTelecommunication`
* **`OtherEngineering`** (Pozostali specjaliści) → *Podkategoria:* `OtherEngineering`

### Kategorie dla Działu Marketing

* **`Marketing`** → *Podkategoria:* `Marketing`
* **`Copywriter`** → *Podkategoria:* `Copywriter`
* **`SocialMediaSpecialist`** → *Podkategoria:* `SocialMediaSpecialist`
* **`SEO`** (SEO/SEM) → *Podkategoria:* `SEO`
* **`EmployerBrandingSpecialist`** → *Podkategoria:* `EmployerBrandingSpecialist`
* **`MediaAndJournalism`** (Media i dziennikarstwo) → *Podkategoria:* `MediaAndJournalism`
* **`ECommerce`** → *Podkategoria:* `ECommerce`
* **`OtherMarketing`** → *Podkategoria:* `OtherMarketing`

### Kategorie dla Działu Sprzedaż

* **`B2BSales`** (Sprzedaż B2B) → *Podkategoria:* `B2BSales`
* **`B2CSales`** (Sprzedaż B2C i detaliczna) → *Podkategoria:* `B2CSales`
* **`AccountManager`** → *Podkategoria:* `AccountManager`
* **`CustomerSuccess`** → *Podkategoria:* `CustomerSuccess`
* **`OtherSales`** → *Podkategoria:* `OtherSales`

### Kategorie dla Działu HR

* **`Recruiter`** (Rekruter) → *Podkategoria:* `Recruiter`
* **`HRSpecialist`** (Specjalista HR) → *Podkategoria:* `HRSpecialist`
* **`GrowthAndCourses`** (Rozwój i szkolenia) → *Podkategoria:* `GrowthAndCourses`
* **`OtherHr`** → *Podkategoria:* `OtherHr`

### Kategorie dla Działu Logistyka

* **`SupplyChain`** (Łańcuch Dostaw) → *Podkategoria:* `SupplyChain`
* **`Transport`** (Transport i Spedycja) → *Podkategoria:* `Transport`
* **`PurchasesAndSupplies`** (Zakupy i Zaopatrzenie) → *Podkategoria:* `PurchasesAndSupplies`
* **`ProductionPlanning`** (Planowanie produkcji) → *Podkategoria:* `ProductionPlanning`
* **`OtherLogistics`** → *Podkategoria:* `OtherLogistics`

### Kategorie dla Działu Finanse

* **`Accounting`** (Księgowość) → *Podkategoria:* `Accounting`
* **`AnalyticsAndControlling`** (Analityka i Controlling) → *Podkategoria:* `AnalyticsAndControlling`
* **`AccountingConsulting`** (Doradztwo) → *Podkategoria:* `AccountingConsulting`
* **`AuditsAndCompliance`** (Audyt i Compliance) → *Podkategoria:* `AuditsAndCompliance`
* **`Insurance`** (Ubezpieczenia) → *Podkategoria:* `Insurance`
* **`OtherFinances`** → *Podkategoria:* `OtherFinances`

### Kategorie dla Działu Inne

* **`Management`** (Zarządzanie) → *Podkategoria:* `Management`
* **`ResearchAndDevelopment`** (Badania i Rozwój) → *Podkategoria:* `ResearchAndDevelopment`
* **`LawAndAdministration`** (Prawo i Administracja) → *Podkategoria:* `LawAndAdministration`
* **`OtherOther`** (Pozostali)
  * *Podkategorie:* `GraphicDesigner` (Grafika i animacja), `Backoffice`, `OtherOther`

---

## 4. Poziomy umiejętności i języków (`skills[].level`, `languages[].level`)

Tablice `skills` i `languages` używają tego samego enuma poziomu:

* `NiceToHave` (mile widziane)
* `Basic` (podstawowy)
* `Advanced` (zaawansowany)
* `Expert` (ekspert)

---

## 5. Waluta wynagrodzenia (`salary.currency`)

Kod waluty zwracany w obiektach `salary` i `secondarySalary`:

* `PLN`
* `EUR`
* `USD`
* `GBP`
* `CHF`

---

## 6. Okres wynagrodzenia (`salary.period`)

Okres rozliczeniowy zwracany w obiektach `salary` i `secondarySalary`:

* `Month` (miesiąc)
* `Year` (rok)
* `Day` (dzień)
* `Hour` (godzina)
* `Fixed` (stała kwota)

---

## 7. Rodzaj umowy (`salary.employmentType`)

Rodzaj umowy zwracany w obiektach `salary` i `secondarySalary`:

* `UoP` — umowa o pracę
* `B2B`
* `UoD` — umowa o dzieło
* `UZ` — umowa zlecenie
* `Praktyka` — umowa o praktykę
* `Staż` — umowa o staż
* `Kontrakt` — kontrakt menedżerski
* `Inne` — pozostałe (np. umowa agencyjna)

---

## 8. Wymiar czasu pracy (`contractTime`)

Wymiar czasu pracy zwracany na poziomie oferty:

* `full_time`
* `part_time`
