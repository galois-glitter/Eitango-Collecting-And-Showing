CREATE TABLE `words` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `word` varchar(100) NOT NULL,
  `meaning_j` text DEFAULT NULL,
  `meaning_e` text DEFAULT NULL,
  `weblio_html` longtext DEFAULT NULL,
  `cambridge_html` longtext DEFAULT NULL,
  `weblio_status` int unsigned DEFAULT 0,
  `cambridge_status`int unsigned DEFAULT 0,   
  `created_at` timestamp NOT NULL DEFAULT current_timestamp, 
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp on update current_timestamp,
  FULLTEXT KEY `FT_Meaning` (`meaning_j`) COMMENT 'tokenizer "TokenMecab"',
  PRIMARY KEY (`id`)
) ENGINE=mroonga DEFAULT CHARSET=utf8mb4;

CREATE TABLE `list_pages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `words_range` text NOT NULL,
  `url` text NOT NULL,
  `html` longtext DEFAULT NULL,
  `html_status` int unsigned DEFAULT 0,
  `created_at` timestamp not null default current_timestamp, 
  `updated_at` timestamp not null default current_timestamp on update current_timestamp,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


