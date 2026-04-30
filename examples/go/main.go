package main

import (
	"encoding/json"
	"fmt"
	"net/http"
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
	resp, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	var data Response
	json.NewDecoder(resp.Body).Decode(&data)

	fmt.Printf("Znaleziono %d ofert.\n", data.TotalCount)
	for _, job := range data.Jobs {
		fmt.Printf("%s @ %s (%d-%d %s)\n", job.Title, job.Company, job.Salary.From, job.Salary.To, job.Salary.Currency)
	}
}