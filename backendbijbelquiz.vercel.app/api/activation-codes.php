<?php
// Simple activation codes API with CORS

header('Content-Type: application/json; charset=utf-8');
// Allow all origins for simplicity; tighten to your domain if needed:
// header('Access-Control-Allow-Origin: https://bijbelquiz.vercel.app');
header('Access-Control-Allow-Origin: *');
header('Vary: Origin');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Hardcoded activation codes (adjust as needed)
$codes = [
    'BIJBEL2025',
    'QUIZ1234',
    'TESTCODE',
    'DEMO-0000-2025'
];

// If a specific code is provided, only validate that code
$codeToCheck = isset($_GET['code']) ? strtoupper(trim($_GET['code'])) : null;

if ($codeToCheck !== null && $codeToCheck !== '') {
    $valid = in_array($codeToCheck, $codes, true);
    echo json_encode(['valid' => $valid], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

// Otherwise return the full list (primarily for debugging)
echo json_encode(['codes' => $codes], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);