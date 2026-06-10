DROP TABLE IF EXISTS test_results;
DROP TABLE IF EXISTS admins;

CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO admins (username, password) VALUES
('rafz', 'rafz7');

CREATE TABLE test_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    screen_time ENUM('rendah','sedang','tinggi') NOT NULL,
    comparison ENUM('rendah','sedang','tinggi') NOT NULL,
    sleep ENUM('ya','tidak') NOT NULL,
    panic ENUM('ya','tidak') NOT NULL,
    cyberbully ENUM('ya','tidak') NOT NULL,
    filter_use ENUM('rendah','sedang','tinggi') NOT NULL,
    support ENUM('baik','cukup','buruk') NOT NULL,
    result_label ENUM('rendah','sedang','tinggi') NOT NULL,
    confidence DECIMAL(5,2) NOT NULL,
    recommendation TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
