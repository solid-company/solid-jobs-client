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
	// Omitted by the API when the year has no data at all for that contract type.
	SalaryB2B *RaportSalaryStat `json:"salaryB2B"`
	SalaryUoP *RaportSalaryStat `json:"salaryUoP"`
	// Most required skills that year, descending by Count, up to 100 entries.
	// Empty (never omitted) when there's no data.
	TopSkills []RaportSkill `json:"topSkills"`
	// Per-quarter breakdown of the same year, oldest first.
	Quarters []RaportQuarter `json:"quarters"`
}

// RaportQuarter is a single calendar quarter within a RaportYear. Same shape and omission
// rules as the year itself, just scoped to the quarter — there is no TopSkills at this level.
type RaportQuarter struct {
	Quarter      int                   `json:"quarter"`
	OfferCount   int                   `json:"offerCount"`
	ContractType ContractTypeBreakdown `json:"contractType"`
	Seniority    SeniorityBreakdown    `json:"seniority"`
	// Omitted by the API when the quarter has no data at all for that contract type.
	SalaryB2B *RaportSalaryStat `json:"salaryB2B"`
	SalaryUoP *RaportSalaryStat `json:"salaryUoP"`
}

// Total is the denominator of every Percentage in the breakdown — it is NOT OfferCount.
// Offers proposing neither B2B nor a permanent contract fall outside all three buckets.
// Used both at year level and nested inside each SeniorityNode.
type ContractTypeBreakdown struct {
	B2BOnly       CountWithPercentage `json:"b2bOnly"`
	PermanentOnly CountWithPercentage `json:"permanentOnly"`
	Both          CountWithPercentage `json:"both"`
	Total         int                 `json:"total"`
}

// Total is the sum of the three levels' Count — it is NOT OfferCount.
// Offers with no declared experience level fall outside all three levels.
type SeniorityBreakdown struct {
	Junior  SeniorityNode `json:"junior"`
	Regular SeniorityNode `json:"regular"`
	Senior  SeniorityNode `json:"senior"`
	Total   int           `json:"total"`
}

// One experience level's count, percentage, and its own independent contract-type split.
type SeniorityNode struct {
	Count        int                   `json:"count"`
	Percentage   int                   `json:"percentage"`
	ContractType ContractTypeBreakdown `json:"contractType"`
}

type CountWithPercentage struct {
	Count      int `json:"count"`
	Percentage int `json:"percentage"`
}

// Salary levels for one contract type in one year, keyed by seniority. When present, all three
// seniority keys are always populated — a seniority with no matching offers still appears, with
// every field at zero.
type RaportSalaryStat struct {
	Junior  RaportSalaryBand `json:"junior"`
	Regular RaportSalaryBand `json:"regular"`
	Senior  RaportSalaryBand `json:"senior"`
}

// Salary band for one seniority level in one year. Monthly amounts in PLN. Figures are a range,
// not a single point estimate — pooled from both ends of every matching salary range.
type RaportSalaryBand struct {
	MedianLower  float64 `json:"medianLower"`
	MedianUpper  float64 `json:"medianUpper"`
	AverageLower float64 `json:"averageLower"`
	AverageUpper float64 `json:"averageUpper"`
	// Number of salary ranges behind the figures for this seniority — NOT a distinct offer count.
	// All fields are zero when this seniority has no salary data that year.
	SalaryRangeCount int `json:"salaryRangeCount"`
}

// One skill and how many offers required it in a given year.
type RaportSkill struct {
	Name  string `json:"name"`
	Count int    `json:"count"`
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

func printRaportSeniorityNode(label string, node SeniorityNode) {
	fmt.Printf("    %-16s %5d offers  (%d%% of seniority.total)\n", label, node.Count, node.Percentage)
	c := node.ContractType
	printRaportBucket("  b2bOnly", c.B2BOnly, c.Total)
	printRaportBucket("  permanentOnly", c.PermanentOnly, c.Total)
	printRaportBucket("  both", c.Both, c.Total)
}

func printRaportSalaryBand(label string, band RaportSalaryBand) {
	fmt.Printf("    %-14s median=%.0f..%.0f  average=%.0f..%.0f  ranges=%d\n",
		label, band.MedianLower, band.MedianUpper, band.AverageLower, band.AverageUpper, band.SalaryRangeCount)
}

func printRaportSalary(label string, salary *RaportSalaryStat) {
	if salary == nil {
		fmt.Printf("    %s: (no data for this year)\n", label)
		return
	}
	printRaportSalaryBand(label+" junior", salary.Junior)
	printRaportSalaryBand(label+" regular", salary.Regular)
	printRaportSalaryBand(label+" senior", salary.Senior)
}

func printRaportYear(year RaportYear) {
	fmt.Printf("\n[%d]  offerCount=%d\n", year.Year, year.OfferCount)

	// Every Total below is an independent denominator — none of them equal OfferCount or each other.
	c := year.ContractType
	fmt.Printf("  contractType (total=%d, offerCount=%d):\n", c.Total, year.OfferCount)
	printRaportBucket("b2bOnly", c.B2BOnly, c.Total)
	printRaportBucket("permanentOnly", c.PermanentOnly, c.Total)
	printRaportBucket("both", c.Both, c.Total)

	s := year.Seniority
	fmt.Printf("  seniority (total=%d, offerCount=%d):\n", s.Total, year.OfferCount)
	printRaportSeniorityNode("junior", s.Junior)
	printRaportSeniorityNode("regular", s.Regular)
	printRaportSeniorityNode("senior", s.Senior)

	fmt.Println("  salary (PLN, per seniority — lower..upper band):")
	printRaportSalary("B2B", year.SalaryB2B)
	printRaportSalary("UoP", year.SalaryUoP)

	fmt.Printf("  topSkills (%d):\n", len(year.TopSkills))
	for i, skill := range year.TopSkills {
		if i >= 10 {
			break
		}
		fmt.Printf("    %-20s %d offers\n", skill.Name, skill.Count)
	}

	fmt.Printf("  quarters (%d):\n", len(year.Quarters))
	for _, quarter := range year.Quarters {
		printRaportQuarter(quarter)
	}
}

func printRaportQuarter(quarter RaportQuarter) {
	fmt.Printf("    Q%d  offerCount=%d\n", quarter.Quarter, quarter.OfferCount)

	// Same independent-denominator caveat as at year level, scoped to the quarter.
	c := quarter.ContractType
	fmt.Printf("      contractType (total=%d, offerCount=%d):\n", c.Total, quarter.OfferCount)
	printRaportBucket("b2bOnly", c.B2BOnly, c.Total)
	printRaportBucket("permanentOnly", c.PermanentOnly, c.Total)
	printRaportBucket("both", c.Both, c.Total)

	s := quarter.Seniority
	fmt.Printf("      seniority (total=%d, offerCount=%d):\n", s.Total, quarter.OfferCount)
	printRaportSeniorityNode("junior", s.Junior)
	printRaportSeniorityNode("regular", s.Regular)
	printRaportSeniorityNode("senior", s.Senior)

	fmt.Println("      salary (PLN, per seniority — lower..upper band):")
	printRaportSalary("B2B", quarter.SalaryB2B)
	printRaportSalary("UoP", quarter.SalaryUoP)
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
