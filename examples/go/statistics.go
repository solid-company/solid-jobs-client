package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
)

var campaignRe = regexp.MustCompile(`^[a-z0-9-]{1,64}$`)

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET STATISTICS — MODELS
// ─────────────────────────────────────────────────────────────────────────────

type MarketStatisticsResponse struct {
	ScopeKind        string       `json:"scopeKind"`
	ScopeKey         string       `json:"scopeKey"`
	GeneratedAt      string       `json:"generatedAt"`
	IncludedSections []string     `json:"includedSections"`
	Demand           *DemandStats `json:"demand"`
	Salary           *SalaryStats `json:"salary"`
	Experience       []Bucket     `json:"experience"`
	TopLocations     []Bucket     `json:"topLocations"`
	TopSkills        []Bucket     `json:"topSkills"`
}

type DemandStats struct {
	ActiveOffers      int          `json:"activeOffers"`
	DistinctEmployers int          `json:"distinctEmployers"`
	RemoteOffers      int          `json:"remoteOffers"`
	RemotePercentage  int          `json:"remotePercentage"`
	OfferTrend        []TrendPoint `json:"offerTrend"`
}

type TrendPoint struct {
	Period     string `json:"period"`
	OfferCount int    `json:"offerCount"`
}

type SalaryStats struct {
	Currency  string      `json:"currency"`
	Overall   *SalaryBand `json:"overall"`
	B2B       *SalaryStat `json:"b2b"`
	Permanent *SalaryStat `json:"permanent"`
}

type SalaryBand struct {
	Min    float64 `json:"min"`
	P25    float64 `json:"p25"`
	Median float64 `json:"median"`
	P75    float64 `json:"p75"`
	Max    float64 `json:"max"`
}

type SalaryStat struct {
	Median     float64 `json:"median"`
	Average    float64 `json:"average"`
	OfferCount int     `json:"offerCount"`
}

type Bucket struct {
	Label      string `json:"label"`
	OfferCount int    `json:"offerCount"`
	Percentage int    `json:"percentage"`
}

// ─────────────────────────────────────────────────────────────────────────────
//  CLIENT METHOD
// ─────────────────────────────────────────────────────────────────────────────

// GetMarketStatistics fetches labour-market statistics for the given scope.
// fields is an optional subset of sections; nil/empty returns all sections
// available for the scope.
func (c *SolidJobsClient) GetMarketStatistics(scopeKind, scopeKey, campaign string, fields []string) (*MarketStatisticsResponse, error) {
	if !campaignRe.MatchString(campaign) {
		return nil, fmt.Errorf("campaign must contain only lowercase letters, digits and hyphens (max 64 chars)")
	}

	params := url.Values{}
	params.Set("campaign", campaign)
	if len(fields) > 0 {
		params.Set("fields", strings.Join(fields, ","))
	}

	reqURL := fmt.Sprintf("%s/public-api/market-statistics/%s/%s?%s", c.BaseURL, scopeKind, scopeKey, params.Encode())

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

	var result MarketStatisticsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding JSON: %w", err)
	}
	return &result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
//  DEMO
// ─────────────────────────────────────────────────────────────────────────────

func printBand(band *SalaryBand) {
	if band == nil {
		fmt.Println("    (no offers with a declared salary)")
		return
	}
	fmt.Printf("    min=%.0f  p25=%.0f  median=%.0f  p75=%.0f  max=%.0f\n",
		band.Min, band.P25, band.Median, band.P75, band.Max)
}

func printContractSalary(label string, stat *SalaryStat) {
	if stat == nil {
		fmt.Printf("    %s: (no precomputed data)\n", label)
		return
	}
	fmt.Printf("    %s: median=%.0f  average=%.0f  offers=%d\n", label, stat.Median, stat.Average, stat.OfferCount)
}

func printBuckets(buckets []Bucket) {
	for _, b := range buckets {
		fmt.Printf("    %-24s %5d offers  (%d%%)\n", b.Label, b.OfferCount, b.Percentage)
	}
}

func printStatistics(stats *MarketStatisticsResponse) {
	fmt.Printf("Scope:            %s / %s\n", stats.ScopeKind, stats.ScopeKey)
	fmt.Printf("Generated at:     %s\n", stats.GeneratedAt)
	fmt.Printf("Included sections: %s\n", strings.Join(stats.IncludedSections, ", "))

	if d := stats.Demand; d != nil {
		fmt.Println("\n[demand]")
		fmt.Printf("  activeOffers=%d  distinctEmployers=%d  remoteOffers=%d  remotePercentage=%d%%\n",
			d.ActiveOffers, d.DistinctEmployers, d.RemoteOffers, d.RemotePercentage)
		fmt.Println("  offerTrend (quarterly):")
		for _, point := range d.OfferTrend {
			fmt.Printf("    %s: %d offers\n", point.Period, point.OfferCount)
		}
	}

	if s := stats.Salary; s != nil {
		fmt.Printf("\n[salary] currency=%s\n", s.Currency)
		fmt.Println("  overall (live percentiles):")
		printBand(s.Overall)
		printContractSalary("b2b       ", s.B2B)
		printContractSalary("permanent ", s.Permanent)
	}

	if stats.Experience != nil {
		fmt.Println("\n[experience]")
		printBuckets(stats.Experience)
	}

	if stats.TopLocations != nil {
		fmt.Println("\n[topLocations]")
		printBuckets(stats.TopLocations)
	}

	if stats.TopSkills != nil {
		fmt.Println("\n[topSkills]")
		printBuckets(stats.TopSkills)
	}
}

func runStatisticsDemo() {
	client := NewClient()
	campaign := "go-stats"

	// 1) Full snapshot — every section available for the React specialization
	full, err := client.GetMarketStatistics("subcategory", "React", campaign, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	printStatistics(full)

	// 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
	//    IncludedSections in the response confirms exactly what came back.
	fmt.Println("\n───────────────────────────────────────────────")
	fmt.Println("Partial fetch with fields=demand,salary:")
	partial, err := client.GetMarketStatistics("subcategory", "React", campaign, []string{"demand", "salary"})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Included sections: %s\n", strings.Join(partial.IncludedSections, ", "))
}
