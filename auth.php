<?php if (session_status() === PHP_SESSION_NONE) session_start(); ?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MindCheck Flow - Digital Anxiety Screening</title>
    <link rel="icon" type="image/x-icon" href="assets/img/favicon.ico">
    <link rel="stylesheet" href="assets/css/style.css?v=5">
</head>
<body>
<div class="live-bg">
    <div class="grid-glow"></div>
    <span class="aurora aurora-a"></span>
    <span class="aurora aurora-b"></span>
    <span class="aurora aurora-c"></span>
</div>

<nav class="topbar">
    <a class="brand" href="index.php">
        <img src="assets/img/logo.png" class="brand-logo-img" alt="MindCheck Logo">
        <span class="brand-text">
            <b>MindCheck</b>
            <small>Digital Anxiety AI</small>
        </span>
    </a>
    <button class="menu-btn" id="menuBtn" type="button" aria-label="Menu">
        <span></span><span></span>
    </button>
    <div class="nav-drawer" id="navDrawer">
        <a href="index.php">Beranda</a>
        <a href="test.php">Tes Kecemasan</a>
        <a href="tools.php">Vibe Tools</a>
        <a href="about.php">Tentang</a>
        <a href="mindcore/login.php">Login Admin</a>
    </div>
</nav>
