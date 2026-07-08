<?php

require_once __DIR__ . '/SolidJobsClient.php';

function printBand(?array $band): void
{
    if ($band === null) {
        echo "    (no offers with a declared salary)\n";
        return;
    }
    echo "    min={$band['min']}  p25={$band['p25']}  median={$band['median']}  p75={$band['p75']}  max={$band['max']}\n";
}

function printContractSalary(string $label, ?array $stat): void
{
    if ($stat === null) {
        echo "    $label: (no precomputed data)\n";
        return;
    }
    echo "    $label: median={$stat['median']}  average={$stat['average']}  offers={$stat['offerCount']}\n";
}

function printBuckets(array $buckets): void
{
    foreach ($buckets as $b) {
        printf("    %-24s %5d offers  (%d%%)\n", $b['label'], $b['offerCount'], $b['percentage']);
    }
}

function printStatistics(array $stats): void
{
    echo "Scope:            {$stats['scopeKind']} / {$stats['scopeKey']}\n";
    echo "Generated at:     {$stats['generatedAt']}\n";
    echo 'Included sections: ' . implode(', ', $stats['includedSections']) . "\n";

    if (isset($stats['demand'])) {
        $d = $stats['demand'];
        echo "\n[demand]\n";
        echo "  activeOffers={$d['activeOffers']}  distinctEmployers={$d['distinctEmployers']}"
            . "  remoteOffers={$d['remoteOffers']}  remotePercentage={$d['remotePercentage']}%\n";
        echo "  offerTrend (quarterly):\n";
        foreach ($d['offerTrend'] as $point) {
            echo "    {$point['period']}: {$point['offerCount']} offers\n";
        }
    }

    if (isset($stats['salary'])) {
        $s = $stats['salary'];
        echo "\n[salary] currency={$s['currency']}\n";
        echo "  overall (live percentiles):\n";
        printBand($s['overall'] ?? null);
        printContractSalary('b2b       ', $s['b2b'] ?? null);
        printContractSalary('permanent ', $s['permanent'] ?? null);
    }

    if (isset($stats['experience'])) {
        echo "\n[experience]\n";
        printBuckets($stats['experience']);
    }

    if (isset($stats['topLocations'])) {
        echo "\n[topLocations]\n";
        printBuckets($stats['topLocations']);
    }

    if (isset($stats['topSkills'])) {
        echo "\n[topSkills]\n";
        printBuckets($stats['topSkills']);
    }
}

$client = new SolidJobsClient();
$campaign = 'php-stats';

// 1) Full snapshot — every section available for the React specialization
$full = $client->getMarketStatistics('subcategory', 'React', $campaign);
printStatistics($full);

// 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
//    `includedSections` in the response confirms exactly what came back.
echo "\n───────────────────────────────────────────────\n";
echo "Partial fetch with fields=demand,salary:\n";
$partial = $client->getMarketStatistics('subcategory', 'React', $campaign, ['demand', 'salary']);
echo 'Included sections: ' . implode(', ', $partial['includedSections']) . "\n";
