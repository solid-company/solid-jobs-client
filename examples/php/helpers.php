<?php

function formatSalary(array $salary): string
{
    if ($salary['from'] === null && $salary['to'] === null) {
        return "no range ({$salary['currency']})";
    }
    return "{$salary['from']}-{$salary['to']} {$salary['currency']}/{$salary['period']}";
}
