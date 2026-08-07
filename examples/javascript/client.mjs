const BASE_URL = 'https://solid.jobs';
const API_VERSION = '1.0';
const MAX_RETRIES = 3;

export class SolidJobsClient {
    #baseUrl;
    #apiVersion;
    #maxRetries;

    constructor({ baseUrl = BASE_URL, apiVersion = API_VERSION, maxRetries = MAX_RETRIES } = {}) {
        this.#baseUrl = baseUrl;
        this.#apiVersion = apiVersion;
        this.#maxRetries = maxRetries;
    }

    async getOffers(division, campaign, query = {}) {
        if (!/^[a-z0-9-]{1,64}$/.test(campaign)) {
            throw new Error('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        const url = this.#buildUrl(division, campaign, query);
        const response = await this.#fetchWithRetry(url);

        if (!response.ok) {
            const body = await response.text();
            throw new Error(`HTTP ${response.status}: ${body}`);
        }

        return response.json();
    }

    async getMarketStatistics(scopeKind, scopeKey, campaign, { fields } = {}) {
        if (!/^[a-z0-9-]{1,64}$/.test(campaign)) {
            throw new Error('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        const params = new URLSearchParams({ campaign });
        if (fields?.length) params.set('fields', fields.join(','));

        const url = `${this.#baseUrl}/public-api/market-statistics/${scopeKind}/${scopeKey}?${params}`;
        const response = await this.#fetchWithRetry(url);

        if (!response.ok) {
            const body = await response.text();
            throw new Error(`HTTP ${response.status}: ${body}`);
        }

        return response.json();
    }

    async getMarketRaport(scopeKey, campaign) {
        if (!/^[a-z0-9-]{1,64}$/.test(campaign)) {
            throw new Error('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        const params = new URLSearchParams({ campaign });

        const url = `${this.#baseUrl}/public-api/market-statistics/raport/${scopeKey}?${params}`;
        const response = await this.#fetchWithRetry(url);

        if (!response.ok) {
            const body = await response.text();
            throw new Error(`HTTP ${response.status}: ${body}`);
        }

        return response.json();
    }

    async *getAllOffers(division, campaign, query = {}) {
        let pageIndex = query.pageIndex ?? 0;

        while (true) {
            const page = await this.getOffers(division, campaign, { ...query, pageIndex });

            for (const job of page.jobs) {
                yield job;
            }

            pageIndex++;
            if (page.jobs.length === 0 || pageIndex >= page.totalPages) break;
        }
    }

    async #fetchWithRetry(url) {
        for (let attempt = 0; ; attempt++) {
            const response = await fetch(url, {
                headers: { 'X-Api-Version': this.#apiVersion },
            });

            if (response.status !== 429 || attempt >= this.#maxRetries) {
                return response;
            }

            const retryAfter = response.headers.get('Retry-After');
            const delay = retryAfter ? parseInt(retryAfter, 10) * 1000 : Math.pow(2, attempt) * 1000;
            console.warn(`Rate limited (429). Retrying in ${delay / 1000}s...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }

    #buildUrl(division, campaign, query) {
        const params = new URLSearchParams({ campaign });

        if (query.pageIndex > 0) params.set('pageIndex', query.pageIndex);
        if (query.pageSize) params.set('pageSize', query.pageSize);
        if (query.sortActive) {
            params.set('sortActive', query.sortActive);
            params.set('sortDirection', query.sortDirection ?? 'asc');
        }
        if (query.cities) params.set('search.cities', query.cities.join(','));
        for (const cat of query.categories ?? []) params.append('search.categories', cat);
        for (const sub of query.subCategories ?? []) params.append('search.subCategories', sub);
        for (const exp of query.experiences ?? []) params.append('search.experiences', exp);
        for (const term of query.searchTerms ?? []) params.append('search.searchTerm', term);
        if (query.minimumSalary) params.set('search.minimumSalary', query.minimumSalary);

        return `${this.#baseUrl}/public-api/offers/${division}?${params}`;
    }
}
