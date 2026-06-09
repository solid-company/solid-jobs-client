package main

import (
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

// ─────────────────────────────────────────────────────────────────────────────
//  CLIENT
// ─────────────────────────────────────────────────────────────────────────────

type SolidJobsClient struct {
	BaseURL    string
	APIVersion string
	MaxRetries int
	HTTPClient *http.Client
}

func NewClient() *SolidJobsClient {
	return &SolidJobsClient{
		BaseURL:    "https://solid.jobs",
		APIVersion: "1.0",
		MaxRetries: 3,
		HTTPClient: &http.Client{Timeout: 30 * time.Second},
	}
}

func (c *SolidJobsClient) GetOffers(division, campaign string, q OfferQuery) (*OffersResponse, error) {
	reqURL := c.buildURL(division, campaign, q)

	req, err := http.NewRequest(http.MethodGet, reqURL, nil)
	if err != nil {
		return nil, fmt.Errorf("creating request: %w", err)
	}
	req.Header.Set("X-Api-Version", c.APIVersion)

	resp, err := c.doWithRetry(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP %d", resp.StatusCode)
	}

	var result OffersResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding JSON: %w", err)
	}
	return &result, nil
}

func (c *SolidJobsClient) GetAllOffers(division, campaign string, q OfferQuery) ([]JobOffer, error) {
	var all []JobOffer
	pageIndex := q.PageIndex

	for {
		q.PageIndex = pageIndex
		page, err := c.GetOffers(division, campaign, q)
		if err != nil {
			return all, err
		}
		all = append(all, page.Jobs...)
		pageIndex++
		if len(page.Jobs) == 0 || pageIndex >= page.TotalPages {
			break
		}
	}
	return all, nil
}

func (c *SolidJobsClient) doWithRetry(req *http.Request) (*http.Response, error) {
	var resp *http.Response
	var err error

	for attempt := 0; ; attempt++ {
		resp, err = c.HTTPClient.Do(req)
		if err != nil {
			return nil, fmt.Errorf("network error: %w", err)
		}

		if resp.StatusCode != http.StatusTooManyRequests || attempt >= c.MaxRetries {
			return resp, nil
		}

		resp.Body.Close()
		delay := time.Duration(math.Pow(2, float64(attempt))) * time.Second
		if ra := resp.Header.Get("Retry-After"); ra != "" {
			if secs, err := strconv.Atoi(ra); err == nil {
				delay = time.Duration(secs) * time.Second
			}
		}
		fmt.Fprintf(os.Stderr, "Rate limited (429). Retrying in %v...\n", delay)
		time.Sleep(delay)
	}
}

func (c *SolidJobsClient) buildURL(division, campaign string, q OfferQuery) string {
	params := url.Values{}
	params.Set("campaign", campaign)

	if q.PageIndex > 0 {
		params.Set("pageIndex", strconv.Itoa(q.PageIndex))
	}
	if q.PageSize > 0 {
		params.Set("pageSize", strconv.Itoa(q.PageSize))
	}
	if q.SortActive != "" {
		params.Set("sortActive", q.SortActive)
		dir := q.SortDirection
		if dir == "" {
			dir = "asc"
		}
		params.Set("sortDirection", dir)
	}
	if len(q.Cities) > 0 {
		params.Set("search.cities", strings.Join(q.Cities, ","))
	}
	for _, v := range q.Categories {
		params.Add("search.categories", v)
	}
	for _, v := range q.SubCategories {
		params.Add("search.subCategories", v)
	}
	for _, v := range q.Experiences {
		params.Add("search.experiences", v)
	}
	for _, v := range q.SearchTerms {
		params.Add("search.searchTerm", v)
	}
	if q.MinimumSalary > 0 {
		params.Set("search.minimumSalary", strconv.Itoa(q.MinimumSalary))
	}

	return fmt.Sprintf("%s/public-api/offers/%s?%s", c.BaseURL, division, params.Encode())
}
