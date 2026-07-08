"""SolidJobs Public API Client"""

from __future__ import annotations

import re
import time
from typing import Any, Dict, Generator, List, Optional

import requests

BASE_URL = "https://solid.jobs"
API_VERSION = "1.0"
MAX_RETRIES = 3
CAMPAIGN_RE = re.compile(r"^[a-z0-9-]{1,64}$")


class SolidJobsClient:
    def __init__(
        self,
        base_url: str = BASE_URL,
        api_version: str = API_VERSION,
        max_retries: int = MAX_RETRIES,
    ):
        self._base_url = base_url
        self._session = requests.Session()
        self._session.headers["X-Api-Version"] = api_version
        self._max_retries = max_retries

    def get_offers(
        self,
        division: str,
        campaign: str,
        *,
        page_index: int = 0,
        page_size: Optional[int] = None,
        sort_active: Optional[str] = None,
        sort_direction: str = "asc",
        cities: Optional[List[str]] = None,
        categories: Optional[List[str]] = None,
        sub_categories: Optional[List[str]] = None,
        experiences: Optional[List[str]] = None,
        search_terms: Optional[List[str]] = None,
        minimum_salary: Optional[int] = None,
    ) -> Dict[str, Any]:
        if not CAMPAIGN_RE.match(campaign):
            raise ValueError("Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).")

        params: Dict[str, Any] = {"campaign": campaign}

        if page_index > 0:
            params["pageIndex"] = page_index
        if page_size is not None:
            params["pageSize"] = page_size
        if sort_active:
            params["sortActive"] = sort_active
            params["sortDirection"] = sort_direction
        if cities:
            params["search.cities"] = ",".join(cities)
        if categories:
            params["search.categories"] = categories
        if sub_categories:
            params["search.subCategories"] = sub_categories
        if experiences:
            params["search.experiences"] = experiences
        if search_terms:
            params["search.searchTerm"] = search_terms
        if minimum_salary is not None:
            params["search.minimumSalary"] = minimum_salary

        url = f"{self._base_url}/public-api/offers/{division}"
        response = self._request_with_retry(url, params)
        response.raise_for_status()
        return response.json()

    def get_market_statistics(
        self,
        scope_kind: str,
        scope_key: str,
        campaign: str,
        *,
        fields: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        if not CAMPAIGN_RE.match(campaign):
            raise ValueError("Campaign must contain only lowercase letters, digits and hyphens (max 64 chars).")

        params: Dict[str, Any] = {"campaign": campaign}
        if fields:
            params["fields"] = ",".join(fields)

        url = f"{self._base_url}/public-api/market-statistics/{scope_kind}/{scope_key}"
        response = self._request_with_retry(url, params)
        response.raise_for_status()
        return response.json()

    def get_all_offers(self, division: str, campaign: str, **kwargs) -> Generator[Dict[str, Any], None, None]:
        page_index = kwargs.pop("page_index", 0)

        while True:
            page = self.get_offers(division, campaign, page_index=page_index, **kwargs)

            for job in page["jobs"]:
                yield job

            page_index += 1
            if not page["jobs"] or page_index >= page["totalPages"]:
                break

    def _request_with_retry(self, url: str, params: Dict[str, Any]) -> requests.Response:
        response = None
        for attempt in range(self._max_retries + 1):
            response = self._session.get(url, params=params)

            if response.status_code != 429 or attempt >= self._max_retries:
                return response

            retry_after = response.headers.get("Retry-After")
            delay = int(retry_after) if retry_after else 2**attempt
            print(f"Rate limited (429). Retrying in {delay}s...")
            time.sleep(delay)

        return response
