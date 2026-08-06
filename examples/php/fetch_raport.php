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

function printSalary(string $label, ?array $salary): void
{
    // salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
    if ($salary === null) {
        echo "    {$label}: (no data for this year)\n";
        return;
    }

    printf("    %s: median=%s  average=%s  ranges=%d\n", $label, $salary['median'], $salary['average'], $salary['salaryRangeCount']);
}

function printYear(array $year): void
{
    printf("\n[%d]  offerCount=%d\n", $year['year'], $year['offerCount']);

    // NOTE: `total` is the denominator of every `percentage` below — and it is NOT `offerCount`.
    // Offers proposing neither B2B nor a permanent contract fall outside contractType, and offers
    // with no declared experience level fall outside seniority.
    $contract = $year['contractType'];
    printf("  contractType (total=%d, offerCount=%d):\n", $contract['total'], $year['offerCount']);
    printBucket('b2bOnly', $contract['b2bOnly'], $contract['total']);
    printBucket('permanentOnly', $contract['permanentOnly'], $contract['total']);
    printBucket('both', $contract['both'], $contract['total']);

    $seniority = $year['seniority'];
    printf("  seniority (total=%d, offerCount=%d):\n", $seniority['total'], $year['offerCount']);
    printBucket('junior', $seniority['junior'], $seniority['total']);
    printBucket('regular', $seniority['regular'], $seniority['total']);
    printBucket('senior', $seniority['senior'], $seniority['total']);

    echo "  salary (monthly, PLN):\n";
    printSalary('B2B', $year['salaryB2B'] ?? null);
    printSalary('UoP', $year['salaryUoP'] ?? null);
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
