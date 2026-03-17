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

-- ---- Table Phone Users (numéros) ----
CREATE TABLE IF NOT EXISTS `phone_users` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    UNIQUE KEY `phone_number` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Phone Contacts ----
CREATE TABLE IF NOT EXISTS `phone_contacts` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `number` VARCHAR(20) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Phone Messages ----
CREATE TABLE IF NOT EXISTS `phone_messages` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `sender` VARCHAR(20) NOT NULL,
    `receiver` VARCHAR(20) NOT NULL,
    `message` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sender` (`sender`),
    KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Phone Calls ----
CREATE TABLE IF NOT EXISTS `phone_calls` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `caller` VARCHAR(20) NOT NULL,
    `receiver` VARCHAR(20) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'missed',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `caller` (`caller`),
    KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Phone Twitter ----
CREATE TABLE IF NOT EXISTS `phone_twitter` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `author` VARCHAR(100) NOT NULL,
    `message` VARCHAR(280) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Fishing Data (niveaux) ----
CREATE TABLE IF NOT EXISTS `fishing_data` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `xp` INT(11) DEFAULT 0,
    `level` INT(11) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Table Fishing Inventory ----
CREATE TABLE IF NOT EXISTS `fishing_inventory` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `fish_name` VARCHAR(50) NOT NULL,
    `amount` INT(11) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier_fish` (`identifier`, `fish_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Items par défaut ----
INSERT IGNORE INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
    ('bread',       'Pain',          50, 0, 1),
    ('water',       'Eau',           50, 0, 1),
    ('phone',       'Téléphone',      1, 0, 1),
    ('id_card',     'Carte d\'identité', 1, 0, 0),
    ('bandage',     'Bandage',       20, 0, 1);
