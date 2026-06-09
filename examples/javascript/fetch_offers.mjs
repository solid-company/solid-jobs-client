import { SolidJobsClient } from './client.mjs';
import { formatSalary } from './helpers.mjs';

const client = new SolidJobsClient();
const campaign = 'js-client';

// 1) Basic listing — first page of IT offers
const firstPage = await client.getOffers('IT', campaign, { pageSize: 5 });
console.log(`Found ${firstPage.totalCount} offers (pages: ${firstPage.totalPages}).`);

for (const job of firstPage.jobs) {
    console.log(`${job.title} @ ${job.company} [${job.experienceLevel}] (${formatSalary(job.salary)})`);
}

// 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
const seniorJava = await client.getOffers('IT', campaign, {
    searchTerms: ['java'],
    cities: ['Warszawa'],
    subCategories: ['Java'],
    experiences: ['Senior'],
    minimumSalary: 15000,
    sortActive: 'salaryTo',
    sortDirection: 'desc',
    pageSize: 10,
});

console.log(`\nSenior Java in Warsaw: ${seniorJava.totalCount} offers`);
for (const job of seniorJava.jobs) {
    console.log(`- ${job.title} (${formatSalary(job.salary)})`);
}

// 3) Iterate all .NET offers using async generator
console.log('\nAll .NET offers:');
let counter = 0;
for await (const job of client.getAllOffers('IT', campaign, { subCategories: ['DotNet'] })) {
    counter++;
    console.log(`${String(counter).padStart(3)}. ${job.title} @ ${job.company}`);
}
console.log(`Total: ${counter}`);
