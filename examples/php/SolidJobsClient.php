<?php

class SolidJobsClient
{
    private string $baseUrl;
    private string $apiVersion;
    private int $maxRetries;

    public function __construct(
        string $baseUrl = 'https://solid.jobs',
        string $apiVersion = '1.0',
        int $maxRetries = 3
    ) {
        $this->baseUrl = $baseUrl;
        $this->apiVersion = $apiVersion;
        $this->maxRetries = $maxRetries;
    }

    public function getOffers(string $division, string $campaign, array $query = []): array
    {
        if (!preg_match('/^[a-z0-9-]{1,64}$/', $campaign)) {
            throw new InvalidArgumentException('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        $url = $this->buildUrl($division, $campaign, $query);
        $body = $this->requestWithRetry($url);

        return json_decode($body, true);
    }

    public function getAllOffers(string $division, string $campaign, array $query = []): array
    {
        $all = [];
        $pageIndex = $query['pageIndex'] ?? 0;

        while (true) {
            $query['pageIndex'] = $pageIndex;
            $page = $this->getOffers($division, $campaign, $query);

            foreach ($page['jobs'] as $job) {
                $all[] = $job;
            }

            $pageIndex++;
            if (empty($page['jobs']) || $pageIndex >= $page['totalPages']) {
                break;
            }
        }

        return $all;
    }

    public function getMarketStatistics(string $scopeKind, string $scopeKey, string $campaign, array $fields = []): array
    {
        if (!preg_match('/^[a-z0-9-]{1,64}$/', $campaign)) {
            throw new InvalidArgumentException('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        $params = ['campaign' => $campaign];
        if (!empty($fields)) {
            $params['fields'] = implode(',', $fields);
        }

        $url = "{$this->baseUrl}/public-api/market-statistics/"
            . rawurlencode($scopeKind) . '/' . rawurlencode($scopeKey)
            . '?' . http_build_query($params);

        $body = $this->requestWithRetry($url);

        return json_decode($body, true);
    }

    public function getMarketRaport(string $scopeKey, string $campaign): array
    {
        if (!preg_match('/^[a-z0-9-]{1,64}$/', $campaign)) {
            throw new InvalidArgumentException('Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).');
        }

        $params = ['campaign' => $campaign];

        $url = "{$this->baseUrl}/public-api/market-statistics/raport/"
            . rawurlencode($scopeKey)
            . '?' . http_build_query($params);

        $body = $this->requestWithRetry($url);

        return json_decode($body, true);
    }

    private function requestWithRetry(string $url): string
    {
        for ($attempt = 0; ; $attempt++) {
            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 30);
            curl_setopt($ch, CURLOPT_HTTPHEADER, ["X-Api-Version: {$this->apiVersion}"]);

            $headers = [];
            curl_setopt($ch, CURLOPT_HEADERFUNCTION, function ($ch, $header) use (&$headers) {
                $parts = explode(':', $header, 2);
                if (count($parts) === 2) {
                    $headers[strtolower(trim($parts[0]))] = trim($parts[1]);
                }
                return strlen($header);
            });

            $body = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            curl_close($ch);

            if ($curlError) {
                throw new RuntimeException("Network error: $curlError");
            }

            if ($httpCode !== 429 || $attempt >= $this->maxRetries) {
                if ($httpCode !== 200) {
                    throw new RuntimeException("HTTP $httpCode: $body");
                }
                return $body;
            }

            $delay = isset($headers['retry-after']) ? (int) $headers['retry-after'] : pow(2, $attempt);
            fwrite(STDERR, "Rate limited (429). Retrying in {$delay}s...\n");
            sleep($delay);
        }
    }

    private function buildUrl(string $division, string $campaign, array $query): string
    {
        $params = ['campaign' => $campaign];

        if (($query['pageIndex'] ?? 0) > 0) {
            $params['pageIndex'] = $query['pageIndex'];
        }
        if (isset($query['pageSize'])) {
            $params['pageSize'] = $query['pageSize'];
        }
        if (isset($query['sortActive'])) {
            $params['sortActive'] = $query['sortActive'];
            $params['sortDirection'] = $query['sortDirection'] ?? 'asc';
        }
        if (!empty($query['cities'])) {
            $params['search.cities'] = implode(',', $query['cities']);
        }

        $queryString = http_build_query($params);

        foreach (['categories' => 'search.categories', 'subCategories' => 'search.subCategories',
                   'experiences' => 'search.experiences', 'searchTerms' => 'search.searchTerm'] as $key => $param) {
            foreach ($query[$key] ?? [] as $value) {
                $queryString .= '&' . urlencode($param) . '=' . urlencode($value);
            }
        }

        if (isset($query['minimumSalary'])) {
            $queryString .= '&search.minimumSalary=' . (int) $query['minimumSalary'];
        }

        return "{$this->baseUrl}/public-api/offers/{$division}?{$queryString}";
    }
}
