CREATE SCHEMA IF NOT EXISTS `onap_demo` DEFAULT CHARACTER SET utf8 ;
USE `onap_demo` ;

-- -----------------------------------------------------
-- Table `onap_demo`.`cell`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `onap_demo`.`cell`(
  `cell_id` varchar(45) NOT NULL,
  `last_modifiedts` datetime(6) NOT NULL,
  `location` varchar(200) DEFAULT NULL,
  `network_id` varchar(45) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `pci_value` bigint(20) NOT NULL,
  `pnf_id` varchar(255) NOT NULL,
  PRIMARY KEY (`cell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -----------------------------------------------------
-- Table `onap_demo`.`cell_nbr_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `onap_demo`.`cell_nbr_info`(
  `cell_id` varchar(45) NOT NULL,
  `target_cell_id` varchar(45) NOT NULL,
  `ho` bit(1) NOT NULL,
  PRIMARY KEY (`cell_id`,`target_cell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE USER 'db_user'@'%' IDENTIFIED BY 'db_password';
GRANT ALL ON onap_demo.* TO 'db_user'@'%';
CREATE USER 'db_user'@'%' IDENTIFIED BY 'db_password';
GRANT ALL ON onap_demo.* TO 'db_user'@'%';

