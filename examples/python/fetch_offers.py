import requests

url = "https://solid.jobs/public-api/offers/IT"
params = {
    "campaign": "python-client",
    "search.cities": "Kraków",
    "pageSize": 5
}

headers = {"X-Api-Version": "1.0"}

response = requests.get(url, params=params, headers=headers)
response.raise_for_status()

data = response.json()
print(f"Znaleziono {data['totalCount']} ofert.")

for job in data['jobs']:
    salary = job['salary']
    print(f"{job['title']} @ {job['company']} ({salary['from']}-{salary['to']} {salary['currency']})")
