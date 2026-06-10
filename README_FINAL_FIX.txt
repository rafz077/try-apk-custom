<?php include "includes/header.php"; ?>
<main class="app-shell">
    <section class="screen-card info-screen active">
        <span class="chip">Tentang Sistem</span>
        <h1>Prototype penelitian web untuk deteksi dini kecemasan digital.</h1>
        <p class="lead">MindCheck menggabungkan form screening, database MySQL, algoritma Naive Bayes, rekomendasi personal, Vibe Tools, dan dashboard admin.</p>

        <div class="tab-card">
            <div class="tab-nav">
                <button class="tab-btn active" type="button" data-tab="latar">Latar</button>
                <button class="tab-btn" type="button" data-tab="alur">Alur</button>
                <button class="tab-btn" type="button" data-tab="nilai">Nilai</button>
            </div>
            <div class="tab-content active" id="latar">
                <h3>Latar Belakang</h3>
                <p>Remaja sering menghadapi tekanan dari likes, komentar, followers, perbandingan sosial, dan standar visual media sosial. Screening dini membantu pengguna lebih sadar terhadap kondisi digitalnya.</p>
            </div>
            <div class="tab-content" id="alur">
                <h3>Alur Sistem</h3>
                <p>User mengisi form, sistem menghitung Naive Bayes, hasil ditampilkan, rekomendasi diberikan, lalu data tersimpan ke MySQL untuk dipantau oleh admin.</p>
            </div>
            <div class="tab-content" id="nilai">
                <h3>Nilai Akademik</h3>
                <p>Project ini memiliki sistem, algoritma, database, dashboard admin, export data, dan tools interaktif sehingga cocok untuk proyek penelitian web.</p>
            </div>
        </div>

        <a class="primary-btn wide" href="test.php">Mulai Screening</a>
    </section>
</main>
<?php include "includes/footer.php"; ?>
