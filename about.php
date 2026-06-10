<?php
include "auth.php";
include "../config/database.php";

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename=mindcheck_results.csv');

$output = fopen('php://output', 'w');
fputcsv($output, array('Nama', 'Usia', 'Screen Time', 'Comparison', 'Sleep', 'Panic', 'Cyberbully', 'Filter', 'Support', 'Hasil', 'Confidence', 'Tanggal'));

$stmt = $pdo->query("SELECT * FROM test_results ORDER BY created_at DESC");
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    fputcsv($output, array(
        $row['name'], $row['age'], $row['screen_time'], $row['comparison'], $row['sleep'],
        $row['panic'], $row['cyberbully'], $row['filter_use'], $row['support'],
        $row['result_label'], $row['confidence'], $row['created_at']
    ));
}
fclose($output);
exit;
?>
