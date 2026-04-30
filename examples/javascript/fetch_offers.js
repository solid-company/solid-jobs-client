async function getOffers() {
    const params = new URLSearchParams({
        campaign: 'js-client',
        pageSize: 5
    });

    const response = await fetch(`https://solid.jobs/public-api/offers/IT?${params}`);
    const data = await response.json();

    console.log(`Znaleziono ${data.totalCount} ofert.`);
    data.jobs.forEach(job => {
        console.log(`${job.title} @ ${job.company} (${job.salary.from}-${job.salary.to} ${job.salary.currency})`);
    });
}

getOffers();