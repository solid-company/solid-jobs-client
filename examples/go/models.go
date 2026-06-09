package main

// ─────────────────────────────────────────────────────────────────────────────
//  RESPONSE MODELS
// ─────────────────────────────────────────────────────────────────────────────

type OffersResponse struct {
	Jobs       []JobOffer `json:"jobs"`
	PageIndex  int        `json:"pageIndex"`
	PageSize   int        `json:"pageSize"`
	TotalCount int        `json:"totalCount"`
	TotalPages int        `json:"totalPages"`
}

type JobOffer struct {
	JobOfferKey     string     `json:"jobOfferKey"`
	Title           string     `json:"title"`
	Division        string     `json:"division"`
	Category        string     `json:"category"`
	SubCategory     string     `json:"subCategory"`
	Company         string     `json:"company"`
	CompanyLogoUrl  *string    `json:"companyLogoUrl"`
	Salary          Salary     `json:"salary"`
	SecondarySalary *Salary    `json:"secondarySalary"`
	ContractTime    string     `json:"contractTime"`
	Locations       []string   `json:"locations"`
	Benefits        []string   `json:"benefits"`
	IsRemote        bool       `json:"isRemote"`
	IsHybrid        bool       `json:"isHybrid"`
	URL             string     `json:"url"`
	ExperienceLevel string     `json:"experienceLevel"`
	Skills          []SkillTag `json:"skills"`
	Languages       []SkillTag `json:"languages"`
	Description     string     `json:"description"`
	ValidFrom       string     `json:"validFrom"`
	ValidTo         string     `json:"validTo"`
}

type Salary struct {
	From           *float64 `json:"from"`
	To             *float64 `json:"to"`
	Currency       string   `json:"currency"`
	Period         string   `json:"period"`
	EmploymentType string   `json:"employmentType"`
}

type SkillTag struct {
	Level string `json:"level"`
	Name  string `json:"name"`
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUERY PARAMETERS
// ─────────────────────────────────────────────────────────────────────────────

type OfferQuery struct {
	PageIndex     int
	PageSize      int
	SortActive    string
	SortDirection string
	Cities        []string
	Categories    []string
	SubCategories []string
	Experiences   []string
	SearchTerms   []string
	MinimumSalary int
}
