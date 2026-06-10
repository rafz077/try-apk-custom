<?php
include "config/database.php";
include "includes/naive_bayes.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    header("Location: test.php");
    exit;
}

$required = array("name", "age", "screen_time", "comparison", "sleep", "panic", "cyberbully", "filter", "support");
foreach ($required as $field) {
    if (!isset($_POST[$field]) || $_POST[$field] === "") {
        header("Location: test.php");
        exit;
    }
}

$input = array(
    "screen_time" => $_POST["screen_time"],
    "comparison" => $_POST["comparison"],
    "sleep" => $_POST["sleep"],
    "panic" => $_POST["panic"],
    "cyberbully" => $_POST["cyberbully"],
    "filter" => $_POST["filter"],
    "support" => $_POST["support"]
);

$result = naiveBayesPredict($input);
$recommendation = recommendationText($result["prediction"]);
$plan = dailyPlan($result["prediction"]);

$stmt = $pdo->prepare("INSERT INTO test_results 
(name, age, screen_time, comparison, sleep, panic, cyberbully, filter_use, support, result_label, confidence, recommendation)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

$stmt->execute(array(
    $_POST["name"],
    $_POST["age"],
    $input["screen_time"],
    $input["comparison"],
    $input["sleep"],
    $input["panic"],
    $input["cyberbully"],
    $input["filter"],
    $input["support"],
    $result["prediction"],
    $result["confidence"],
    $recommendation
));

$query = http_build_query(array(
    "label" => $result["prediction"],
    "confidence" => $result["confidence"],
    "recommendation" => $recommendation,
    "plan1" => $plan[0],
    "plan2" => $plan[1],
    "plan3" => $plan[2]
));

header("Location: result.php?$query");
exit;
?>
