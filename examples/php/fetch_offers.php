<?php
$query = http_build_query([
    'campaign' => 'php-client',
    'pageSize' => 5,
]);

$url = "https://solid.jobs/public-api/offers/IT?" . $query;

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Api-Version: 1.0']);

$body = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

if ($curlError) {
    fwrite(STDERR, "Błąd sieci: $curlError\n");
    exit(1);
}

if ($httpCode === 429) {
    fwrite(STDERR, "Przekroczono limit zapytań (429). Spróbuj ponownie za chwilę.\n");
    exit(1);
}

if ($httpCode !== 200) {
    fwrite(STDERR, "Błąd HTTP: $httpCode\n");
    exit(1);
}

$data = json_decode($body, true);

echo "Znaleziono " . $data['totalCount'] . " ofert.\n";

foreach ($data['jobs'] as $job) {
    $salary = $job['salary'];
    echo "{$job['title']} @ {$job['company']} ({$salary['from']}-{$salary['to']} {$salary['currency']})\n";
}
