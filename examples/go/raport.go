package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
)

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET RAPORT — MODELS
// ─────────────────────────────────────────────────────────────────────────────

type MarketRaportResponse struct {
	ScopeKey    string       `json:"scopeKey"`
	GeneratedAt string       `json:"generatedAt"`
	Years       []RaportYear `json:"years"`
}

type RaportYear struct {
	Year         int                   `json:"year"`
	OfferCount   int                   `json:"offerCount"`
	ContractType ContractTypeBreakdown `json:"contractType"`
	Seniority    SeniorityBreakdown    `json:"seniority"`
	// Omitted by the API when the year has no data for that contract type.
	SalaryB2B *RaportSalary `json:"salaryB2B"`
	SalaryUoP *RaportSalary `json:"salaryUoP"`
}

// Total is the denominator of every Percentage in the breakdown — it is NOT OfferCount.
// Offers proposing neither B2B nor a permanent contract fall outside all three buckets.
type ContractTypeBreakdown struct {
	B2BOnly       CountWithPercentage `json:"b2bOnly"`
	PermanentOnly CountWithPercentage `json:"permanentOnly"`
	Both          CountWithPercentage `json:"both"`
	Total         int                 `json:"total"`
}

// Total is the denominator of every Percentage in the breakdown — it is NOT OfferCount.
// Offers with no declared experience level fall outside all three buckets.
type SeniorityBreakdown struct {
	Junior  CountWithPercentage `json:"junior"`
	Regular CountWithPercentage `json:"regular"`
	Senior  CountWithPercentage `json:"senior"`
	Total   int                 `json:"total"`
}

type CountWithPercentage struct {
	Count      int `json:"count"`
	Percentage int `json:"percentage"`
}

type RaportSalary struct {
	Median  float64 `json:"median"`
	Average float64 `json:"average"`
	// Number of salary ranges behind the figures — NOT a distinct offer count.
	SalaryRangeCount int `json:"salaryRangeCount"`
}

// ─────────────────────────────────────────────────────────────────────────────
//  CLIENT METHOD
// ─────────────────────────────────────────────────────────────────────────────

// GetMarketRaport fetches the yearly market report for a single role.
// Unlike GetMarketStatistics there is no scopeKind and no fields filter —
// the report always comes back whole, up to 3 calendar years, oldest first.
func (c *SolidJobsClient) GetMarketRaport(scopeKey, campaign string) (*MarketRaportResponse, error) {
	if !campaignRe.MatchString(campaign) {
		return nil, fmt.Errorf("campaign must contain only lowercase letters, digits and hyphens (max 64 chars)")
	}

	params := url.Values{}
	params.Set("campaign", campaign)

	reqURL := fmt.Sprintf("%s/public-api/market-statistics/raport/%s?%s", c.BaseURL, scopeKey, params.Encode())

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
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}

	var result MarketRaportResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding JSON: %w", err)
	}
	return &result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
//  DEMO
// ─────────────────────────────────────────────────────────────────────────────

func printRaportBucket(label string, bucket CountWithPercentage, total int) {
	fmt.Printf("    %-16s %5d offers  (%d%% of %d)\n", label, bucket.Count, bucket.Percentage, total)
}

func printRaportSalary(label string, salary *RaportSalary) {
	if salary == nil {
		fmt.Printf("    %s: (no data for this year)\n", label)
		return
	}
	fmt.Printf("    %s: median=%.0f  average=%.0f  ranges=%d\n", label, salary.Median, salary.Average, salary.SalaryRangeCount)
}

func printRaportYear(year RaportYear) {
	fmt.Printf("\n[%d]  offerCount=%d\n", year.Year, year.OfferCount)

	c := year.ContractType
	fmt.Printf("  contractType (total=%d, offerCount=%d):\n", c.Total, year.OfferCount)
	printRaportBucket("b2bOnly", c.B2BOnly, c.Total)
	printRaportBucket("permanentOnly", c.PermanentOnly, c.Total)
	printRaportBucket("both", c.Both, c.Total)

	s := year.Seniority
	fmt.Printf("  seniority (total=%d, offerCount=%d):\n", s.Total, year.OfferCount)
	printRaportBucket("junior", s.Junior, s.Total)
	printRaportBucket("regular", s.Regular, s.Total)
	printRaportBucket("senior", s.Senior, s.Total)

	fmt.Println("  salary (monthly, PLN):")
	printRaportSalary("B2B", year.SalaryB2B)
	printRaportSalary("UoP", year.SalaryUoP)
}

func runRaportDemo() {
	client := NewClient()
	campaign := "go-raport"

	raport, err := client.GetMarketRaport("ManualTester", campaign)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Role:         %s\n", raport.ScopeKey)
	fmt.Printf("Generated at: %s\n", raport.GeneratedAt)
	fmt.Printf("Years:        %d\n", len(raport.Years))

	for _, year := range raport.Years {
		printRaportYear(year)
	}
}
