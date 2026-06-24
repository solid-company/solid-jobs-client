# SOLID.Jobs - Klient Publicznego API

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![EN](https://img.shields.io/badge/lang-EN-blue.svg)](README.md)

Przykładowy klient, który pozwala na pobranie publicznych ofert pracy z portalu [SOLID.Jobs](https://solid.jobs).

API zostało zaprojektowane z myślą o zewnętrznych integratorach, agregatorach ofert pracy oraz osobach chcących budować własne interfejsy i analizy rynku IT.

## Cechy API

* **Brak klasycznej autoryzacji** — API nie wymaga generowania kluczy (API Keys) ani tokenów OAuth. Dostęp jest kontrolowany przez obowiązkowy parametr `campaign` służący do śledzenia ruchu (patrz niżej).
* **Rozbudowane filtrowanie** — Wyszukiwanie po miastach, technologiach, doświadczeniu i widełkach płacowych.
* **Paginacja i sortowanie** — Pełna kontrola nad pobieranymi danymi.
* **Standaryzacja** — Jasny i przewidywalny format danych (JSON).

## Endpoint Główny

```http
GET https://solid.jobs/public-api/offers/{dzial}
```

*Dostępne działy (dział): `IT`, `Engineering`, `Marketing`, `Sales`, `HR`, `Logistics`, `Finances`, `Other`.*

### Wersjonowanie API

API jest wersjonowane. Aktualna wersja to `1.0`. Wersję można podać w nagłówku żądania:

```http
X-Api-Version: 1.0
```

Brak nagłówka oznacza użycie najnowszej dostępnej wersji.

### Wymagany parametr: `campaign`

Każde żądanie **musi** zawierać parametr query `campaign`. Służy on wyłącznie do analityki ruchu — nie jest to token autoryzacyjny.

* Wartość: Twój unikalny identyfikator (np. nazwa firmy, nazwa bota, id integracji).
* Format: Tylko małe litery, cyfry i myślniki. Maksymalnie 64 znaki.
* Przykład: `?campaign=moj-super-agregator`

### Limity zapytań

API stosuje rate limiting. Przekroczenie limitu zwraca status `429 Too Many Requests`.

| Limit | Wartość |
| :--- | :--- |
| Zapytań na minutę (na IP) | **300** (fixed window) |
| Limit kolejki | **10** |

Zalecamy obsługę statusu `429` z mechanizmem retry (np. exponential backoff).

### Opcjonalne parametry wyszukiwania (Query Params)

> **Szczegółowy opis dozwolonych wartości dla poszczególnych parametrów znajdziesz w pliku [DICTIONARIES.pl.md](DICTIONARIES.pl.md).**

| Parametr | Typ | Opis | Przykład |
| :--- | :--- | :--- | :--- |
| `pageIndex` | int | Indeks strony (od 0, domyślnie 0). | `0` |
| `pageSize` | int | Rozmiar strony (domyślnie 30, max 500). | `50` |
| `sortActive` | string | Pole do sortowania (`validFrom`, `validTo`, `title`, `company`, `salaryFrom`, `salaryTo`, `experienceLevel`). | `validFrom` |
| `sortDirection` | string | Kierunek sortowania (`asc` lub `desc`). | `desc` |
| `search.cities` | string | Miasta po przecinku. | `Poznań,Warszawa` |
| `search.categories` | string[] | Kategorie główne (np. `Developer`, `Tester`). | `Developer` |
| `search.subCategories` | string[] | Podkategorie (np. `DotNet`, `Java`). | `DotNet,Java` |
| `search.experiences` | string[] | Poziom doświadczenia. | `Regular,Senior` |
| `search.searchTerm` | string[] | Frazy do wyszukiwania pełnotekstowego. | `Angular` |
| `search.minimumSalary` | int | Minimalne wynagrodzenie — dolna granica widełek ≥ wartość. | `20000` |

---

## Przykładowa odpowiedź

Poprawna odpowiedź `200 OK` zwraca obiekt JSON o następującej strukturze:

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
      "benefits": ["Prywatna opieka zdrowotna", "Karta sportowa"],
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
      "description": "Szukamy Senior .NET Developera...",
      "validFrom": "2026-05-01T00:00:00+00:00",
      "validTo": "2026-06-01T00:00:00+00:00",
      "updatedAt": "2026-05-15T12:30:00+00:00"
    }
  ]
}
```

#### Pola odpowiedzi

| Pole | Opis |
| :--- | :--- |
| `pageIndex` | Indeks bieżącej strony (od 0). |
| `pageSize` | Liczba ofert na stronie. |
| `totalCount` | Łączna liczba ofert spełniających kryteria. |
| `totalPages` | Łączna liczba stron. |
| `jobs` | Tablica obiektów ofert pracy. |

#### Pola oferty pracy

| Pole | Opis |
| :--- | :--- |
| `jobOfferKey` | Unikalny identyfikator oferty. |
| `title` | Tytuł stanowiska. |
| `division` | Dział (np. `IT`, `Engineering`). |
| `category` | Kategoria główna (np. `Developer`). |
| `subCategory` | Podkategoria (np. `DotNet`). |
| `company` | Nazwa firmy. |
| `companyLogoUrl` | URL logo firmy (nullable). |
| `salary` | Główny obiekt wynagrodzenia. |
| `secondarySalary` | Dodatkowy obiekt wynagrodzenia, np. inny typ umowy (nullable). |
| `contractTime` | Wymiar czasu pracy (np. `full_time`, `part_time`). |
| `locations` | Tablica nazw miast. |
| `benefits` | Tablica opisów benefitów. |
| `isRemote` | Czy stanowisko jest w pełni zdalne. |
| `isHybrid` | Czy stanowisko jest hybrydowe. |
| `url` | Bezpośredni link do oferty na SOLID.Jobs. |
| `experienceLevel` | Wymagany poziom doświadczenia. |
| `skills` | Tablica wymaganych umiejętności (`name` + `level`). |
| `languages` | Tablica wymaganych języków (`name` + `level`). |
| `description` | Opis oferty pracy. |
| `validFrom` | Data publikacji oferty. |
| `validTo` | Data wygaśnięcia oferty. |
| `updatedAt` | Data ostatniej aktualizacji (nullable). |

#### Pola wynagrodzenia

| Pole | Opis |
| :--- | :--- |
| `from` | Dolna granica widełek płacowych (nullable). |
| `to` | Górna granica widełek płacowych (nullable). |
| `currency` | Kod waluty (np. `PLN`, `EUR`, `USD`). |
| `period` | Okres rozliczeniowy (np. `Month`, `Hour`). |
| `employmentType` | Typ zatrudnienia (np. `B2B`, `UoP`). |

### Odpowiedzi błędów

**400 Bad Request** — nieprawidłowy lub brakujący `campaign`:

```
Make sure that campaign parameter exist and contains only letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — nieprawidłowy `dział`:

```
Division not allowed: 'InvalidValue'. Avialable values are: IT, Engineering, Marketing, Sales, HR, Logistics, Finances, Other.
```

**429 Too Many Requests** — przekroczono limit zapytań. Ponów żądanie po krótkiej przerwie.

---

## Przykłady użycia

W katalogu `/examples` znajdziesz gotowe skrypty pokazujące, jak zintegrować się z API. Każdy przykład działa po sklonowaniu repozytorium — wystarczy przejść do katalogu i uruchomić jedną komendę.

| Język | Wymagania | Katalog | Komenda |
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

## Kontrybucje i zgłaszanie błędów

Jeśli masz pomysł na rozszerzenie publicznego API o nowe endpointy lub znalazłeś błąd w dokumentacji, otwórz **Issue**.

## Licencja

Ten projekt jest udostępniany na licencji [MIT](LICENSE).
