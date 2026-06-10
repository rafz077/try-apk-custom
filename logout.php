<?php
include "auth.php";
include "../config/database.php";

$total = $pdo->query("SELECT COUNT(*) FROM test_results")->fetchColumn();
$rendah = $pdo->query("SELECT COUNT(*) FROM test_results WHERE result_label='rendah'")->fetchColumn();
$sedang = $pdo->query("SELECT COUNT(*) FROM test_results WHERE result_label='sedang'")->fetchColumn();
$tinggi = $pdo->query("SELECT COUNT(*) FROM test_results WHERE result_label='tinggi'")->fetchColumn();
$rows = $pdo->query("SELECT * FROM test_results ORDER BY created_at DESC LIMIT 20")->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MindCheck Admin Dashboard</title>
    <link rel="icon" type="image/x-icon" href="../assets/img/favicon.ico">
    <link rel="stylesheet" href="../assets/css/style.css?v=5">
</head>
<body>
<div class="live-bg">
    <div class="grid-glow"></div>
    <span class="aurora aurora-a"></span>
    <span class="aurora aurora-b"></span>
</div>
<nav class="topbar">
    <a class="brand" href="dashboard.php">
        <img src="../assets/img/logo.png" class="brand-logo-img" alt="MindCheck Logo">
        <span class="brand-text"><b>Admin Panel</b><small>MindCheck Secure</small></span>
    </a>
    <a class="logout-btn" href="logout.php">Logout</a>
</nav>

<main class="admin-shell">
    <section class="admin-hero">
        <span class="chip">Private Analytics</span>
        <h1>Ringkasan screening pengguna.</h1>
        <p>Monitoring hasil klasifikasi kecemasan digital dari sistem MindCheck.</p>
    </section>

    <section class="stat-strip">
        <div class="stat-card"><small>Total Tes</small><b><?php echo $total; ?></b></div>
        <div class="stat-card low"><small>Rendah</small><b><?php echo $rendah; ?></b></div>
        <div class="stat-card mid"><small>Sedang</small><b><?php echo $sedang; ?></b></div>
        <div class="stat-card high"><small>Tinggi</small><b><?php echo $tinggi; ?></b></div>
    </section>

    <section class="chart-panel">
        <div class="panel-title">
            <h2>Distribusi Risiko</h2>
            <a href="export.php" class="mini-action">Export CSV</a>
        </div>
        <div class="chart-bars">
            <div><span style="--bar:<?php echo max(8, $total ? ($rendah/$total*100) : 8); ?>%"></span><small>Rendah</small></div>
            <div><span style="--bar:<?php echo max(8, $total ? ($sedang/$total*100) : 8); ?>%"></span><small>Sedang</small></div>
            <div><span style="--bar:<?php echo max(8, $total ? ($tinggi/$total*100) : 8); ?>%"></span><small>Tinggi</small></div>
        </div>
    </section>

    <section class="data-panel">
        <h2>Data terbaru</h2>
        <div class="data-list">
            <?php foreach ($rows as $row): ?>
            <article>
                <div>
                    <b><?php echo htmlspecialchars($row["name"]); ?></b>
                    <small><?php echo htmlspecialchars($row["age"]); ?> tahun • <?php echo htmlspecialchars($row["created_at"]); ?></small>
                </div>
                <span class="risk-pill <?php echo $row["result_label"]; ?>"><?php echo strtoupper($row["result_label"]); ?> <?php echo htmlspecialchars($row["confidence"]); ?>%</span>
            </article>
            <?php endforeach; ?>
        </div>
    </section>
</main>
<script src="../assets/js/app.js?v=5"></script>
</body>
</html>
