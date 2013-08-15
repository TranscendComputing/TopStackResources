/* Populate defaults for initial users. */

CREATE TABLE IF NOT EXISTS `rds_ec2_security_group`(
  `rds_ec2_security_group_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rds_sec_grp_id` bigint(20) DEFAULT NULL,
  `ec2_security_group_owner_id` varchar(64) NOT NULL,
  `ec2_security_group_name` varchar(64) NOT NULL,
  `status` varchar(16) NOT NULL,
  PRIMARY KEY (`rds_ec2_security_group_id`)
) ENGINE=InnoDB;

DROP TABLE if EXISTS rds_security_group;

CREATE TABLE `rds_security_group`(
  `rds_db_security_group_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dbsecurityGroupDescription` varchar(255) DEFAULT NULL,
  `dbsecurityGroupName` varchar(255) DEFAULT NULL,
  `internals` varchar(255) DEFAULT NULL,
  `port` int(11) NOT NULL,
  `stackId` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `transcendOnly` bit(1) NOT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`rds_db_security_group_id`),
  KEY `FKA26DE43E84B790BA` (`account_id`),
  CONSTRAINT `FKA26DE43E84B790BA` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB;


insert into rds_security_group (dbsecurityGroupDescription, dbsecurityGroupName, port, transcendOnly, account_id)
select 'Default Security Group', 'default', 0, 0, account.id
from account;

DROP TABLE IF EXISTS `HAZELCAST_NODE`;
DROP TABLE IF EXISTS `HAZELCAST_CONF`;

CREATE TABLE `HAZELCAST_CONF` (
  `groupId` bigint(20) NOT NULL AUTO_INCREMENT,
  `availabilityZone` varchar(255) DEFAULT NULL,
  `groupName` varchar(255) DEFAULT NULL,
  `groupPW` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`groupId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

INSERT INTO `HAZELCAST_CONF` VALUES (1, 'nova', 'dev', 'dev-pass');

CREATE TABLE `HAZELCAST_NODE` (
  `nodeId` bigint(20) NOT NULL AUTO_INCREMENT,
  `dns` varchar(255) DEFAULT NULL,
  `ipAddress` varchar(255) DEFAULT NULL,
  `HazelcastConfiguration` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`nodeId`),
  KEY `FK5AFC5D1AE6A0B361` (`HazelcastConfiguration`),
  CONSTRAINT `FK5AFC5D1AE6A0B361` FOREIGN KEY (`HazelcastConfiguration`) REFERENCES `HAZELCAST_CONF` (`groupId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

INSERT INTO `HAZELCAST_NODE` VALUES (1, 'localhost:5701','localhost:5701',1);

CREATE TABLE IF NOT EXISTS `zones` (
  `id` varchar(255) NOT NULL,
  `accountId` bigint(20) NOT NULL,
  `callerReference` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idIndex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `changes` (
  `ID` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `submit_time` varchar(255) DEFAULT NULL,
  `zone_table` varchar(255) DEFAULT NULL,
  `request` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DELIMITER //

CREATE PROCEDURE alter_elasticache_cluster()
  BEGIN
    SELECT COUNT(*) INTO @targetExists FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'elasticache_cluster' AND table_schema = 'topstack' AND column_name = 'status';
    IF @targetExists > 0 THEN
      ALTER TABLE `topstack`.`elasticache_cluster` MODIFY COLUMN `status` VARCHAR(30)  CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL;
    END IF;
  END//

DELIMITER ;

CALL alter_elasticache_cluster();
DROP PROCEDURE alter_elasticache_cluster;

DELIMITER //

CREATE PROCEDURE drop_index_elasticache_parameter_group()
  BEGIN
    SELECT COUNT(*) INTO @indexExists FROM information_schema.statistics WHERE table_schema = 'topstack' AND table_name = 'elasticache_parameter_group' AND column_name = 'name';
    IF @indexExists > 0 THEN
      ALTER TABLE `topstack`.`elasticache_parameter_group` DROP INDEX `name`;
    END IF;
  END//

DELIMITER ;

CALL drop_index_elasticache_parameter_group();
DROP PROCEDURE drop_index_elasticache_parameter_group;

DELIMITER //

CREATE PROCEDURE alterZonesTableIfNeeded()
  BEGIN
    SELECT COLUMN_NAME INTO @colName FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'zones' AND table_schema = 'topstack' AND column_name = 'tableName';
    IF @colName IS NULL THEN
      ALTER TABLE `zones` ADD tableName varchar(255);
    END IF;
  END//

DELIMITER ;

CALL alterZonesTableIfNeeded();

DROP PROCEDURE alterZonesTableIfNeeded;
UPDATE `zones` SET tableName = concat('table', floor(rand() * 10000));

CREATE TABLE IF NOT EXISTS `rrSet` (
  `rrSet_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `rdata` varchar(255) DEFAULT NULL,
  `rdtype` varchar(255) DEFAULT NULL,
  `sid` varchar(255) DEFAULT NULL,
  `ttl` bigint(20) NOT NULL,
  `weight` bigint(20) NOT NULL,
  `zoneId` varchar(255) DEFAULT NULL,
  `zoneName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rrSet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



DELIMITER //

CREATE PROCEDURE alterRrSetTableIfNeeded()
  BEGIN
    SELECT COLUMN_NAME INTO @colName FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'rrSet' AND table_schema = 'topstack' AND column_name = 'zoneName';
    IF @colName IS NULL THEN
      ALTER TABLE rrSet ADD COLUMN zoneName VARCHAR(255);
    END IF;
  END//

DELIMITER ;

CALL alterRrSetTableIfNeeded();

DROP PROCEDURE alterRrSetTableIfNeeded;

CREATE TABLE IF NOT EXISTS `cf_stack` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `disableRollBack` bit(1) DEFAULT NULL,
  `notifications` varchar(255) DEFAULT NULL,
  `parameters` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `stackId` varchar(255) DEFAULT NULL,
  `stackName` varchar(255) DEFAULT NULL,
  `templateBody` varchar(60000) DEFAULT NULL,
  `templateURL` varchar(255) DEFAULT NULL,
  `timeoutInMins` int(11) NOT NULL,
  `urn` varchar(255) DEFAULT NULL,
  `userId` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `topstack`.`cf_stack` MODIFY COLUMN `templateBody` VARCHAR(60000)  CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `elasticache_node`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `elasticache_node_address` varchar(256) DEFAULT NULL,
  `cluster_id` bigint(20) NOT NULL,
  `created_time` datetime NOT NULL,
  `instance_id` varchar(256) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  `parameter_group_status` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

ALTER TABLE `topstack`.`elasticache_node` MODIFY COLUMN `status` VARCHAR(32)
CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL;

DROP TABLE IF EXISTS QRTZ_JOB_LISTENERS;
DROP TABLE IF EXISTS QRTZ_TRIGGER_LISTENERS;
DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;
CREATE TABLE QRTZ_JOB_DETAILS(
JOB_NAME VARCHAR(200) NOT NULL,
JOB_GROUP VARCHAR(200) NOT NULL,
DESCRIPTION VARCHAR(250) NULL,
JOB_CLASS_NAME VARCHAR(250) NOT NULL,
IS_DURABLE VARCHAR(1) NOT NULL,
IS_VOLATILE VARCHAR(1) NOT NULL,
IS_STATEFUL VARCHAR(1) NOT NULL,
REQUESTS_RECOVERY VARCHAR(1) NOT NULL,
JOB_DATA BLOB NULL,
PRIMARY KEY (JOB_NAME,JOB_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_JOB_LISTENERS (
JOB_NAME VARCHAR(200) NOT NULL,
JOB_GROUP VARCHAR(200) NOT NULL,
JOB_LISTENER VARCHAR(200) NOT NULL,
PRIMARY KEY (JOB_NAME,JOB_GROUP,JOB_LISTENER),
INDEX (JOB_NAME, JOB_GROUP),
FOREIGN KEY (JOB_NAME,JOB_GROUP)
REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_TRIGGERS (
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
JOB_NAME VARCHAR(200) NOT NULL,
JOB_GROUP VARCHAR(200) NOT NULL,
IS_VOLATILE VARCHAR(1) NOT NULL,
DESCRIPTION VARCHAR(250) NULL,
NEXT_FIRE_TIME BIGINT(13) NULL,
PREV_FIRE_TIME BIGINT(13) NULL,
PRIORITY INTEGER NULL,
TRIGGER_STATE VARCHAR(16) NOT NULL,
TRIGGER_TYPE VARCHAR(8) NOT NULL,
START_TIME BIGINT(13) NOT NULL,
END_TIME BIGINT(13) NULL,
CALENDAR_NAME VARCHAR(200) NULL,
MISFIRE_INSTR SMALLINT(2) NULL,
JOB_DATA BLOB NULL,
PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
INDEX (JOB_NAME, JOB_GROUP),
FOREIGN KEY (JOB_NAME,JOB_GROUP)
REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_SIMPLE_TRIGGERS (
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
REPEAT_COUNT BIGINT(7) NOT NULL,
REPEAT_INTERVAL BIGINT(12) NOT NULL,
TIMES_TRIGGERED BIGINT(10) NOT NULL,
PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
INDEX (TRIGGER_NAME, TRIGGER_GROUP),
FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_CRON_TRIGGERS (
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
CRON_EXPRESSION VARCHAR(120) NOT NULL,
TIME_ZONE_ID VARCHAR(80),
PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
INDEX (TRIGGER_NAME, TRIGGER_GROUP),
FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_BLOB_TRIGGERS (
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
BLOB_DATA BLOB NULL,
PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
INDEX (TRIGGER_NAME, TRIGGER_GROUP),
FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_TRIGGER_LISTENERS (
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
TRIGGER_LISTENER VARCHAR(200) NOT NULL,
PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_LISTENER),
INDEX (TRIGGER_NAME, TRIGGER_GROUP),
FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP)
REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_CALENDARS (
CALENDAR_NAME VARCHAR(200) NOT NULL,
CALENDAR BLOB NOT NULL,
PRIMARY KEY (CALENDAR_NAME))
ENGINE=InnoDB;

CREATE TABLE QRTZ_PAUSED_TRIGGER_GRPS (
TRIGGER_GROUP VARCHAR(200) NOT NULL,
PRIMARY KEY (TRIGGER_GROUP))
ENGINE=InnoDB;

CREATE TABLE QRTZ_FIRED_TRIGGERS (
ENTRY_ID VARCHAR(95) NOT NULL,
TRIGGER_NAME VARCHAR(200) NOT NULL,
TRIGGER_GROUP VARCHAR(200) NOT NULL,
IS_VOLATILE VARCHAR(1) NOT NULL,
INSTANCE_NAME VARCHAR(200) NOT NULL,
FIRED_TIME BIGINT(13) NOT NULL,
PRIORITY INTEGER NOT NULL,
STATE VARCHAR(16) NOT NULL,
JOB_NAME VARCHAR(200) NULL,
JOB_GROUP VARCHAR(200) NULL,
IS_STATEFUL VARCHAR(1) NULL,
REQUESTS_RECOVERY VARCHAR(1) NULL,
PRIMARY KEY (ENTRY_ID))
ENGINE=InnoDB;

CREATE TABLE QRTZ_SCHEDULER_STATE (
INSTANCE_NAME VARCHAR(200) NOT NULL,
LAST_CHECKIN_TIME BIGINT(13) NOT NULL,
CHECKIN_INTERVAL BIGINT(13) NOT NULL,
PRIMARY KEY (INSTANCE_NAME))
ENGINE=InnoDB;

CREATE TABLE QRTZ_LOCKS (
LOCK_NAME VARCHAR(40) NOT NULL,
PRIMARY KEY (LOCK_NAME))
ENGINE=InnoDB;

INSERT INTO QRTZ_LOCKS values('TRIGGER_ACCESS');
INSERT INTO QRTZ_LOCKS values('JOB_ACCESS');
INSERT INTO QRTZ_LOCKS values('CALENDAR_ACCESS');
INSERT INTO QRTZ_LOCKS values('STATE_ACCESS');
INSERT INTO QRTZ_LOCKS values('MISFIRE_ACCESS');
commit;

CREATE TABLE IF NOT EXISTS `ts_inst_lb` (
  `id` INT  NOT NULL AUTO_INCREMENT,
  `hostnm` TEXT(256)  NOT NULL,
  `inport` INT  NOT NULL,
  `outport` INT  NOT NULL,
  `backend` TEXT(256)  NOT NULL,
  PRIMARY KEY (`id`)
)
ENGINE = MyISAM
COMMENT = 'Topstack load balancer';