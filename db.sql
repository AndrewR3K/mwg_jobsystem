CREATE TABLE IF NOT EXISTS jobs (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(150) NULL,
    onDutyEvent VARCHAR(150) NULL,
    offDutyEvent VARCHAR(150) NULL,
    expGainEvent VARCHAR(150) NULL,
    expLossEvent VARCHAR(150) NULL,
    levelUpEvent VARCHAR(150) NULL,
    maxLevelEvent VARCHAR(150) NULL
);

CREATE TABLE IF NOT EXISTS character_jobs (
    identifier VARCHAR(50) NOT NULL,
    charid INT NOT NULL,
    jobid INT NOT NULL,
    totalxp INT NOT NULL DEFAULT 1,
    level INT NULL,
    active TINYINT(1) NULL,
    UNIQUE INDEX Identifier_CharIdentifier_JobIdentifier (identifier,charid,jobid) USING BTREE,
    CONSTRAINT `FK_character_jobs_jobs` FOREIGN KEY (`jobid`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS job_levels (
    level INT NOT NULL PRIMARY KEY,
    minxp INT NOT NULL
);

INSERT INTO job_levels (`level`, `minxp`) VALUES (1,0);
INSERT INTO job_levels (`level`, `minxp`) VALUES (2,150);
INSERT INTO job_levels (`level`, `minxp`) VALUES (3,330);
INSERT INTO job_levels (`level`, `minxp`) VALUES (4,600);
INSERT INTO job_levels (`level`, `minxp`) VALUES (5,890);
INSERT INTO job_levels (`level`, `minxp`) VALUES (6,1100);
INSERT INTO job_levels (`level`, `minxp`) VALUES (7,1310);
INSERT INTO job_levels (`level`, `minxp`) VALUES (8,1810);
INSERT INTO job_levels (`level`, `minxp`) VALUES (9,2320);
INSERT INTO job_levels (`level`, `minxp`) VALUES (10,2770);
INSERT INTO job_levels (`level`, `minxp`) VALUES (11,2340);
INSERT INTO job_levels (`level`, `minxp`) VALUES (12,4120);
INSERT INTO job_levels (`level`, `minxp`) VALUES (13,5200);
INSERT INTO job_levels (`level`, `minxp`) VALUES (14,5290);
INSERT INTO job_levels (`level`, `minxp`) VALUES (15,6280);
INSERT INTO job_levels (`level`, `minxp`) VALUES (16,7430);
INSERT INTO job_levels (`level`, `minxp`) VALUES (17,8960);
INSERT INTO job_levels (`level`, `minxp`) VALUES (18,10500);
INSERT INTO job_levels (`level`, `minxp`) VALUES (19,12130);
INSERT INTO job_levels (`level`, `minxp`) VALUES (20,13860);
INSERT INTO job_levels (`level`, `minxp`) VALUES (21,15630);
INSERT INTO job_levels (`level`, `minxp`) VALUES (22,17670);
INSERT INTO job_levels (`level`, `minxp`) VALUES (23,18800);
INSERT INTO job_levels (`level`, `minxp`) VALUES (24,20250);
INSERT INTO job_levels (`level`, `minxp`) VALUES (25,21390);
INSERT INTO job_levels (`level`, `minxp`) VALUES (26,21880);
INSERT INTO job_levels (`level`, `minxp`) VALUES (27,23940);
INSERT INTO job_levels (`level`, `minxp`) VALUES (28,25960);
INSERT INTO job_levels (`level`, `minxp`) VALUES (29,27340);
INSERT INTO job_levels (`level`, `minxp`) VALUES (30,28610);
INSERT INTO job_levels (`level`, `minxp`) VALUES (31,29860);
INSERT INTO job_levels (`level`, `minxp`) VALUES (32,31200);
INSERT INTO job_levels (`level`, `minxp`) VALUES (33,32490);
INSERT INTO job_levels (`level`, `minxp`) VALUES (34,33760);
INSERT INTO job_levels (`level`, `minxp`) VALUES (35,34980);
INSERT INTO job_levels (`level`, `minxp`) VALUES (36,36160);
INSERT INTO job_levels (`level`, `minxp`) VALUES (37,37420);
INSERT INTO job_levels (`level`, `minxp`) VALUES (38,38640);
INSERT INTO job_levels (`level`, `minxp`) VALUES (39,39820);
INSERT INTO job_levels (`level`, `minxp`) VALUES (40,40930);
INSERT INTO job_levels (`level`, `minxp`) VALUES (41,42000);
INSERT INTO job_levels (`level`, `minxp`) VALUES (42,43140);
INSERT INTO job_levels (`level`, `minxp`) VALUES (43,45120);
INSERT INTO job_levels (`level`, `minxp`) VALUES (44,50510);
INSERT INTO job_levels (`level`, `minxp`) VALUES (45,56250);
INSERT INTO job_levels (`level`, `minxp`) VALUES (46,62750);
INSERT INTO job_levels (`level`, `minxp`) VALUES (47,69850);
INSERT INTO job_levels (`level`, `minxp`) VALUES (48,72430);
INSERT INTO job_levels (`level`, `minxp`) VALUES (49,74980);
INSERT INTO job_levels (`level`, `minxp`) VALUES (50,77540);