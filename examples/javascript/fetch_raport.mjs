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

function printSeniorityNode(label, node) {
    console.log(`    ${label.padEnd(16)} ${String(node.count).padStart(5)} offers  (${node.percentage}% of seniority.total)`);
    // Nested contractType has its own independent total — not the seniority level's count.
    const contract = node.contractType;
    printBucket('  b2bOnly', contract.b2bOnly, contract.total);
    printBucket('  permanentOnly', contract.permanentOnly, contract.total);
    printBucket('  both', contract.both, contract.total);
}

function printSalaryBand(label, band) {
    // Zero fields mean this seniority has no salary data that year — the object is still present.
    console.log(`    ${label.padEnd(14)} median=${band.medianLower}..${band.medianUpper}  average=${band.averageLower}..${band.averageUpper}  ranges=${band.salaryRangeCount}`);
}

function printSalary(label, salary) {
    // salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
    if (!salary) return console.log(`    ${label}: (no data for this year)`);
    printSalaryBand(`${label} junior`, salary.junior);
    printSalaryBand(`${label} regular`, salary.regular);
    printSalaryBand(`${label} senior`, salary.senior);
}

function printYear(year) {
    console.log(`\n[${year.year}]  offerCount=${year.offerCount}`);

    // NOTE: every `total` below is an independent denominator — none of them equal `offerCount`
    // or each other. Offers proposing neither B2B nor a permanent contract fall outside
    // contractType, and offers with no declared experience level fall outside seniority.
    const contract = year.contractType;
    console.log(`  contractType (total=${contract.total}, offerCount=${year.offerCount}):`);
    printBucket('b2bOnly', contract.b2bOnly, contract.total);
    printBucket('permanentOnly', contract.permanentOnly, contract.total);
    printBucket('both', contract.both, contract.total);

    const seniority = year.seniority;
    console.log(`  seniority (total=${seniority.total}, offerCount=${year.offerCount}):`);
    printSeniorityNode('junior', seniority.junior);
    printSeniorityNode('regular', seniority.regular);
    printSeniorityNode('senior', seniority.senior);

    console.log('  salary (PLN, per seniority — lower..upper band):');
    printSalary('B2B', year.salaryB2B);
    printSalary('UoP', year.salaryUoP);

    console.log(`  topSkills (${year.topSkills.length}):`);
    for (const skill of year.topSkills.slice(0, 10)) {
        console.log(`    ${skill.name.padEnd(20)} ${skill.count} offers`);
    }

    console.log(`  quarters (${year.quarters.length}):`);
    for (const quarter of year.quarters) {
        printQuarter(quarter);
    }
}

function printQuarter(quarter) {
    console.log(`    Q${quarter.quarter}  offerCount=${quarter.offerCount}`);

    // Same independent-denominator caveat as at year level, scoped to the quarter.
    const contract = quarter.contractType;
    console.log(`      contractType (total=${contract.total}, offerCount=${quarter.offerCount}):`);
    printBucket('b2bOnly', contract.b2bOnly, contract.total);
    printBucket('permanentOnly', contract.permanentOnly, contract.total);
    printBucket('both', contract.both, contract.total);

    const seniority = quarter.seniority;
    console.log(`      seniority (total=${seniority.total}, offerCount=${quarter.offerCount}):`);
    printSeniorityNode('junior', seniority.junior);
    printSeniorityNode('regular', seniority.regular);
    printSeniorityNode('senior', seniority.senior);

    console.log('      salary (PLN, per seniority — lower..upper band):');
    printSalary('B2B', quarter.salaryB2B);
    printSalary('UoP', quarter.salaryUoP);
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
