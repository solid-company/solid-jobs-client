package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

type Response struct {
	TotalCount int `json:"totalCount"`
	Jobs       []struct {
		Title   string `json:"title"`
		Company string `json:"company"`
		Salary  struct {
			From     int    `json:"from"`
			To       int    `json:"to"`
			Currency string `json:"currency"`
		} `json:"salary"`
	} `json:"jobs"`
}

func main() {
	url := "https://solid.jobs/public-api/offers/IT?campaign=go-client&pageSize=5"

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Błąd tworzenia żądania: %v\n", err)
		os.Exit(1)
	}
	req.Header.Set("X-Api-Version", "1.0")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Błąd sieci: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusTooManyRequests {
		fmt.Fprintln(os.Stderr, "Przekroczono limit zapytań (429). Spróbuj ponownie za chwilę.")
		os.Exit(1)
	}

	if resp.StatusCode != http.StatusOK {
		fmt.Fprintf(os.Stderr, "Błąd HTTP: %d\n", resp.StatusCode)
		os.Exit(1)
	}

	var data Response
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		fmt.Fprintf(os.Stderr, "Błąd parsowania JSON: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Znaleziono %d ofert.\n", data.TotalCount)
	for _, job := range data.Jobs {
		fmt.Printf("%s @ %s (%d-%d %s)\n", job.Title, job.Company, job.Salary.From, job.Salary.To, job.Salary.Currency)
	}
}
