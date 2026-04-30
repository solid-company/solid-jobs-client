# SOLID.Jobs - Public API Client

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Przykładowy klient, który pozwala na pobranie publicznych ofert pracy z portalu [SOLID.Jobs](https://solid.jobs).

API zostało zaprojektowane z myślą o zewnętrznych integratorach, agregatorach ofert pracy oraz osobach chcących budować własne interfejsy i analizy rynku IT.

## Cechy API

* **Brak klasycznej autoryzacji** - API nie wymaga generowania kluczy (API Keys) ani tokenów OAuth. Dostęp jest kontrolowany przez obowiązkowy parametr `campaign` służący do śledzenia ruchu (patrz niżej).
* **Rozbudowane filtrowanie** - Wyszukiwanie po miastach, technologiach, doświadczeniu i widełkach płacowych.
* **Paginacja i sortowanie** - Pełna kontrola nad pobieranymi danymi.
* **Standaryzacja** - Jasny i przewidywalny format danych (JSON).

## Endpoint Główny

```http
GET https://solid.jobs/public-api/offers/{division}
```

*Dostępne dywizje (division): `IT`, `Engineering`, `Marketing`, `Sales`, `HR`, `Logistics`, `Finances`, `Other`.*

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

API stosuje rate limiting. Przekroczenie limitu zwraca status `429 Too Many Requests`. Zalecamy obsługę tego statusu z mechanizmem retry (np. exponential backoff).

### Opcjonalne parametry wyszukiwania (Query Params)

> **Szczegółowy opis dozwolonych wartości dla poszczególnych parametrów znajdziesz w pliku [DICTIONARIES.md](DICTIONARIES.md).**

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

## Przykłady użycia

W katalogu `/examples` znajdziesz gotowe skrypty pokazujące, jak zintegrować się z API. Każdy przykład działa po sklonowaniu repozytorium — wystarczy przejść do katalogu i uruchomić jedną komendę.

| Język | Wymagania | Katalog | Komenda |
| :--- | :--- | :--- | :--- |
| [JavaScript / Node.js](examples/javascript/fetch_offers.js) | Node.js 18+ | `examples/javascript` | `node fetch_offers.js` |
| [C# / .NET](examples/csharp/Program.cs) | .NET 9 SDK | `examples/csharp` | `dotnet run` |
| [Python](examples/python/fetch_offers.py) | Python 3.8+ | `examples/python` | `pip install -r requirements.txt && python fetch_offers.py` |
| [Go](examples/go/main.go) | Go 1.21+ | `examples/go` | `go run main.go` |
| [Java](examples/java/FetchOffers.java) | Java 11+ | `examples/java` | `java FetchOffers.java` |
| [PHP](examples/php/fetch_offers.php) | PHP 7.4+ | `examples/php` | `php fetch_offers.php` |
| [Ruby](examples/ruby/fetch_offers.rb) | Ruby 2.7+ | `examples/ruby` | `ruby fetch_offers.rb` |
| [Rust](examples/rust/src/main.rs) | Rust 1.70+ | `examples/rust` | `cargo run` |
| [Swift](examples/swift/Sources/main.swift) | Swift 5.9+ | `examples/swift` | `swift run` |

## Kontrybucje i zgłaszanie błędów
Jeśli masz pomysł na rozszerzenie publicznego api o nowe endpointy lub znalazłeś błąd w dokumentacji, otwórz **Issue**.

## Licencja
Ten projekt jest udostępniany na licencji [MIT](LICENSE).
