import { SolidJobsClient } from './client.mjs';

const client = new SolidJobsClient();
const campaign = 'js-stats';

// ─────────────────────────────────────────────────────────────────────────────
//  Printing helpers — walk every field the endpoint can return.
// ─────────────────────────────────────────────────────────────────────────────

function printBand(band) {
    if (!band) return console.log('    (no offers with a declared salary)');
    console.log(`    min=${band.min}  p25=${band.p25}  median=${band.median}  p75=${band.p75}  max=${band.max}`);
}

function printContractSalary(label, stat) {
    if (!stat) return console.log(`    ${label}: (no precomputed data)`);
    console.log(`    ${label}: median=${stat.median}  average=${stat.average}  offers=${stat.offerCount}`);
}

function printBuckets(buckets) {
    for (const b of buckets ?? []) {
        console.log(`    ${b.label.padEnd(24)} ${String(b.offerCount).padStart(5)} offers  (${b.percentage}%)`);
    }
}

function printStatistics(stats) {
    console.log(`Scope:            ${stats.scopeKind} / ${stats.scopeKey}`);
    console.log(`Generated at:     ${stats.generatedAt}`);
    console.log(`Included sections: ${stats.includedSections.join(', ')}`);

    if (stats.demand) {
        const d = stats.demand;
        console.log('\n[demand]');
        console.log(`  activeOffers=${d.activeOffers}  distinctEmployers=${d.distinctEmployers}` +
            `  remoteOffers=${d.remoteOffers}  remotePercentage=${d.remotePercentage}%`);
        console.log('  offerTrend (quarterly):');
        for (const point of d.offerTrend) {
            console.log(`    ${point.period}: ${point.offerCount} offers`);
        }
    }

    if (stats.salary) {
        const s = stats.salary;
        console.log(`\n[salary] currency=${s.currency}`);
        console.log('  overall (live percentiles):');
        printBand(s.overall);
        printContractSalary('b2b       ', s.b2b);
        printContractSalary('permanent ', s.permanent);
    }

    if (stats.experience) {
        console.log('\n[experience]');
        printBuckets(stats.experience);
    }

    if (stats.topLocations) {
        console.log('\n[topLocations]');
        printBuckets(stats.topLocations);
    }

    if (stats.topSkills) {
        console.log('\n[topSkills]');
        printBuckets(stats.topSkills);
    }
}

// 1) Full snapshot — every section available for the React specialization
const full = await client.getMarketStatistics('subcategory', 'React', campaign);
printStatistics(full);

// 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
//    `includedSections` in the response confirms exactly what came back.
console.log('\n───────────────────────────────────────────────');
console.log('Partial fetch with fields=demand,salary:');
const partial = await client.getMarketStatistics('subcategory', 'React', campaign, {
    fields: ['demand', 'salary'],
});
console.log(`Included sections: ${partial.includedSections.join(', ')}`);
