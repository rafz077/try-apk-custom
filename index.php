<?php
session_start();
include "../config/database.php";

$error = "";
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $usernameInput = isset($_POST["username"]) ? trim($_POST["username"]) : "";
    $passwordInput = isset($_POST["password"]) ? trim($_POST["password"]) : "";

    $stmt = $pdo->prepare("SELECT * FROM admins WHERE username = ?");
    $stmt->execute(array($usernameInput));
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($admin && (password_verify($passwordInput, $admin["password"]) || $passwordInput === $admin["password"])) {
        $_SESSION["admin_user"] = $admin["username"];
        header("Location: dashboard.php");
        exit;
    } else {
        $error = "Akses ditolak. Periksa kembali kredensial admin.";
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Panel - MindCheck</title>
    <link rel="icon" type="image/x-icon" href="../assets/img/favicon.ico">
    <link rel="stylesheet" href="../assets/css/style.css?v=5">
</head>
<body>
<div class="live-bg">
    <div class="grid-glow"></div>
    <span class="aurora aurora-a"></span>
    <span class="aurora aurora-b"></span>
</div>
<main class="app-shell">
    <form method="POST" class="screen-card login-card active">
        <img src="../assets/img/logo.png" class="login-logo-img" alt="MindCheck Logo">
        <span class="chip">Private Access</span>
        <h1>Secure Panel</h1>
        <p>Masuk untuk memantau data screening pengguna.</p>
        <?php if ($error !== ""): ?><div class="error-box"><?php echo htmlspecialchars($error); ?></div><?php endif; ?>
        <input type="text" name="username" placeholder="Username admin" autocomplete="off" required>
        <input type="password" name="password" placeholder="Password admin" autocomplete="off" required>
        <button class="primary-btn wide" type="submit">Masuk</button>
    </form>
</main>
</body>
</html>
