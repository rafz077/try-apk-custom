<?php include "includes/header.php"; ?>
<main class="app-shell">
    <section class="screen-card hero-screen view active" id="homeView">
        <div class="hero-content">
            <span class="chip">AI sederhana • Naive Bayes • MySQL</span>
            <h1>Cek tekanan digitalmu dengan cara yang lebih tenang.</h1>
            <p>MindCheck membantu remaja memahami risiko kecemasan akibat media sosial lewat screening singkat, hasil visual, dan rekomendasi personal.</p>

            <div class="visual-card">
                <div class="orbit-core"><span>🧠</span></div>
                <div class="signal-row">
                    <i style="--h:48%"></i><i style="--h:82%"></i><i style="--h:54%"></i><i style="--h:92%"></i><i style="--h:64%"></i>
                </div>
                <small>Analisis cepat berbasis aktivitas media sosial harian.</small>
            </div>

            <div class="action-row">
                <a class="primary-btn" href="test.php">Mulai Tes</a>
                <button class="soft-btn" type="button" data-show="featureView">Lihat Fitur</button>
            </div>
        </div>
    </section>

    <section class="screen-card feature-screen view" id="featureView">
        <div class="screen-head">
            <button class="back-btn" type="button" data-show="homeView">←</button>
            <div>
                <span class="chip">Project Features</span>
                <h2>Lebih dari form biasa.</h2>
                <p>Website ini punya sistem, database, algoritma, tools interaktif, dashboard, dan export data.</p>
            </div>
        </div>

        <div class="feature-list">
            <article><span>🧪</span><div><h3>Wizard Screening</h3><p>Form dibuat step-by-step agar nyaman dipakai di mobile.</p></div></article>
            <article><span>🤖</span><div><h3>Naive Bayes</h3><p>Klasifikasi rendah, sedang, tinggi dengan AI sederhana.</p></div></article>
            <article><span>🎮</span><div><h3>Vibe Tools</h3><p>Mood Snap, Detox Mission, Focus Sprint, dan Journal Prompt.</p></div></article>
            <article><span>📊</span><div><h3>Admin Dashboard</h3><p>Panel data dengan chart, statistik, dan export CSV.</p></div></article>
        </div>

        <div class="action-row compact">
            <a class="primary-btn" href="test.php">Coba Tes</a>
            <a class="soft-btn" href="tools.php">Buka Tools</a>
        </div>
    </section>
</main>
<?php include "includes/footer.php"; ?>
