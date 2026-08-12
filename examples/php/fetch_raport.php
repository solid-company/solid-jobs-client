<?php

require_once __DIR__ . '/SolidJobsClient.php';

$campaign = 'php-raport';
$role = 'ManualTester';

// ─────────────────────────────────────────────────────────────────────────────
//  Printing helpers — walk every field the endpoint can return.
// ─────────────────────────────────────────────────────────────────────────────

function printBucket(string $label, array $bucket, int $total): void
{
    printf("    %-16s %5d offers  (%d%% of %d)\n", $label, $bucket['count'], $bucket['percentage'], $total);
}

function printSeniorityNode(string $label, array $node): void
{
    printf("    %-16s %5d offers  (%d%% of seniority.total)\n", $label, $node['count'], $node['percentage']);
    // Nested contractType has its own independent total — not the seniority level's count.
    $contract = $node['contractType'];
    printBucket('  b2bOnly', $contract['b2bOnly'], $contract['total']);
    printBucket('  permanentOnly', $contract['permanentOnly'], $contract['total']);
    printBucket('  both', $contract['both'], $contract['total']);
}

function printSalaryBand(string $label, array $band): void
{
    // Zero fields mean this seniority has no salary data that year — the object is still present.
    printf(
        "    %-14s median=%s..%s  average=%s..%s  ranges=%d\n",
        $label,
        $band['medianLower'],
        $band['medianUpper'],
        $band['averageLower'],
        $band['averageUpper'],
        $band['salaryRangeCount']
    );
}

function printSalary(string $label, ?array $salary): void
{
    // salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
    if ($salary === null) {
        echo "    {$label}: (no data for this year)\n";
        return;
    }

    printSalaryBand("{$label} junior", $salary['junior']);
    printSalaryBand("{$label} regular", $salary['regular']);
    printSalaryBand("{$label} senior", $salary['senior']);
}

function printYear(array $year): void
{
    printf("\n[%d]  offerCount=%d\n", $year['year'], $year['offerCount']);

    // NOTE: every `total` below is an independent denominator — none of them equal `offerCount`
    // or each other. Offers proposing neither B2B nor a permanent contract fall outside
    // contractType, and offers with no declared experience level fall outside seniority.
    $contract = $year['contractType'];
    printf("  contractType (total=%d, offerCount=%d):\n", $contract['total'], $year['offerCount']);
    printBucket('b2bOnly', $contract['b2bOnly'], $contract['total']);
    printBucket('permanentOnly', $contract['permanentOnly'], $contract['total']);
    printBucket('both', $contract['both'], $contract['total']);

    $seniority = $year['seniority'];
    printf("  seniority (total=%d, offerCount=%d):\n", $seniority['total'], $year['offerCount']);
    printSeniorityNode('junior', $seniority['junior']);
    printSeniorityNode('regular', $seniority['regular']);
    printSeniorityNode('senior', $seniority['senior']);

    echo "  salary (PLN, per seniority — lower..upper band):\n";
    printSalary('B2B', $year['salaryB2B'] ?? null);
    printSalary('UoP', $year['salaryUoP'] ?? null);

    $topSkills = $year['topSkills'];
    printf("  topSkills (%d):\n", count($topSkills));
    foreach (array_slice($topSkills, 0, 10) as $skill) {
        printf("    %-20s %d offers\n", $skill['name'], $skill['count']);
    }

    $quarters = $year['quarters'];
    printf("  quarters (%d):\n", count($quarters));
    foreach ($quarters as $quarter) {
        printQuarter($quarter);
    }
}

function printQuarter(array $quarter): void
{
    printf("    Q%d  offerCount=%d\n", $quarter['quarter'], $quarter['offerCount']);

    // Same independent-denominator caveat as at year level, scoped to the quarter.
    $contract = $quarter['contractType'];
    printf("      contractType (total=%d, offerCount=%d):\n", $contract['total'], $quarter['offerCount']);
    printBucket('b2bOnly', $contract['b2bOnly'], $contract['total']);
    printBucket('permanentOnly', $contract['permanentOnly'], $contract['total']);
    printBucket('both', $contract['both'], $contract['total']);

    $seniority = $quarter['seniority'];
    printf("      seniority (total=%d, offerCount=%d):\n", $seniority['total'], $quarter['offerCount']);
    printSeniorityNode('junior', $seniority['junior']);
    printSeniorityNode('regular', $seniority['regular']);
    printSeniorityNode('senior', $seniority['senior']);

    echo "      salary (PLN, per seniority — lower..upper band):\n";
    printSalary('B2B', $quarter['salaryB2B'] ?? null);
    printSalary('UoP', $quarter['salaryUoP'] ?? null);
}

$client = new SolidJobsClient();

// Yearly market report for a single role — up to 3 calendar years, oldest first.
// There is no `fields` parameter here: the report always comes back whole.
$raport = $client->getMarketRaport($role, $campaign);

echo "Role:         {$raport['scopeKey']}\n";
echo "Generated at: {$raport['generatedAt']}\n";
echo 'Years:        ' . count($raport['years']) . "\n";

foreach ($raport['years'] as $year) {
    printYear($year);
}
