# SOLID.Jobs - Public API Client

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Przykładowy klient, który pozwala na pobranie publicznych ofert pracy z portalu [SOLID.Jobs](https://solid.jobs).

API zostało zaprojektowane z myślą o zewnętrznych integratorach, agregatorach ofert pracy oraz osobach chcących budować własne interfejsy i analizy rynku IT.

## Cechy API

* **Brak autoryzacji (No-Auth)** - API jest całkowicie publiczne i nie wymaga generowania kluczy (API Keys) ani tokenów OAuth.
* **Rozbudowane filtrowanie** - Wyszukiwanie po miastach, technologiach, doświadczeniu i widełkach płacowych.
* **Paginacja i sortowanie** - Pełna kontrola nad pobieranymi danymi.
* **Standaryzacja** - Jasny i przewidywalny format danych (JSON).

## Endpoint Główny

\`\`\`http
GET https://solid.jobs/api/public-api/offers/{division}
\`\`\`
*Dostępne dywizje (division): `IT`, `Engineering`, `Marketing`, `Sales`, `HR`, `Logistics`, `Finances`, `Other`.*

### Wymagany parametr: `campaign`
Mimo braku klasycznej autoryzacji, każde żądanie **musi** zawierać parametr query `campaign`. Służy on do analityki ruchu po naszej stronie.
* Wartość: Twój unikalny identyfikator (np. nazwa firmy, nazwa bota, id integracji).
* Format: Tylko małe litery, cyfry i myślniki. Maksymalnie 64 znaki.
* Przykład: `?campaign=moj-super-agregator`

### Opcjonalne parametry wyszukiwania (Query Params)

> **Szczegółowy opis dozwolonych wartości dla poszczególnych parametrów znajdziesz w pliku [DICTIONARIES.md](DICTIONARIES.md).**

| Parametr | Typ | Opis | Przykład |
| :--- | :--- | :--- | :--- |
| `pageIndex` | int | Indeks strony (od 0, domyślnie 0). | `0` |
| `pageSize` | int | Rozmiar strony (domyślnie 30, max 500). | `50` |
| `sortActive` | string | Pole do sortowania (np. `validFrom`, `salaryTo`). | `validFrom` |
| `sortDirection` | string | Kierunek sortowania (`asc` lub `desc`). | `desc` |
| `search.cities` | string | Miasta po przecinku. | `Poznań,Warszawa` |
| `search.categories` | string[] | Kategorie główne. | `Backend` |
| `search.experiences` | string[] | Poziom doświadczenia. | `Mid,Senior` |
| `search.minimumSalary` | int | Dolna granica dla górnych widełek. | `20000` |

---

## Przykłady użycia

W katalogu `/examples` znajdziesz gotowe skrypty pokazujące, jak zintegrować się z API:

1. [Node.js (JavaScript / Fetch API)](#przykład-javascript--nodejs)
2. [.NET C# (Console App)](#przykład-c-net)
3. [Python (Requests)](#przykład-python)

## Kontrybucje i zgłaszanie błędów
Jeśli masz pomysł na rozszerzenie publicznego api o nowe endpointy lub znalazłeś błąd w dokumentacji, otwórz **Issue**.

## Licencja
Ten projekt jest udostępniany na licencji [MIT](LICENSE).