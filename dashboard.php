<?php
function trainingData() {
    return array(
        array("screen_time"=>"rendah","comparison"=>"rendah","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"rendah","support"=>"baik","label"=>"rendah"),
        array("screen_time"=>"rendah","comparison"=>"sedang","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"sedang","support"=>"baik","label"=>"rendah"),
        array("screen_time"=>"sedang","comparison"=>"rendah","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"rendah","support"=>"cukup","label"=>"rendah"),
        array("screen_time"=>"sedang","comparison"=>"sedang","sleep"=>"ya","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"sedang","support"=>"cukup","label"=>"sedang"),
        array("screen_time"=>"sedang","comparison"=>"sedang","sleep"=>"ya","panic"=>"ya","cyberbully"=>"tidak","filter"=>"sedang","support"=>"cukup","label"=>"sedang"),
        array("screen_time"=>"tinggi","comparison"=>"sedang","sleep"=>"ya","panic"=>"ya","cyberbully"=>"tidak","filter"=>"tinggi","support"=>"cukup","label"=>"sedang"),
        array("screen_time"=>"tinggi","comparison"=>"tinggi","sleep"=>"ya","panic"=>"ya","cyberbully"=>"tidak","filter"=>"tinggi","support"=>"buruk","label"=>"tinggi"),
        array("screen_time"=>"tinggi","comparison"=>"tinggi","sleep"=>"ya","panic"=>"ya","cyberbully"=>"ya","filter"=>"tinggi","support"=>"buruk","label"=>"tinggi"),
        array("screen_time"=>"sedang","comparison"=>"tinggi","sleep"=>"ya","panic"=>"ya","cyberbully"=>"ya","filter"=>"tinggi","support"=>"buruk","label"=>"tinggi"),
        array("screen_time"=>"tinggi","comparison"=>"tinggi","sleep"=>"ya","panic"=>"ya","cyberbully"=>"ya","filter"=>"sedang","support"=>"cukup","label"=>"tinggi"),
        array("screen_time"=>"rendah","comparison"=>"rendah","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"rendah","support"=>"cukup","label"=>"rendah"),
        array("screen_time"=>"sedang","comparison"=>"rendah","sleep"=>"ya","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"rendah","support"=>"baik","label"=>"sedang"),
        array("screen_time"=>"tinggi","comparison"=>"rendah","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"tidak","filter"=>"rendah","support"=>"baik","label"=>"sedang"),
        array("screen_time"=>"rendah","comparison"=>"tinggi","sleep"=>"ya","panic"=>"ya","cyberbully"=>"tidak","filter"=>"tinggi","support"=>"cukup","label"=>"sedang"),
        array("screen_time"=>"tinggi","comparison"=>"sedang","sleep"=>"tidak","panic"=>"tidak","cyberbully"=>"ya","filter"=>"sedang","support"=>"cukup","label"=>"sedang"),
        array("screen_time"=>"tinggi","comparison"=>"tinggi","sleep"=>"ya","panic"=>"tidak","cyberbully"=>"ya","filter"=>"rendah","support"=>"buruk","label"=>"tinggi")
    );
}

function getUniqueValues($data, $feature) {
    $values = array();
    foreach ($data as $row) {
        if (!in_array($row[$feature], $values)) {
            $values[] = $row[$feature];
        }
    }
    return $values;
}

function naiveBayesPredict($input) {
    $data = trainingData();
    $labels = array("rendah", "sedang", "tinggi");
    $features = array("screen_time", "comparison", "sleep", "panic", "cyberbully", "filter", "support");
    $total = count($data);
    $scores = array();

    foreach ($labels as $label) {
        $labelData = array();
        foreach ($data as $row) {
            if ($row["label"] === $label) {
                $labelData[] = $row;
            }
        }

        $labelCount = count($labelData);
        $prior = ($labelCount + 1) / ($total + count($labels));
        $prob = $prior;

        foreach ($features as $feature) {
            $possibleValues = getUniqueValues($data, $feature);
            $valueCount = 0;

            foreach ($labelData as $row) {
                if ($row[$feature] === $input[$feature]) {
                    $valueCount++;
                }
            }

            $prob *= ($valueCount + 1) / ($labelCount + count($possibleValues));
        }

        $scores[$label] = $prob;
    }

    arsort($scores);
    $prediction = key($scores);
    $sum = array_sum($scores);
    $confidence = $sum > 0 ? round(($scores[$prediction] / $sum) * 100, 2) : 0;

    return array("prediction"=>$prediction, "confidence"=>$confidence, "scores"=>$scores);
}

function recommendationText($label) {
    if ($label === "rendah") {
        return "Kondisi digital kamu relatif aman. Pertahankan batas penggunaan media sosial, jaga tidur, dan gunakan platform digital untuk hal yang produktif.";
    }
    if ($label === "sedang") {
        return "Ada indikasi tekanan digital sedang. Coba lakukan digital break, kurasi akun yang memicu perbandingan diri, dan buat zona bebas gadget sebelum tidur.";
    }
    return "Indikasi tekanan digital cukup tinggi. Kurangi paparan media sosial, bicarakan kondisi kamu dengan orang terpercaya, dan pertimbangkan bantuan guru BK, konselor, atau psikolog.";
}

function dailyPlan($label) {
    if ($label === "rendah") {
        return array("Gunakan mode fokus 1 jam saat belajar", "Tetapkan jam tidur tanpa ponsel", "Lakukan aktivitas offline minimal 30 menit");
    }
    if ($label === "sedang") {
        return array("Batasi scroll malam hari", "Unfollow akun pemicu insecure", "Tulis jurnal mood 5 menit sebelum tidur");
    }
    return array("Istirahat dari media sosial 24 jam", "Hubungi orang terpercaya hari ini", "Cari bantuan profesional bila cemas terus berlanjut");
}
?>
