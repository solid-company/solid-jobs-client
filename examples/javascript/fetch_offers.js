async function getOffers() {
    const params = new URLSearchParams({
        campaign: 'js-client',
        pageSize: 5,
    });

    const response = await fetch(`https://solid.jobs/public-api/offers/IT?${params}`, {
        headers: { 'X-Api-Version': '1.0' },
    });

    if (response.status === 429) {
        console.error('Przekroczono limit zapytań (429). Spróbuj ponownie za chwilę.');
        return;
    }

    if (!response.ok) {
        console.error(`Błąd HTTP: ${response.status}`);
        return;
    }

    const data = await response.json();

    console.log(`Znaleziono ${data.totalCount} ofert.`);
    data.jobs.forEach(job => {
        console.log(`${job.title} @ ${job.company} (${job.salary.from}-${job.salary.to} ${job.salary.currency})`);
    });
}

getOffers();
