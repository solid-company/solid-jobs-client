import { SolidJobsClient } from './client.mjs';

const client = new SolidJobsClient();
const campaign = 'js-raport';
const role = 'ManualTester';

// ─────────────────────────────────────────────────────────────────────────────
//  Printing helpers — walk every field the endpoint can return.
// ─────────────────────────────────────────────────────────────────────────────

function printBucket(label, bucket, total) {
    console.log(`    ${label.padEnd(16)} ${String(bucket.count).padStart(5)} offers  (${bucket.percentage}% of ${total})`);
}

function printSalary(label, salary) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
    if (!salary) return console.log(`    ${label}: (no data for this year)`);
    console.log(`    ${label}: median=${salary.median}  average=${salary.average}  ranges=${salary.salaryRangeCount}`);
}

function printYear(year) {
    console.log(`\n[${year.year}]  offerCount=${year.offerCount}`);

    // NOTE: `total` is the denominator of every `percentage` below — and it is NOT `offerCount`.
    // Offers proposing neither B2B nor a permanent contract fall outside contractType, and offers
    // with no declared experience level fall outside seniority.
    const contract = year.contractType;
    console.log(`  contractType (total=${contract.total}, offerCount=${year.offerCount}):`);
    printBucket('b2bOnly', contract.b2bOnly, contract.total);
    printBucket('permanentOnly', contract.permanentOnly, contract.total);
    printBucket('both', contract.both, contract.total);

    const seniority = year.seniority;
    console.log(`  seniority (total=${seniority.total}, offerCount=${year.offerCount}):`);
    printBucket('junior', seniority.junior, seniority.total);
    printBucket('regular', seniority.regular, seniority.total);
    printBucket('senior', seniority.senior, seniority.total);

    console.log('  salary (monthly, PLN):');
    printSalary('B2B', year.salaryB2B);
    printSalary('UoP', year.salaryUoP);
}

// Yearly market report for a single role — up to 3 calendar years, oldest first.
// There is no `fields` parameter here: the report always comes back whole.
const raport = await client.getMarketRaport(role, campaign);

console.log(`Role:         ${raport.scopeKey}`);
console.log(`Generated at: ${raport.generatedAt}`);
console.log(`Years:        ${raport.years.length}`);

for (const year of raport.years) {
    printYear(year);
}
