package main

import (
	"fmt"
	"os"
)

func formatSalary(s Salary) string {
	if s.From == nil && s.To == nil {
		return fmt.Sprintf("no range (%s)", s.Currency)
	}
	from, to := float64(0), float64(0)
	if s.From != nil {
		from = *s.From
	}
	if s.To != nil {
		to = *s.To
	}
	return fmt.Sprintf("%.0f-%.0f %s/%s", from, to, s.Currency, s.Period)
}

func main() {
	// `go run . stats` runs the market-statistics demo instead of the offers demo.
	if len(os.Args) > 1 && os.Args[1] == "stats" {
		runStatisticsDemo()
		return
	}

	// `go run . raport` runs the yearly market-raport demo.
	if len(os.Args) > 1 && os.Args[1] == "raport" {
		runRaportDemo()
		return
	}

	client := NewClient()
	campaign := "go-client"

	// 1) Basic listing — first page of IT offers
	firstPage, err := client.GetOffers("IT", campaign, OfferQuery{PageSize: 5})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Found %d offers (pages: %d).\n", firstPage.TotalCount, firstPage.TotalPages)
	for _, job := range firstPage.Jobs {
		fmt.Printf("%s @ %s [%s] (%s)\n", job.Title, job.Company, job.ExperienceLevel, formatSalary(job.Salary))
	}

	// 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
	seniorJava, err := client.GetOffers("IT", campaign, OfferQuery{
		SearchTerms:   []string{"java"},
		Cities:        []string{"Warszawa"},
		SubCategories: []string{"Java"},
		Experiences:   []string{"Senior"},
		MinimumSalary: 15000,
		SortActive:    "salaryTo",
		SortDirection:  "desc",
		PageSize:      10,
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("\nSenior Java in Warsaw: %d offers\n", seniorJava.TotalCount)
	for _, job := range seniorJava.Jobs {
		fmt.Printf("- %s (%s)\n", job.Title, formatSalary(job.Salary))
	}

	// 3) Iterate all .NET offers
	fmt.Println("\nAll .NET offers:")
	allDotNet, err := client.GetAllOffers("IT", campaign, OfferQuery{SubCategories: []string{"DotNet"}})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	for i, job := range allDotNet {
		fmt.Printf("%3d. %s @ %s\n", i+1, job.Title, job.Company)
	}
	fmt.Printf("Total: %d\n", len(allDotNet))
}
