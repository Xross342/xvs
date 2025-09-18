
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Ads` (
  `ad_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ad_title` varchar(128) NOT NULL DEFAULT '',
  `ad_code` text NOT NULL DEFAULT '',
  `ad_adult` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `ad_weight` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `ad_disabled` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ad_id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Categories` (
  `cat_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `cat_parent_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `cat_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `cat_name` varchar(255) NOT NULL DEFAULT '',
  `cat_descr` text NOT NULL,
  `cat_premium` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`cat_id`),
  KEY `parent` (`cat_parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ChangeFields` (
  `hash` char(10) NOT NULL DEFAULT '',
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `used` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `data` text NOT NULL,
  KEY `hash` (`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Comments` (
  `cmt_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `cmt_type` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `cmt_ext_id` int(10) unsigned NOT NULL DEFAULT 0,
  `cmt_ip` int(10) unsigned NOT NULL DEFAULT 0,
  `cmt_name` varchar(32) NOT NULL DEFAULT '',
  `cmt_email` varchar(64) NOT NULL DEFAULT '',
  `cmt_website` varchar(100) NOT NULL DEFAULT '',
  `cmt_text` text NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`cmt_id`),
  KEY `ext` (`cmt_type`,`cmt_ext_id`),
  KEY `date` (`created`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DailyTraffic` (
  `dayhour` int(10) unsigned NOT NULL DEFAULT 0,
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `bandwidth` bigint(20) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`dayhour`,`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DelReasons` (
  `file_code` varchar(12) NOT NULL DEFAULT '',
  `file_name` varchar(100) NOT NULL DEFAULT '',
  `info` varchar(255) NOT NULL DEFAULT '',
  `last_access` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`file_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Domains` (
  `dom_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `dom_domain` varchar(128) NOT NULL DEFAULT '',
  `dom_status` enum('INIT','PENDING','ACTIVE','ERROR','OFF','TODELETE') NOT NULL DEFAULT 'INIT',
  `dom_ns1` varchar(128) NOT NULL DEFAULT '',
  `dom_ns2` varchar(128) NOT NULL DEFAULT '',
  `created` datetime NOT NULL DEFAULT '2024-01-01 00:00:00',
  `dom_error` varchar(255) NOT NULL DEFAULT '',
  `dom_cf_id` varchar(1024) NOT NULL DEFAULT '',
  PRIMARY KEY (`dom_id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Favorites` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`usr_id`,`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FileLogs` (
  `file_real` varchar(12) NOT NULL DEFAULT '',
  `event` varchar(255) NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `file_real` (`file_real`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Files` (
  `file_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `srv_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `srv_id_copy` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_name` varchar(255) NOT NULL DEFAULT '',
  `file_title` varchar(255) NOT NULL DEFAULT '',
  `file_descr` text NOT NULL,
  `file_public` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_premium_only` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_adult` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_code` varchar(12) NOT NULL DEFAULT '',
  `file_real` varchar(12) NOT NULL DEFAULT '',
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_fld_id` int(11) NOT NULL DEFAULT 0,
  `file_downloads` int(10) unsigned NOT NULL DEFAULT 0,
  `file_views` int(10) unsigned NOT NULL DEFAULT 0,
  `file_views_full` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size` bigint(20) unsigned NOT NULL DEFAULT 0,
  `file_size_o` bigint(20) unsigned NOT NULL DEFAULT 0,
  `file_size_n` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_h` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_l` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_x` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_p` int(10) unsigned NOT NULL DEFAULT 0,
  `file_screenlist` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_ip` int(20) unsigned NOT NULL DEFAULT 0,
  `file_md5` varchar(64) NOT NULL DEFAULT '',
  `file_spec_txt` text NOT NULL,
  `file_spec_o` varchar(255) NOT NULL DEFAULT '',
  `file_spec_n` varchar(255) NOT NULL DEFAULT '',
  `file_spec_h` varchar(255) NOT NULL DEFAULT '',
  `file_spec_l` varchar(255) NOT NULL DEFAULT '',
  `file_spec_x` varchar(255) NOT NULL DEFAULT '',
  `file_spec_p` varchar(255) NOT NULL DEFAULT '',
  `file_length` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_rating` mediumint(9) NOT NULL DEFAULT 0,
  `file_last_download` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cat_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `file_money` decimal(10,5) unsigned NOT NULL DEFAULT 0.00000,
  `file_status` enum('OK','PENDING','LOCKED') NOT NULL DEFAULT 'OK',
  `file_src` varchar(255) NOT NULL DEFAULT '',
  `file_captions` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`file_id`),
  KEY `server` (`srv_id`),
  KEY `size` (`file_size`),
  KEY `srv2` (`srv_id_copy`),
  KEY `created` (`file_created`),
  KEY `cat_id` (`cat_id`),
  KEY `public` (`file_public`),
  KEY `real` (`file_real`),
  KEY `code` (`file_code`),
  KEY `status` (`file_status`),
  KEY `usrfld` (`usr_id`,`file_fld_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Files2Playlists` (
  `pls_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`pls_id`,`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FilesDMCA` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `del_by_email` varchar(64) NOT NULL DEFAULT '',
  `del_by_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `del_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  UNIQUE KEY `file` (`file_id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FilesData` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(24) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`file_id`,`name`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FilesFeatured` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FilesTrash` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `srv_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `srv_id_copy` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_name` varchar(255) NOT NULL DEFAULT '',
  `file_title` varchar(255) NOT NULL DEFAULT '',
  `file_descr` text NOT NULL,
  `file_public` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_premium_only` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_adult` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_code` varchar(12) NOT NULL DEFAULT '',
  `file_real` varchar(12) NOT NULL DEFAULT '',
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_fld_id` int(11) NOT NULL DEFAULT 0,
  `file_downloads` int(10) unsigned NOT NULL DEFAULT 0,
  `file_views` int(10) unsigned NOT NULL DEFAULT 0,
  `file_views_full` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size` bigint(20) unsigned NOT NULL DEFAULT 0,
  `file_size_o` bigint(20) unsigned NOT NULL DEFAULT 0,
  `file_size_n` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_h` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_l` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_x` int(10) unsigned NOT NULL DEFAULT 0,
  `file_size_p` int(10) unsigned NOT NULL DEFAULT 0,
  `file_screenlist` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_ip` int(20) unsigned NOT NULL DEFAULT 0,
  `file_md5` varchar(64) NOT NULL DEFAULT '',
  `file_spec_txt` text NOT NULL,
  `file_spec_o` varchar(255) NOT NULL DEFAULT '',
  `file_spec_n` varchar(255) NOT NULL DEFAULT '',
  `file_spec_h` varchar(255) NOT NULL DEFAULT '',
  `file_spec_l` varchar(255) NOT NULL DEFAULT '',
  `file_spec_x` varchar(255) NOT NULL DEFAULT '',
  `file_spec_p` varchar(255) NOT NULL DEFAULT '',
  `file_length` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_rating` mediumint(9) NOT NULL DEFAULT 0,
  `file_last_download` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cat_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `file_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `file_money` decimal(10,5) unsigned NOT NULL DEFAULT 0.00000,
  `file_status` enum('OK','PENDING','LOCKED') NOT NULL DEFAULT 'OK',
  `file_src` varchar(255) NOT NULL DEFAULT '',
  `file_captions` varchar(255) NOT NULL DEFAULT '',
  `file_deleted` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `del_by` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `hide` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `cleaned` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`file_id`),
  KEY `usr` (`usr_id`),
  KEY `cleaned` (`cleaned`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Folders` (
  `fld_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `fld_parent_id` int(10) unsigned NOT NULL DEFAULT 0,
  `fld_code` varchar(10) NOT NULL DEFAULT '',
  `fld_descr` text NOT NULL,
  `fld_name` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`fld_id`),
  KEY `parent` (`fld_parent_id`),
  KEY `code` (`fld_code`),
  KEY `user` (`usr_id`,`fld_parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Hosts` (
  `host_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `host_name` varchar(100) NOT NULL DEFAULT '',
  `host_ip` varchar(100) NOT NULL DEFAULT '',
  `host_cgi_url` varchar(255) NOT NULL DEFAULT '',
  `host_htdocs_url` varchar(255) NOT NULL DEFAULT '',
  `host_in` smallint(5) unsigned NOT NULL DEFAULT 0,
  `host_out` smallint(5) unsigned NOT NULL DEFAULT 0,
  `host_avg` decimal(5,2) unsigned NOT NULL DEFAULT 0.00,
  `host_max_enc` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_max_trans` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_max_url` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_transfer_speed` smallint(5) unsigned NOT NULL DEFAULT 0,
  `host_connections` smallint(5) unsigned NOT NULL DEFAULT 0,
  `host_net_speed` smallint(5) unsigned NOT NULL DEFAULT 0,
  `host_notes` mediumtext NOT NULL,
  `host_live` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `host_torrent` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_torrent_active` datetime NOT NULL DEFAULT '2020-01-01 00:00:00',
  `host_ftp` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_ftp_current` mediumtext NOT NULL,
  `host_proxy` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_cache_rate` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `IPNLogs` (
  `ipn_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `info` text NOT NULL,
  PRIMARY KEY (`ipn_id`),
  KEY `created` (`created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Languages` (
  `lang_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `lang_name` varchar(255) NOT NULL DEFAULT '',
  `lang_order` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `lang_active` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`lang_id`),
  KEY `name` (`lang_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LoginHistory` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `agent` varchar(255) NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `user` (`usr_id`,`created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LoginProtect` (
  `usr_id` mediumint(8) unsigned NOT NULL,
  `ip` int(20) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `usr_id` (`usr_id`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `News` (
  `news_id` mediumint(9) unsigned NOT NULL AUTO_INCREMENT,
  `news_title` varchar(100) NOT NULL DEFAULT '',
  `news_title2` varchar(100) NOT NULL DEFAULT '',
  `news_text` text NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`news_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Pairs` (
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Payments` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `amount` decimal(7,2) unsigned NOT NULL DEFAULT 0.00,
  `status` enum('PENDING','PAID','REJECTED') NOT NULL DEFAULT 'PENDING',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `processed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `pay_type` varchar(32) NOT NULL DEFAULT '',
  `pay_info` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `user` (`usr_id`),
  KEY `stat` (`status`,`created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Playlists` (
  `pls_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `pls_name` varchar(255) NOT NULL DEFAULT '',
  `pls_code` char(6) NOT NULL DEFAULT '',
  PRIMARY KEY (`pls_id`),
  UNIQUE KEY `code` (`pls_code`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PremiumKeys` (
  `key_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `key_code` varchar(14) NOT NULL DEFAULT '',
  `key_time` varchar(8) NOT NULL DEFAULT '0',
  `key_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `key_activated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `usr_id_activated` mediumint(8) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`key_id`),
  KEY `user` (`usr_id`,`key_created`),
  KEY `created` (`key_created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Proxy2Files` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `host_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`file_id`,`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueDelete` (
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_real` char(12) NOT NULL DEFAULT '',
  `srv_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `del_by` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `del_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `quality` char(1) NOT NULL DEFAULT '0',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT 0,
  KEY `id` (`file_real_id`),
  KEY `del_time` (`del_time`),
  KEY `priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueEmail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email_from` varchar(255) NOT NULL DEFAULT '',
  `email_to` varchar(255) NOT NULL DEFAULT '',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `priority` tinyint(4) NOT NULL DEFAULT 0,
  `txt` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueEncoding` (
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_real` varchar(12) NOT NULL DEFAULT '',
  `quality` char(1) NOT NULL DEFAULT '',
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `host_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `srv_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `started` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` enum('PENDING','ENCODING','STUCK','ERROR') NOT NULL DEFAULT 'PENDING',
  `progress` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `fps` smallint(5) unsigned NOT NULL DEFAULT 0,
  `error` text NOT NULL,
  `premium` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `priority` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `extra` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`file_real`,`quality`),
  KEY `host_id` (`host_id`,`status`),
  KEY `srv` (`srv_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueTransfer` (
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_real` varchar(12) NOT NULL DEFAULT '',
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `srv_id1` smallint(5) unsigned NOT NULL DEFAULT 0,
  `srv_id2` smallint(5) unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `started` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` enum('PENDING','MOVING','ERROR','STUCK') NOT NULL DEFAULT 'PENDING',
  `transferred` int(10) unsigned NOT NULL DEFAULT 0,
  `updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `speed` smallint(5) unsigned NOT NULL DEFAULT 0,
  `copy` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `premium` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `error` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`file_real`,`srv_id1`,`srv_id2`),
  KEY `srv2` (`srv_id2`),
  KEY `file_real_id` (`file_real_id`),
  KEY `srv1` (`srv_id1`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueUpload` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `srv_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `url` mediumtext NOT NULL,
  `status` enum('PENDING','WORKING','ERROR','STUCK') NOT NULL DEFAULT 'PENDING',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `started` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `size_dl` bigint(20) unsigned NOT NULL DEFAULT 0,
  `size_full` bigint(20) unsigned NOT NULL DEFAULT 0,
  `speed` smallint(5) unsigned NOT NULL DEFAULT 0,
  `error` mediumtext NOT NULL,
  `premium` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `extras` text NOT NULL,
  `file_code` varchar(12) NOT NULL DEFAULT '',
  `fld_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `usr` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `QueueVTT` (
  `file_real_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_code` char(12) NOT NULL DEFAULT '',
  `host_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `disk_id` char(2) NOT NULL DEFAULT '01',
  `language` char(3) NOT NULL DEFAULT 'eng',
  `data` mediumtext NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `no_db_update` tinyint(3) unsigned NOT NULL DEFAULT 0,
  KEY `host` (`host_id`,`file_real_id`,`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Reports` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `file_code` char(12) NOT NULL DEFAULT '',
  `type` varchar(128) NOT NULL DEFAULT '',
  `info` text NOT NULL,
  `ip` int(20) unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Servers` (
  `srv_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `srv_name` varchar(64) NOT NULL DEFAULT '',
  `srv_type` enum('UPLOADER','ENCODER','STORAGE') NOT NULL DEFAULT 'STORAGE',
  `srv_encode` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `host_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `srv_ip` varchar(16) NOT NULL DEFAULT '',
  `srv_cgi_url` varchar(255) NOT NULL DEFAULT '',
  `srv_htdocs_url` varchar(255) NOT NULL DEFAULT '',
  `disk_id` char(2) NOT NULL DEFAULT '01',
  `disk_dev_df` varchar(32) NOT NULL DEFAULT '',
  `disk_dev_io` varchar(32) NOT NULL DEFAULT '',
  `disk_util` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `srv_disk_max` bigint(20) unsigned NOT NULL DEFAULT 0,
  `srv_status` enum('ON','READONLY','READONLY2','OFF') NOT NULL DEFAULT 'ON',
  `srv_files` int(10) unsigned NOT NULL DEFAULT 0,
  `srv_disk` bigint(20) unsigned NOT NULL DEFAULT 0,
  `srv_allow_regular` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `srv_allow_premium` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `srv_ssd` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `srv_created` date NOT NULL DEFAULT '0000-00-00',
  `srv_last_upload` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `srv_users_only` varchar(255) NOT NULL DEFAULT '',
  `srv_countries_only` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`srv_id`),
  KEY `host` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Sessions` (
  `session_id` char(16) NOT NULL DEFAULT '',
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `last_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`session_id`),
  KEY `usr_id` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Stats` (
  `day` date NOT NULL DEFAULT '0000-00-00',
  `uploads` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `deleted` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `downloads` int(8) unsigned NOT NULL DEFAULT 0,
  `views` int(10) unsigned NOT NULL DEFAULT 0,
  `views_adb` int(10) unsigned NOT NULL DEFAULT 0,
  `registered` smallint(5) unsigned NOT NULL DEFAULT 0,
  `bandwidth` bigint(20) unsigned NOT NULL DEFAULT 0,
  `paid` decimal(7,2) NOT NULL DEFAULT 0.00,
  `profit` decimal(10,5) unsigned NOT NULL DEFAULT 0.00000,
  `payout` decimal(7,2) unsigned NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Stats2` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `day` date NOT NULL DEFAULT '0000-00-00',
  `views` int(10) unsigned NOT NULL DEFAULT 0,
  `views_prem` int(10) unsigned NOT NULL DEFAULT 0,
  `views_adb` int(10) unsigned NOT NULL DEFAULT 0,
  `uploads` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `uploads_mb` int(10) unsigned NOT NULL DEFAULT 0,
  `downloads` int(10) unsigned NOT NULL DEFAULT 0,
  `downloads_prem` int(10) unsigned NOT NULL DEFAULT 0,
  `sales` smallint(10) unsigned NOT NULL DEFAULT 0,
  `profit_views` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  `profit_sales` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  `profit_refs` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  `profit_site` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  `refs` smallint(5) unsigned NOT NULL DEFAULT 0,
  `profit_rebills` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  PRIMARY KEY (`day`,`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StatsCountry` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `day` date NOT NULL DEFAULT '0000-00-00',
  `country` char(2) NOT NULL DEFAULT 'XX',
  `views` int(10) unsigned NOT NULL DEFAULT 0,
  `money` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  PRIMARY KEY (`usr_id`,`day`,`country`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StatsIP` (
  `day` date NOT NULL,
  `ip` int(20) unsigned NOT NULL DEFAULT 0,
  `traffic` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `money` decimal(8,5) unsigned NOT NULL DEFAULT 0.00000,
  `views` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ip`,`day`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StatsMisc` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `day` date NOT NULL DEFAULT '0000-00-00',
  `name` varchar(32) NOT NULL DEFAULT '',
  `value` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`usr_id`,`day`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StatsMiscMin` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `minute` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `name` varchar(32) NOT NULL DEFAULT '',
  `value` mediumint(8) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`usr_id`,`minute`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StatsPerf` (
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `encode` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `urlupload` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `transfer` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `connections` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `speed_out` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `speed_in` mediumint(8) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StorageSlots` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(9) unsigned NOT NULL DEFAULT 0,
  `expire` date NOT NULL DEFAULT '0000-00-00',
  `gb` mediumint(8) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Stream2IP` (
  `stream_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`stream_id`,`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Streams` (
  `stream_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `host_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `stream_code` char(10) NOT NULL DEFAULT '',
  `stream_key` char(6) NOT NULL DEFAULT '',
  `stream_title` varchar(255) NOT NULL DEFAULT '',
  `stream_descr` text NOT NULL,
  `stream_live` tinyint(4) NOT NULL DEFAULT 0,
  `stream_record` tinyint(4) NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `started` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`stream_id`),
  KEY `user` (`usr_id`),
  KEY `code` (`stream_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tags` (
  `tag_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tag_value` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tags2Files` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `tag_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`file_id`,`tag_id`),
  KEY `tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TicketMessages` (
  `msg_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ti_id` int(10) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `msg_ip` int(10) unsigned NOT NULL DEFAULT 0,
  `message` text NOT NULL,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`msg_id`),
  KEY `ticket` (`ti_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tickets` (
  `ti_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ti_title` varchar(128) NOT NULL DEFAULT '',
  `category` varchar(64) NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `open` tinyint(4) NOT NULL DEFAULT 1,
  `unread` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `unread_adm` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `replied` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ti_id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TmpFiles` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `views` smallint(5) unsigned NOT NULL DEFAULT 0,
  `views_full` smallint(5) unsigned NOT NULL DEFAULT 0,
  `money` decimal(7,5) unsigned NOT NULL DEFAULT 0.00000,
  `bandwidth` int(10) unsigned NOT NULL DEFAULT 0,
  `downloads` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`file_id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TmpStats2` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `views` smallint(5) unsigned NOT NULL DEFAULT 0,
  `views_prem` smallint(5) unsigned NOT NULL DEFAULT 0,
  `views_adb` smallint(5) unsigned NOT NULL DEFAULT 0,
  `profit_views` decimal(8,5) unsigned NOT NULL DEFAULT 0.00000,
  `profit_refs` decimal(7,5) unsigned NOT NULL DEFAULT 0.00000,
  `downloads` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`usr_id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TmpUsers` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `money` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  PRIMARY KEY (`usr_id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Torrents` (
  `sid` varchar(100) NOT NULL DEFAULT '',
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `host_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL DEFAULT '',
  `downloaded` bigint(20) unsigned DEFAULT NULL,
  `uploaded` bigint(20) unsigned DEFAULT NULL,
  `size` bigint(20) unsigned DEFAULT NULL,
  `seed_until_rate` decimal(8,2) unsigned NOT NULL DEFAULT 0.00,
  `download_speed` int(10) unsigned DEFAULT NULL,
  `upload_speed` int(10) unsigned DEFAULT NULL,
  `files` text NOT NULL,
  `status` enum('WORKING','ERROR','SEEDING') NOT NULL DEFAULT 'WORKING',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `extras` text NOT NULL,
  `peers` smallint(5) unsigned NOT NULL DEFAULT 0,
  KEY `sid` (`sid`),
  KEY `user` (`usr_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Transactions` (
  `id` varchar(10) NOT NULL DEFAULT '',
  `usr_id` mediumint(9) unsigned NOT NULL DEFAULT 0,
  `amount` decimal(10,2) unsigned NOT NULL DEFAULT 0.00,
  `txn_id` varchar(100) NOT NULL DEFAULT '',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `aff_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ip` int(20) unsigned NOT NULL DEFAULT 0,
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `email` varchar(100) NOT NULL DEFAULT '',
  `verified` tinyint(4) unsigned NOT NULL DEFAULT 0,
  `name` varchar(16) NOT NULL DEFAULT '',
  `ref_url` varchar(255) NOT NULL DEFAULT '',
  `ipn_id` int(10) unsigned NOT NULL DEFAULT 0,
  `days` smallint(5) unsigned NOT NULL DEFAULT 0,
  `plugin` varchar(16) NOT NULL DEFAULT '',
  `domain` varchar(32) NOT NULL DEFAULT '',
  `rebill` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Translations` (
  `lang_id` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `trans_name` varchar(255) NOT NULL DEFAULT '',
  `trans_value` varchar(4096) NOT NULL DEFAULT '',
  PRIMARY KEY (`lang_id`,`trans_name`),
  KEY `lang` (`lang_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserData` (
  `usr_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`usr_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Users` (
  `usr_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `usr_login` varchar(32) NOT NULL DEFAULT '',
  `usr_password` varchar(100) NOT NULL DEFAULT '',
  `usr_email` varchar(64) NOT NULL DEFAULT '',
  `usr_adm` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_mod` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_status` enum('OK','PENDING','BANNED') NOT NULL DEFAULT 'OK',
  `usr_premium_expire` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `usr_aff_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `usr_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `usr_lastlogin` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `usr_lastip` int(20) unsigned NOT NULL DEFAULT 0,
  `usr_pay_email` varchar(255) NOT NULL DEFAULT '',
  `usr_pay_type` varchar(16) NOT NULL DEFAULT '',
  `usr_disk_space` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `usr_disk_used` bigint(20) unsigned NOT NULL DEFAULT 0,
  `usr_money` decimal(11,5) unsigned NOT NULL DEFAULT 0.00000,
  `usr_no_emails` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_security_lock` varchar(8) NOT NULL DEFAULT '',
  `usr_reseller` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_notes` text NOT NULL,
  `usr_premium_only` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_premium_dl_only` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_sales_rate` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_allowed_ips` varchar(255) NOT NULL DEFAULT '',
  `usr_monitor` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_uploads_on` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_social_id` varchar(64) NOT NULL DEFAULT '',
  `usr_website_rate` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_no_expire` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_ftp_password` varchar(16) NOT NULL DEFAULT '',
  `usr_embed_title` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_api_key` varchar(32) NOT NULL DEFAULT '',
  `usr_channel_name` varchar(255) NOT NULL DEFAULT '',
  `usr_files_used` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `usr_login_code` varchar(64) NOT NULL DEFAULT '',
  `usr_password_changed` date NOT NULL DEFAULT '0000-00-00',
  `usr_vip` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `usr_no_file_delete` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`usr_id`),
  KEY `login` (`usr_login`),
  KEY `aff_id` (`usr_aff_id`),
  KEY `usr_social_id` (`usr_social_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Views` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `ip` int(10) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `money` decimal(6,5) unsigned NOT NULL DEFAULT 0.00000,
  `owner_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `size` bigint(20) unsigned NOT NULL DEFAULT 0,
  `finished` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `referer` varchar(255) NOT NULL DEFAULT '',
  `embed` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `download` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `premium` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `adb` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `country` char(2) NOT NULL DEFAULT 'XX',
  `money_code` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `watch_sec` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`file_id`,`ip`),
  KEY `created` (`created`),
  KEY `ip` (`ip`,`download`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Votes` (
  `file_id` int(10) unsigned NOT NULL DEFAULT 0,
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `vote` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`file_id`,`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Websites` (
  `usr_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `domain` varchar(64) NOT NULL DEFAULT '',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `money_profit` decimal(9,5) unsigned NOT NULL DEFAULT 0.00000,
  `money_sales` decimal(7,2) unsigned NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`domain`),
  KEY `user` (`usr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

