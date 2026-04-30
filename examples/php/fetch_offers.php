<?php
$query = http_build_query([
    'campaign' => 'php-client',
    'pageSize' => 5
]);

$url = "https://solid.jobs/public-api/offers/IT?" . $query;
$response = file_get_contents($url);
$data = json_decode($response, true);

echo "Znaleziono " . $data['totalCount'] . " ofert.\n";

foreach ($data['jobs'] as $job) {
    $salary = $job['salary'];
    echo "{$job['title']} @ {$job['company']} ({$salary['from']}-{$salary['to']} {$salary['currency']})\n";
}