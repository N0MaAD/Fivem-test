-- ============================================================
-- BASE DE DONNÉES ESX - FiveM
-- Exécuter ce script dans MySQL/MariaDB avant de lancer le serveur
-- ============================================================

CREATE DATABASE IF NOT EXISTS `esx_fivem` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `esx_fivem`;

-- ---- Table Users (joueurs) ----
CREATE TABLE IF NOT EXISTS `users` (
    `identifier` VARCHAR(60) NOT NULL,
    `accounts` LONGTEXT DEFAULT NULL,
    `group_name` VARCHAR(50) DEFAULT 'user',
    `firstname` VARCHAR(50) DEFAULT NULL,
    `lastname` VARCHAR(50) DEFAULT NULL,
    `dateofbirth` VARCHAR(25) DEFAULT NULL,
    `sex` VARCHAR(10) DEFAULT NULL,
    `position` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Skin (apparence) ----
CREATE TABLE IF NOT EXISTS `skin` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `skin` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Items (inventaire global) ----
CREATE TABLE IF NOT EXISTS `items` (
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `limit` INT(11) DEFAULT -1,
    `rare` TINYINT(1) DEFAULT 0,
    `can_remove` TINYINT(1) DEFAULT 1,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Items par défaut ----
INSERT IGNORE INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
    ('bread',       'Pain',          50, 0, 1),
    ('water',       'Eau',           50, 0, 1),
    ('phone',       'Téléphone',      1, 0, 1),
    ('id_card',     'Carte d\'identité', 1, 0, 0),
    ('bandage',     'Bandage',       20, 0, 1);
