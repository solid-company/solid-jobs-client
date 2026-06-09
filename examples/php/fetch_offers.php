<?php

require_once __DIR__ . '/SolidJobsClient.php';
require_once __DIR__ . '/helpers.php';

$client = new SolidJobsClient();
$campaign = 'php-client';

// 1) Basic listing — first page of IT offers
$firstPage = $client->getOffers('IT', $campaign, ['pageSize' => 5]);
echo "Found {$firstPage['totalCount']} offers (pages: {$firstPage['totalPages']}).\n";

foreach ($firstPage['jobs'] as $job) {
    $sal = formatSalary($job['salary']);
    echo "{$job['title']} @ {$job['company']} [{$job['experienceLevel']}] ($sal)\n";
}

// 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
$seniorJava = $client->getOffers('IT', $campaign, [
    'searchTerms' => ['java'],
    'cities' => ['Warszawa'],
    'subCategories' => ['Java'],
    'experiences' => ['Senior'],
    'minimumSalary' => 15000,
    'sortActive' => 'salaryTo',
    'sortDirection' => 'desc',
    'pageSize' => 10,
]);

echo "\nSenior Java in Warsaw: {$seniorJava['totalCount']} offers\n";
foreach ($seniorJava['jobs'] as $job) {
    echo "- {$job['title']} (" . formatSalary($job['salary']) . ")\n";
}

// 3) Iterate all .NET offers
echo "\nAll .NET offers:\n";
$allDotNet = $client->getAllOffers('IT', $campaign, ['subCategories' => ['DotNet']]);
foreach ($allDotNet as $i => $job) {
    printf("%3d. %s @ %s\n", $i + 1, $job['title'], $job['company']);
}
echo "Total: " . count($allDotNet) . "\n";
