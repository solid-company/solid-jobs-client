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
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — nieprawidłowy `dział`:

```
Division not allowed: 'InvalidValue'. Avialable values are: IT, Engineering, Marketing, Sales, HR, Logistics, Finances, Other.
```

**429 Too Many Requests** — przekroczono limit zapytań. Ponów żądanie po krótkiej przerwie.

---

## Endpoint Statystyk Rynku

Zagregowane statystyki rynku pracy dla pojedynczego **zakresu** — działu, kategorii głównej, specjalizacji (podkategorii), grupy podkategorii lub miasta. Podobnie jak endpoint ofert nie wymaga autoryzacji (tylko parametru `campaign`) i zwraca płaski, stabilny kontrakt JSON. Odpowiedzi są cache'owalne do 1 godziny.

```http
GET https://solid.jobs/public-api/market-statistics/{scopeKind}/{scopeKey}?campaign=moj-super-agregator
```

Obowiązują tu te same zasady co wyżej: nagłówek `X-Api-Version: 1.0`, reguły parametru `campaign` oraz limity zapytań (300 zapytań/min na IP, kolejka 10).

### Parametry ścieżki

| Parametr | Typ | Opis |
| :--- | :--- | :--- |
| `scopeKind` | string | Rodzaj zakresu (case-insensitive). Jeden z: `division`, `mainCategory`, `subcategory`, `subcategoryGroup`, `city`. |
| `scopeKey` | string | Konkretna wartość w obrębie rodzaju — patrz mapowanie poniżej. |

**Dozwolone wartości `scopeKey`** (nieznany rodzaj lub klucz zwraca `404`):

| `scopeKind` | Wartość `scopeKey` | Przykład | Dozwolone wartości |
| :--- | :--- | :--- | :--- |
| `division` | Nazwa działu | `IT` | [DICTIONARIES §2](DICTIONARIES.pl.md#2-działy-parametr-ścieżki-division) |
| `mainCategory` | Nazwa kategorii głównej | `Developer` | [DICTIONARIES §3](DICTIONARIES.pl.md#3-kategorie-i-podkategorie-searchcategories-i-searchsubcategories) (kategorie) |
| `subcategory` | Nazwa podkategorii | `React` | [DICTIONARIES §3](DICTIONARIES.pl.md#3-kategorie-i-podkategorie-searchcategories-i-searchsubcategories) (podkategorie) |
| `subcategoryGroup` | Grupa podkategorii | `Frontend` | `Frontend`, `Mobile` ([DICTIONARIES §9](DICTIONARIES.pl.md#9-rodzaje-zakresu-statystyk-scopekind-parametr-ścieżki)) |
| `city` | Slug miasta (małe litery) | `warszawa` | Dowolne miasto obsługiwane przez portal |

### Parametry query

| Parametr | Typ | Wymagany | Opis |
| :--- | :--- | :--- | :--- |
| `campaign` | string | **tak** | Identyfikator ruchu — małe litery, cyfry i myślniki, maks. 64 znaki. |
| `fields` | string | nie | Rozdzielony przecinkami podzbiór sekcji do zwrócenia (case-insensitive): `demand`, `salary`, `experience`, `topLocations`, `topSkills`. Pominięcie zwraca wszystkie sekcje dostępne dla zakresu. |

### Dostępność sekcji

Sekcja `topLocations` jest **niedostępna** dla zakresu `city` (zakres to już pojedyncze miasto). Jawne zażądanie jej dla miasta zwraca `400`; pominięcie `fields` po prostu ją pomija. Pozostałe sekcje są dostępne dla każdego rodzaju zakresu.

### Przykładowa odpowiedź

Poprawna odpowiedź `200 OK` dla `subcategory/React` (wszystkie sekcje):

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

#### Pola najwyższego poziomu

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `scopeKind` | string | Rodzaj zakresu, którego dotyczą statystyki (odzwierciedla żądanie, znormalizowany). |
| `scopeKey` | string | Klucz zakresu w obrębie rodzaju. Rodzaje enumowe zachowują kanoniczną wielkość liter; `city` to slug małymi literami. |
| `generatedAt` | string | Moment wygenerowania (UTC, ISO-8601 z przesunięciem `+00:00`). |
| `includedSections` | string[] | Nazwy sekcji faktycznie obecnych w odpowiedzi — pozwala sprawdzić, co wróciło, gdy część pominięto. |
| `demand` | object | Metryki popytu i zatrudnienia. Pominięte gdy sekcja nieżądana. |
| `salary` | object | Metryki płacowe. Pominięte gdy sekcja nieżądana. |
| `experience` | object[] | Rozkład wg poziomu doświadczenia. Pominięte gdy sekcja nieżądana. |
| `topLocations` | object[] | Rozkład top miast. Pominięte gdy sekcja nieżądana lub niedostępna (zakres `city`). |
| `topSkills` | object[] | Rozkład top umiejętności. Pominięte gdy sekcja nieżądana. |

#### Pola `demand`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `activeOffers` | int | Liczba aktywnych ofert w zakresie. |
| `distinctEmployers` | int | Liczba unikalnych pracodawców publikujących w zakresie. |
| `remoteOffers` | int | Liczba ofert w pełni zdalnych. |
| `remotePercentage` | int | Udział ofert w pełni zdalnych (0–100). |
| `offerTrend` | object[] | Trend liczby ofert kwartalnie (precomputed), do 8 najnowszych kwartałów, od najstarszego. |

#### Pola `offerTrend[]`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `period` | string | Etykieta kwartału w formacie `YYYY-Qn` (np. `2026-Q1`). |
| `offerCount` | int | Liczba ofert w danym kwartale. |

#### Pola `salary`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `currency` | string | Waluta wszystkich kwot poniżej. Zawsze `PLN`. |
| `overall` | object \| null | Widełki policzone na żywo z aktywnych ofert (percentyle). `null` gdy żadna oferta w zakresie nie podaje płacy. |
| `b2b` | object \| null | Precomputed statystyka płac B2B. `null` gdy brak danych. |
| `permanent` | object \| null | Precomputed statystyka płac dla umowy o pracę (UoP). `null` gdy brak danych. |

#### Pola `salary.overall` (widełki)

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `min` | number | Minimum — dolny kraniec widełek. |
| `p25` | number | 25. percentyl. |
| `median` | number | Mediana (50. percentyl). |
| `p75` | number | 75. percentyl. |
| `max` | number | Maksimum — górny kraniec widełek. |

#### Pola `salary.b2b` / `salary.permanent` (statystyka płac)

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `median` | number | Mediana wynagrodzenia dla rodzaju umowy. |
| `average` | number | Średnie wynagrodzenie dla rodzaju umowy. |
| `offerCount` | int | Liczba ofert uwzględnionych w statystyce. |

#### Pola `experience[]`, `topLocations[]`, `topSkills[]` (pozycja rozkładu)

Wszystkie trzy sekcje mają ten sam kształt pozycji:

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `label` | string | Etykieta pozycji — poziom doświadczenia (`experience`), nazwa miasta (`topLocations`) lub nazwa umiejętności (`topSkills`). |
| `offerCount` | int | Liczba aktywnych ofert w tej pozycji. |
| `percentage` | int | Udział względem wszystkich aktywnych ofert zakresu (0–100). |

### Odpowiedzi błędów

**400 Bad Request** — nieprawidłowy lub brakujący `campaign`:

```
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**400 Bad Request** — nieznana sekcja w `fields`:

```
Unknown section 'foo'. Available sections: Demand, Salary, Experience, TopLocations, TopSkills.
```

**400 Bad Request** — żądana sekcja niedostępna dla zakresu (np. `topLocations` dla miasta):

```
Section(s) not available for scope kind 'City': TopLocations. Available for this scope: Demand, Salary, Experience, TopSkills.
```

**404 Not Found** — nieznany `scopeKind` lub `scopeKey` (puste ciało odpowiedzi).

**429 Too Many Requests** — przekroczono limit zapytań. Ponów żądanie po krótkiej przerwie.

---

## Endpoint Raportu Rynkowego

Raport rynkowy rok po roku dla **pojedynczej roli** — liczba ofert, podział na typy umów, podział na poziomy doświadczenia oraz poziomy wynagrodzeń, po jednym wpisie na rok kalendarzowy. W odróżnieniu od endpointu statystyk powyżej **nie ma tu `scopeKind`** (segment ścieżki to zawsze `raport`) ani parametru **`fields`** — raport zawsze zwracany jest w całości. Odpowiedzi można cachować do 1 godziny.

```http
GET https://solid.jobs/public-api/market-statistics/raport/{scopeKey}?campaign=my-awesome-aggregator
```

Obowiązuje ten sam nagłówek `X-Api-Version: 1.0`, te same zasady dla `campaign` oraz te same limity zapytań (300 zapytań/min na IP, kolejka 10), co opisano wyżej.

### Parametry ścieżki

| Parametr | Typ | Opis |
| :--- | :--- | :--- |
| `scopeKey` | string | Rola (specjalizacja), której dotyczy raport, np. `ManualTester`. Wielkość liter nie ma znaczenia; nieznana wartość zwraca `404`. Dozwolone wartości: [DICTIONARIES §3](DICTIONARIES.pl.md#3-kategorie-i-podkategorie-searchcategories-i-searchsubcategories) (podkategorie). |

### Parametry zapytania

| Parametr | Typ | Wymagany | Opis |
| :--- | :--- | :--- | :--- |
| `campaign` | string | **tak** | Identyfikator ruchu — małe litery, cyfry i myślniki, maks. 64 znaki. |

### Zakres czasowy

Raport obejmuje do **3 lat kalendarzowych**, od najstarszego: rok bieżący i dwa poprzednie. Rok bieżący liczony jest od początku roku do dziś, więc jego wartości są naturalnie niższe niż roku zakończonego.

### Przykładowa odpowiedź

Poprawna odpowiedź `200 OK` dla `ManualTester` (skrócona tutaj do dwóch lat):

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

#### Pola najwyższego poziomu

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `scopeKey` | string | Rola, której dotyczy raport (powtórzenie żądania, kanoniczna wielkość liter). |
| `generatedAt` | string | Moment wygenerowania (UTC, ISO-8601 z przesunięciem `+00:00`). |
| `years` | object[] | Po jednym wpisie na rok kalendarzowy, od najstarszego. |

#### Pola `years[]`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `year` | int | Rok kalendarzowy, którego dotyczy wpis. |
| `offerCount` | int | Wszystkie oferty opublikowane w tej roli w danym roku. |
| `contractType` | object | Podział wg typów umów proponowanych w ofercie. |
| `seniority` | object | Podział wg wymaganego poziomu doświadczenia. |
| `salaryB2B` | object | Poziomy wynagrodzeń B2B w danym roku. **Pomijane**, gdy rok nie ma danych B2B. |
| `salaryUoP` | object | Poziomy wynagrodzeń dla umowy o pracę (UoP). **Pomijane**, gdy rok nie ma danych UoP. |

#### Pola `contractType`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `b2bOnly` | object | Oferty proponujące **wyłącznie** B2B. |
| `permanentOnly` | object | Oferty proponujące **wyłącznie** umowę o pracę (UoP). |
| `both` | object | Oferty proponujące **zarówno** B2B, jak i UoP. |
| `total` | int | Suma trzech koszyków — mianownik dla ich `percentage`. Przeczytaj notę niżej: to **nie** jest `offerCount`. |

#### Pola `seniority`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `junior` | object | Oferty wymagające poziomu junior. |
| `regular` | object | Oferty wymagające poziomu regular. |
| `senior` | object | Oferty wymagające poziomu senior. |
| `total` | int | Suma trzech koszyków — mianownik dla ich `percentage`. Przeczytaj notę niżej: to **nie** jest `offerCount`. |

#### Pola koszyka `contractType` / `seniority`

Każdy koszyk w obu podziałach ma ten sam kształt:

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `count` | int | Liczba ofert w tym koszyku. |
| `percentage` | int | Udział względem `total` danego podziału (0–100). |

#### Pola `salaryB2B` / `salaryUoP`

| Pole | Typ | Opis |
| :--- | :--- | :--- |
| `median` | number | Mediana miesięcznego wynagrodzenia w PLN dla danego typu umowy w tym roku. |
| `average` | number | Średnie miesięczne wynagrodzenie w PLN dla danego typu umowy w tym roku. |
| `salaryRangeCount` | int | Liczba widełek stojących za tymi wartościami — **nie** liczba unikalnych ofert, patrz nota niżej. |

### Jak czytać te liczby

Trzy rzeczy, na których naiwna integracja się przewróci:

* **`total` to nie `offerCount`.** Oferta nieproponująca ani B2B, ani umowy o pracę (np. umowa zlecenie) nie trafia do żadnego koszyka `contractType`, a oferta bez określonego poziomu doświadczenia nie trafia do żadnego koszyka `seniority`. Zawsze dziel przez `total` danego podziału, nigdy przez `offerCount`. W przykładzie wyżej rok 2024 ma `offerCount` 170, ale `contractType.total` 165.
* **Procenty zaokrąglane są niezależnie**, więc trzy wartości podziału mogą zsumować się do 99 albo 101 zamiast dokładnie 100.
* **`salaryRangeCount` liczy widełki, nie oferty.** Oferta deklarująca zarówno główne, jak i dodatkowe widełki tego samego typu umowy liczy się dwa razy, więc ta liczba może przewyższyć liczbę ofert w roku.

### Odpowiedzi błędów

**400 Bad Request** — nieprawidłowy lub brakujący `campaign`:

```
Make sure that campaign parameter exists and contains only lowercase letters, numbers and dashes (max 64 chars long).
```

**404 Not Found** — nieznany `scopeKey` (puste ciało odpowiedzi).

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

### Przykłady statystyk rynku

Każdy katalog językowy zawiera także przykład statystyk rynku. Pobiera wszystkie sekcje dla zakresu `subcategory/React`, wypisuje każdą zwróconą wartość, a następnie wykonuje drugie zapytanie z `fields=demand,salary`, aby pokazać filtr sekcji w działaniu.

| Język | Katalog | Komenda |
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

### Przykłady raportu rynkowego

Każdy katalog językowy zawiera także przykład raportu rynkowego. Pobiera roczny raport dla roli `ManualTester` i wypisuje dla każdego roku liczbę ofert, podziały na typ umowy i poziom doświadczenia oraz poziomy wynagrodzeń B2B / UoP.

| Język | Katalog | Komenda |
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

## Kontrybucje i zgłaszanie błędów

Jeśli masz pomysł na rozszerzenie publicznego API o nowe endpointy lub znalazłeś błąd w dokumentacji, otwórz **Issue**.

## Licencja

Ten projekt jest udostępniany na licencji [MIT](LICENSE).
