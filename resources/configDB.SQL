# SQL file for initializing TopStack database.
# For distribution, all comments are removed, as are grants and create and drop database.

DROP DATABASE  IF EXISTS `topstack`;
CREATE DATABASE `topstack`;
GRANT ALL ON `topstack`.* TO 'topstack'@'localhost' identified by 'topstack_password';

# On dev boxes, allow from all hosts.
GRANT ALL ON `topstack`.* TO 'topstack'@'%' identified by 'topstack_password';

USE `topstack`;

CREATE TABLE `schema_version` (
  `version` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `type` varchar(10) NOT NULL,
  `script` varchar(200) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(30) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int(11) DEFAULT NULL,
  `state` varchar(15) NOT NULL,
  `current_version` tinyint(1) NOT NULL,
  PRIMARY KEY (`version`),
  UNIQUE KEY `version` (`version`),
  UNIQUE KEY `script` (`script`),
  KEY `schema_version_current_version_index` (`current_version`)
) ENGINE=InnoDB;

INSERT INTO `topstack`.`schema_version` (`version`, `description`, `type`, `script`,
`installed_by`, `execution_time`, `state`, `current_version` ) VALUES
('1.0', 'configDB Init', 'INIT', 'configDB Init', 'topstack', 0, 'SUCCESS', 1);

CREATE TABLE  `topstack`.`availability_zone` (
  `availability_zone` varchar(50) default NULL,
  `bak_window` varchar(255) default NULL,
  `mntn_window` varchar(255) default NULL,
  `def` boolean default false,
  `cloud_type` varchar(255) default NULL,
  PRIMARY KEY (`availability_zone`)
) ENGINE=InnoDB;
INSERT INTO `topstack`.`availability_zone` (`availability_zone`, `bak_window`, `mntn_window`, `def`, `cloud_type` ) VALUES ('topstackcluster', null, null, true, 'Eucalyptus');
INSERT INTO `topstack`.`availability_zone` (`availability_zone`, `bak_window`, `mntn_window`, `def`, `cloud_type` ) VALUES ('nova', null, null, false, 'OpenStack');
INSERT INTO `topstack`.`availability_zone` (`availability_zone`, `bak_window`, `mntn_window`, `def`, `cloud_type` ) VALUES ('xen-tier2', null, null, false, 'Eucalyptus');

CREATE TABLE  `topstack`.`azmap` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `availability_zone` varchar(255) DEFAULT NULL,
  `map_key` varchar(255) DEFAULT NULL,
  `map_type` varchar(255) DEFAULT NULL,
  `map_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
INSERT INTO `topstack`.`azmap` (`availability_zone`, `map_type`, `map_key`, `map_value` ) VALUES ('topstackcluster', 'db_instance_type', 'db.m1.small', 'm1.small');
INSERT INTO `topstack`.`azmap` (`availability_zone`, `map_type`, `map_key`, `map_value` ) VALUES ('topstackcluster', 'db_instance_type', 'db.c1.medium', 'c1.medium');
INSERT INTO `topstack`.`azmap` (`availability_zone`, `map_type`, `map_key`, `map_value` ) VALUES ('topstackcluster', 'db_instance_type', 'db.m1.large', 'm1.large');

CREATE TABLE  `topstack`.`system_defaults` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) default NULL,
  `key_name` varchar(50) default NULL,
  `key_value` varchar(255) default NULL,
  `def` boolean default false,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value`, `def` ) VALUES ('EBS::Stacks', '32bit Amazon Linux running Tomcat 6', '32bit Amazon Linux running Tomcat 6', true);
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value`, `def` ) VALUES ('EBS::Stacks', '64bit Amazon Linux running Tomcat 6', '64bit Amazon Linux running Tomcat 6', false);
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value`, `def` ) VALUES ('EBS::Stacks', '32bit Amazon Linux running Tomcat 7', '32bit Amazon Linux running Tomcat 7', false);
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value`, `def` ) VALUES ('EBS::Stacks', '64bit Amazon Linux running Tomcat 7', '64bit Amazon Linux running Tomcat 7', false);
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value`, `def` ) VALUES ('EBS::AvailabilityZone', 'default', 'nova', true);

INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value` ) VALUES ('RDS::User', 'InstanceLimit', '10');
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value` ) VALUES ('RDS::User', 'StorageLimit', '100');
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value` ) VALUES ('RDS::User', 'ParameterGroupLimit', '10');
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value` ) VALUES ('RDS::User', 'SecurityGroupLimit', '10');
INSERT INTO `topstack`.`system_defaults` (`type`, `key_name`, `key_value` ) VALUES ('RDS::User', 'SnapshotLimit', '10');

CREATE TABLE  `topstack`.`account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) default NULL,
  `access_key` varchar(255) default NULL,
  `secret_key` varchar(255) default NULL,
  `def_security_groups` varchar(255) default NULL,
  `def_key_name` varchar(255) default NULL,
  `emails` varchar(255) default NULL,
  `def_zone` varchar(255) default NULL,
  `tenant` varchar(255) default NULL,
  `api_username` varchar(255) default NULL,
  `api_password` varchar(255) default NULL,
  `role_name` VARCHAR(40) default "ROLE_USER",
  `enabled` tinyint(1) default TRUE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;
-- Account # 1 is ALWAYS a placeholder for the "SYSTEM" account used by resources such as parameter groups, security groups, etc.
-- DO NOT CHANGE
INSERT INTO `topstack`.`account` (`name`, `access_key`, `secret_key`,
`def_security_groups`, `def_key_name`, `emails`, `def_zone`, `role_name` ) VALUES
('system-account', '', '', '', '', 'admin@transcendcomputing.com', 'none', 'ROLE_ADMIN');

-- USER ACCOUNTS:
UPDATE account set api_username = access_key, api_password = secret_key;

CREATE TABLE `topstack`.`rds_dbengine` (
  	`id` bigint(20) NOT NULL AUTO_INCREMENT,
	`engine` VARCHAR(12),
	`engine_version` VARCHAR(8),
	`_default` BOOLEAN,
	`dbparameterGroupFamily` VARCHAR(30),
	`next_minor_version` VARCHAR(8),
	`minor_version_release_date` DATETIME,
	`next_major_version` VARCHAR(8),
	`major_version_release_date` DATETIME,
	primary key(`id`)
) ENGINE=InnoDB;
-- INSERT into topstack.rds_dbengine (`engine`, `engine_version`, `dbparameterGroupFamily`, `_default`) values ('mysql', '5.1', 'mysql5.1', false);
INSERT into topstack.rds_dbengine (`engine`, `engine_version`, `dbparameterGroupFamily`, `_default`) values ('mysql', '5.5', 'mysql5.5', true);
-- INSERT into topstack.rds_dbengine (`engine`, `engine_version`, `dbparameterGroupFamily`, `_default`) values ('oracle-ee', '11.2.0.2.v2', 'oracle-ee-11.2', false);
-- INSERT into topstack.rds_dbengine (`engine`, `engine_version`, `dbparameterGroupFamily`, `_default`) values ('oracle-se', '11.2.0.2.v2', 'oracle-se-11.2', false);
-- INSERT into topstack.rds_dbengine (`engine`, `engine_version`, `dbparameterGroupFamily`, `_default`) values ('oracle-se1', '11.2.0.2.v2', 'oracle-se1-11.2', false);


CREATE TABLE  `topstack`.`gi_image_metadata` (
  `long_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `image_id` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `os` varchar(255) DEFAULT NULL,
  `GoldenStatus` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `architecture` varchar(255) DEFAULT NULL,
  `cloud` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`long_id`)
) ENGINE=InnoDB;

CREATE TABLE `topstack`.`ImageMetadataBean_associations` (
  `ImageMetadataBean_long_id` bigint(20) NOT NULL,
  `associations` varchar(255) DEFAULT NULL,
  KEY `FKB9611FD7BDB03E17` (`ImageMetadataBean_long_id`),
  CONSTRAINT `FKB9611FD7BDB03E17` FOREIGN KEY (`ImageMetadataBean_long_id`) REFERENCES `gi_image_metadata` (`long_id`)
) ENGINE=InnoDB;


INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('emi-BAEA0FF4', 'Linux', 'Centos-5.5', 'none', 'machine',  'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('eki-3A4A0D5A', 'Linux', 'Centos-5.5', 'none', 'kernel',  'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('eri-B2C7101A', 'Linux', 'Centos-5.5', 'none', 'ramdisk', 'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('emi-BB0D0FEA', 'Linux', 'Centos-5.6', 'none', 'machine',  'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('eki-3A4A0D5A', 'Linux', 'Centos-5.6', 'none', 'kernel',  'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('eri-B2C7101A', 'Linux', 'Centos-5.6', 'none', 'ramdisk', 'x86_64', 'eucalyptus');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('ami-00000008', 'Linux', 'CentOS', 'none', 'machine', 'x86_64', 'openstack');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('aki-00000005', 'Linux', 'CentOS', 'none', 'kernel', 'x86_64', 'openstack');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('ari-00000006', 'Linux', 'CentOS', 'none', 'ramdisk', 'x86_64', 'openstack');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('ami-00000006', 'Linux', 'CentOS 5.7', 'none', 'machine', 'x86_64', 'openstack-beta');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('aki-00000001', 'Linux', 'CentOS 5.7', 'none', 'kernel', 'x86_64', 'openstack-beta');
INSERT INTO `topstack`.`gi_image_metadata` (image_id, platform, os, GoldenStatus, type, architecture, cloud) VALUES('ari-00000002', 'Linux', 'CentOS 5.7', 'none', 'ramdisk', 'x86_64', 'openstack-beta');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('1','eki-3A4A0D5A');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('1','eri-B2C7101A');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('4','eki-3A4A0D5A');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('4','eri-B2C7101A');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('7','aki-00000002');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('7','ari-00000003');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('10','aki-00000001');
INSERT INTO `topstack`.`ImageMetadataBean_associations` (ImageMetadataBean_long_id, associations) VALUES ('10','ari-00000002');

CREATE TABLE  `topstack`.`hypervisors` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `protocol` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `enable` char(1) NOT NULL,
  `account_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `topstack`.`service` (
  `service_id` int(11) NOT NULL AUTO_INCREMENT,
  `service_name` varchar(32) NOT NULL,
  `service_name_abbreviation` varchar(8) NOT NULL,
  PRIMARY KEY (`service_id`)
) ENGINE=InnoDB;

-- The service abbreviations match those used in ToughUI cloud_services
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Relational Database Service', 'RDS');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Scalable Queue', 'SQS');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Load Balancer Service', 'ELB');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'DNS 53', 'DNS');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Auto Scale', 'AS');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Elastic Servlet', 'AWSEB');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Cloud Monitor', 'ACW');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Object Storage', 'S3');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Compute Service', 'EC2');
INSERT INTO topstack.service (`service_name`, `service_name_abbreviation` ) values ( 'Block Storage', 'EBS');

--
-- ELASTICACHE DEFAULTS
--

CREATE TABLE `topstack`.`elasticache_parameter_family` (
  `id` int(11) NOT NULL auto_increment,
  `family` varchar(24) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB ;
INSERT INTO topstack.elasticache_parameter_family (`family`) values ( 'memcached1.4');

CREATE TABLE `topstack`.`elasticache_parameter_group` (
  `id` int(11) NOT NULL auto_increment,
  `acid` int(11) default NULL,
  `family_id` int(11) NOT NULL,
  `name` varchar(24) NOT NULL,
  `description` varchar(128) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB ;
INSERT INTO topstack.elasticache_parameter_group (`name`, `description`, `acid`,`family_id`) values ( 'default.memcached1.4', 'Default parameter group for memcached1.4', 0,1);

CREATE TABLE `topstack`.`elasticache_parameter` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` int(11) NOT NULL,
  `node_specific` bit(1) NOT NULL,
  `allowed_values` longtext,
  `data_type` varchar(20) default NULL,
  `description` longtext,
  `is_modifiable` bit(1) NOT NULL,
  `name` varchar(256) default NULL,
  `parameter_value` varchar(256) default NULL,
  `source` varchar(20) default NULL,
  `minimum_engine_version` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB ;
INSERT INTO topstack.elasticache_parameter (`group_id`,`node_specific`,`name`, `allowed_values`, `data_type`,`is_modifiable`,
	`parameter_value`,`source`,`minimum_engine_version`,`description`)
SELECT 1, 0, 'backlog_queue_limit','1-10000','integer',0,'1024','system',1,'The backlog queue limit.'
UNION ALL
SELECT 1, 0, 'binding_protocol','auto,binary,ascii','string',0,'auto','system',1,'Binding protocol.'
UNION ALL
SELECT 1, 0, 'cas_disabled','0,1','boolean',1,'0','system',1,'If supplied, CAS operations will be disabled, and items stored will consume 8 bytes less than with CAS enabled.'
UNION ALL
SELECT 1, 0, 'chunk_size','1-1024','integer',1,'48','system',1,'The minimum amount of space to allocate for the smallest item''s key + value + flags, in bytes.'
UNION ALL
SELECT 1, 0, 'chunk_size_growth_factor','1.01-100.00','float',1,'1.25','system',1,'The growth factor controlling the size of each successive memcached chunk - each chunk will be chunk_size_growth_factor times larger than the previous chunk.'
UNION ALL
SELECT 1, 0, 'error_on_memory_exhausted','0,1','boolean',1,'0','system',1,'If supplied, when there is no more memory to store items, memcached will return an error rather than evicting items.'
UNION ALL
SELECT 1, 0, 'large_memory_pages','0,1','boolean',0,'0','system',1,'Try to use large memory pages.'
UNION ALL
SELECT 1, 0, 'lock_down_paged_memory','0,1','boolean',0,'0','system',1,'Lock down all paged memory.'
UNION ALL
SELECT 1, 0, 'max_item_size','1024-134217728','integer',1,'1048576','system',1,'The size of the largest item storable in the cache, in bytes.'
UNION ALL
SELECT 1, 0, 'max_simultaneous_connections','3-65000','integer',0,'65000','system',1,'The maximum number of simultaneous connections.'
UNION ALL
SELECT 1, 0, 'maximize_core_file_limit','0,1','boolean',0,'0','system',1,'Maximize core file limit.'
UNION ALL
SELECT 1, 0, 'memcached_connections_overhead','0-100000','integer',1, '100','system',1,'The amount of memory to reserve for memcached connections and other miscellaneous overhead.'
UNION ALL
SELECT 1, 0, 'requests_per_event','1-1000','integer',0,'20','system',1,'The maximum number of requests per event, limits the number of requests processed for a given connection to prevent starvation.'
UNION ALL
SELECT 1, 1, 'max_cache_memory','1-100000','integer',0,'1000','system',1,'The maximum configurable amount of memory to use to store items, in megabytes.'
UNION ALL
SELECT 1, 1, 'num_threads','1-8','integer',0,'2','system',1,'The number of memcached threads to use.';

CREATE TABLE `topstack`.`cache_node_type` (
  `id` int(11) NOT NULL auto_increment,
  `description` varchar(64) default NULL,
  `node_type` varchar(24) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB;

INSERT INTO `topstack`.`cache_node_type`(node_type,description)
SELECT 'cache.m1.small', ''
UNION ALL
SELECT 'cache.m1.large', ''
UNION ALL
SELECT 'cache.m1.xlarge', ''
UNION ALL
SELECT 'cache.m2.xlarge', ''
UNION ALL
SELECT 'cache.m2.2xlarge', ''
UNION ALL
SELECT 'cache.m2.4xlarge', ''
UNION ALL
SELECT 'cache.c1.xlarge', '';

CREATE TABLE `topstack`.`node_specific_value` (
  `id` int(11) NOT NULL auto_increment,
  `parameter_id` int(11) NOT NULL,
  `node_type_id` int(11) NOT NULL,
  `parameter_value` varchar(256) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB ;
INSERT INTO topstack.node_specific_value(parameter_id,node_type_id,parameter_value)
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),1,'1300'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),2,'6600'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),3,'7100'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),4,'14600'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),5,'16700'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),6,'33800'
UNION ALL
SELECT (SELECT id FROM topstack.elasticache_parameter WHERE name = 'max_cache_memory' ),7,'68000';

--
-- End Elasticache config
--


-- Elasticbeanstalk: default configuration template and its default option setting values
CREATE TABLE  `topstack`.`template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) default NULL,
  `app_name` varchar(255) default NULL,
  `created_teime` DATETIME,
  `deployStatus` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `env_id` varchar(255) default NULL,
  `env_name` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `src_app_name` varchar(255) default NULL,
  `src_template` varchar(255) default NULL,
  `stack` varchar(255) default NULL,
  `updated_time` DATETIME,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
INSERT INTO topstack.template (`description`, `name`, `stack`, `user_id` ) values ( 'Default configuration template for 32bit Linux with Tomcat 6', 'DefaultConfiguration', '32bit Amazon Linux running Tomcat 6', 0);
INSERT INTO topstack.template (`description`, `name`, `stack`, `user_id` ) values ( 'Default configuration template for 64bit Linux with Tomcat 6', 'DefaultConfiguration', '64bit Amazon Linux running Tomcat 6', 0);
INSERT INTO topstack.template (`description`, `name`, `stack`, `user_id` ) values ( 'Default configuration template for 32bit Linux with Tomcat 7', 'DefaultConfiguration', '32bit Amazon Linux running Tomcat 7', 0);
INSERT INTO topstack.template (`description`, `name`, `stack`, `user_id` ) values ( 'Default configuration template for 64bit Linux with Tomcat 7', 'DefaultConfiguration', '64bit Amazon Linux running Tomcat 7', 0);

CREATE TABLE  `topstack`.`config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name_space` varchar(255) default NULL,
  `opt` varchar(255) default NULL,
  `val` varchar(255) default NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('ImageId', 'ami-00000011', 'aws:autoscaling:launchconfiguration');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Notification Endpoint', null, 'aws:elasticbeanstalk:sns:topics');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('PARAM1', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('PARAM2', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('PARAM3', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('PARAM4', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('PARAM5', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('JDBC_CONNECTION_STRING', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('SecurityGroups', 'elasticbeanstalk-default', 'aws:autoscaling:launchconfiguration');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('UnhealthyThreshold', '5', 'aws:elb:healthcheck');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('InstanceType', 'm1.tiny', 'aws:autoscaling:launchconfiguration');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Statistic', 'Average', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('LoadBalancerHTTPSPort', 'OFF', 'aws:elb:loadbalancer');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Stickiness Cookie Expiration', '0', 'aws:elb:policies');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('MeasureName', 'NetworkOut', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Interval', '30', 'aws:elb:healthcheck');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Application Healthcheck URL', '/', 'aws:elasticbeanstalk:application');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Notification Topic ARN', null, 'aws:elasticbeanstalk:sns:topics');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('LowerBreachScaleIncrement', '-1', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('XX:MaxPermSize', '64m', 'aws:elasticbeanstalk:container:tomcat:jvmoptions');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('UpperBreachScaleIncrement', '1', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('MinSize', '1', 'aws:autoscaling:asg');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Custom Availability Zones', 'nova', 'aws:autoscaling:asg');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Availability Zones', 'Any 1', 'aws:autoscaling:asg');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('LogPublicationControl', 'false', 'aws:elasticbeanstalk:hostmanager');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('JVM Options', null, 'aws:elasticbeanstalk:container:tomcat:jvmoptions');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Notification Topic Name', null, 'aws:elasticbeanstalk:sns:topics');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('LoadBalancerHTTPPort', '80', 'aws:elb:loadbalancer');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Timeout', '5', 'aws:elb:healthcheck');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('BreachDuration', '2', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('MonitoringInterval', '5 minute', 'aws:autoscaling:launchconfiguration');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('MaxSize', '4', 'aws:autoscaling:asg');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('LowerThreshold', '2000000', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('AWS_SECRET_KEY', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('AWS_ACCESS_KEY_ID', null, 'aws:elasticbeanstalk:application:environment');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('UpperThreshold', '6000000', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Notification Protocol', 'email', 'aws:elasticbeanstalk:sns:topics');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Unit', 'Bytes', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Xmx', '256m', 'aws:elasticbeanstalk:container:tomcat:jvmoptions');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Cooldown', '360', 'aws:autoscaling:asg');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Period', '1', 'aws:autoscaling:trigger');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Xms', '256m', 'aws:elasticbeanstalk:container:tomcat:jvmoptions');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('EC2KeyName', null, 'aws:autoscaling:launchconfiguration');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('Stickiness Policy', 'false', 'aws:elb:policies');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('HealthyThreshold', '3', 'aws:elb:healthcheck');
INSERT INTO topstack.config (`opt`, `val`, `name_space` ) values ('SSLCertificateId', null, 'aws:elb:loadbalancer');

CREATE TABLE  `topstack`.`template_configs` (
  `template_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL
) ENGINE=InnoDB;
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 1);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 2);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 3);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 4);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 5);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 6);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 7);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 8);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 9);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 10);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 11);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 12);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 13);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 14);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 15);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 16);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 17);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 18);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 19);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 20);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 21);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 22);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 23);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 24);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 25);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 26);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 27);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 28);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 29);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 30);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 31);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 32);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 33);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 34);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 35);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 36);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 37);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 38);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 39);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 40);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 41);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 42);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 43);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 44);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 45);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (1, 46);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 1);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 2);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 3);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 4);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 5);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 6);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 7);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 8);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 9);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 10);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 11);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 12);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 13);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 14);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 15);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 16);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 17);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 18);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 19);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 20);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 21);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 22);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 23);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 24);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 25);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 26);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 27);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 28);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 29);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 30);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 31);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 32);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 33);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 34);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 35);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 36);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 37);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 38);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 39);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 40);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 41);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 42);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 43);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 44);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 45);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (2, 46);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 1);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 2);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 3);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 4);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 5);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 6);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 7);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 8);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 9);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 10);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 11);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 12);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 13);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 14);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 15);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 16);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 17);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 18);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 19);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 20);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 21);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 22);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 23);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 24);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 25);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 26);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 27);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 28);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 29);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 30);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 31);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 32);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 33);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 34);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 35);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 36);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 37);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 38);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 39);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 40);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 41);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 42);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 43);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 44);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 45);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (3, 46);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 1);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 2);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 3);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 4);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 5);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 6);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 7);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 8);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 9);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 10);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 11);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 12);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 13);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 14);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 15);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 16);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 17);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 18);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 19);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 20);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 21);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 22);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 23);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 24);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 25);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 26);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 27);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 28);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 29);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 30);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 31);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 32);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 33);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 34);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 35);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 36);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 37);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 38);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 39);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 40);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 41);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 42);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 43);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 44);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 45);
INSERT INTO topstack.template_configs (`template_id`, `config_id`) values (4, 46);
-- end of Elasticbeanstal

-- RDS: default configurations
CREATE TABLE  `topstack`.`rds_dbparameter_group` (
  `rds_parameter_group_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dbparameterGroupFamily` varchar(255) default NULL,
  `dbparameterGroupName` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `account_id` bigint(20),
  PRIMARY KEY (`rds_parameter_group_id`)
) ENGINE=InnoDB;

-- INSERT INTO topstack.rds_dbparameter_group (`dbparameterGroupName`, `account_id`, `dbparameterGroupFamily`, `description` ) values ( 'default.mysql5.1', 1, 'mysql5.1', 'Default parameter group for mysql5.1');
INSERT INTO topstack.rds_dbparameter_group (`dbparameterGroupName`, `account_id`, `dbparameterGroupFamily`, `description` ) values ( 'default.mysql5.5', 1, 'mysql5.5', 'Default parameter group for mysql5.5');
-- INSERT INTO topstack.rds_dbparameter_group (`dbparameterGroupName`, `account_id`, `dbparameterGroupFamily`, `description` ) values ( 'default.oracle-ee-11.2', 1, 'oracle-ee-11.2', 'Default parameter group for oracle-ee-11.2');
-- INSERT INTO topstack.rds_dbparameter_group (`dbparameterGroupName`, `account_id`, `dbparameterGroupFamily`, `description` ) values ( 'default.oracle-se-11.2', 1, 'oracle-se-11.2', 'Default parameter group for oracle-se-11.2');
-- INSERT INTO topstack.rds_dbparameter_group (`dbparameterGroupName`, `account_id`, `dbparameterGroupFamily`, `description` ) values ( 'default.oracle-se1-11.2', 1, 'oracle-se1-11.2', 'Default parameter group for oracle-se1-11.2');

CREATE TABLE  `topstack`.`rds_parameter` (
  `rds_parameter_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `allowed_values` longtext default NULL,
  `apply_type` varchar(255) default NULL,
  `apply_m` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `is_modifiable` bit(1) default NULL,
  `minimum_engine_version` varchar(255) default NULL,
  `parameter_name` varchar(255) default NULL,
  `parameter_value` longtext default NULL,
  `source` varchar(255) default NULL,
  `data_type` varchar(255) default NULL,
  `rds_parameter_group_id` bigint(20),
  PRIMARY KEY (`rds_parameter_id`)
) ENGINE=InnoDB;

INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "allow-suspicious-udfs", NULL, "Controls whether user-defined functions that have only an xxx symbol for the main function can be loaded", "engine-default", "boolean", "0,1", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "auto_increment_increment", NULL, "Intended for use with master-to-master replication, and can be used to control the operation of AUTO_INCREMENT columns", "engine-default", "integer", "1-65535", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "auto_increment_offset", NULL, "Determines the starting point for the AUTO_INCREMENT column value", "engine-default", "integer", "1-65535", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "autocommit", NULL, "Sets the autocommit mode", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "automatic_sp_privileges", NULL, "When this variable has a value of 1 (the default), the server automatically grants the EXECUTE and ALTER ROUTINE privileges to the creator of a stored routine, if the user cannot already execute and alter or drop the routine.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "back_log", NULL, "The number of outstanding connection requests MySQL can have", "engine-default", "integer", "1-65535", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "basedir", "/rdsdbbin/mysql", "The MySQL installation base directory.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "binlog_cache_size", "32768", "The size of the cache to hold the SQL statements for the binary log during a transaction.", "system", "integer", "4096-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "binlog_format", "MIXED", "Row / Statement or Mixed replication", "system", "string", "ROW,STATEMENT,MIXED", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "bulk_insert_buffer_size", NULL, "Limits the size of the MyISAM cache tree in bytes per thread.", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "character-set-client-handshake", NULL, "Don\'t ignore character set information sent by the client.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_client", NULL, "The character set for statements that arrive from the client.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_connection", NULL, "The character set used for literals that do not have a character set introducer and for number-to-string conversion.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_database", NULL, "The character set used by the default database.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_filesystem", NULL, "The file system character set.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_results", NULL, "The character set used for returning query results to the client.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "character_set_server", NULL, "The server\'s default character set.", "engine-default", "string", "big5,dec8,cp850,hp8,koi8r,latin1,latin2,swe7,ascii,ujis,sjis,hebrew,tis620,euckr,koi8u,gb2312,greek,cp1250,gbk,latin5,armscii8,utf8,ucs2,cp866,keybcs2,macce,macroman,cp852,latin7,utf8mb4,cp1251,utf16,cp1256,cp1257,utf32,binary,geostd8,cp932,eucjpms", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "collation_connection", NULL, "The collation of the connection character set.", "engine-default", "string", "big5_chinese_ci,big5_bin,dec8_swedish_ci,dec8_bin,cp850_general_ci,cp850_bin,hp8_english_ci,hp8_bin,koi8r_general_ci,koi8r_bin,latin1_german1_ci,latin1_swedish_ci,latin1_danish_ci,latin1_german2_ci,latin1_bin,latin1_general_ci,latin1_general_cs,latin1_spanish_ci,latin2_czech_cs,latin2_general_ci,latin2_hungarian_ci,latin2_croatian_ci,latin2_bin,swe7_swedish_ci,swe7_bin,ascii_general_ci,ascii_bin,ujis_japanese_ci,ujis_bin,sjis_japanese_ci,sjis_bin,hebrew_general_ci,hebrew_bin,tis620_thai_ci,tis620_bin,euckr_korean_ci,euckr_bin,koi8u_general_ci,koi8u_bin,gb2312_chinese_ci,gb2312_bin,greek_general_ci,greek_bin,cp1250_general_ci,cp1250_czech_cs,cp1250_croatian_ci,cp1250_bin,cp1250_polish_ci,gbk_chinese_ci,gbk_bin,latin5_turkish_ci,latin5_bin,armscii8_general_ci,armscii8_bin,utf8_general_ci,utf8_bin,utf8_unicode_ci,utf8_icelandic_ci,utf8_latvian_ci,utf8_romanian_ci,utf8_slovenian_ci,utf8_polish_ci,utf8_estonian_ci,utf8_spanish_ci,utf8_swedish_ci,utf8_turkish_ci,utf8_czech_ci,utf8_danish_ci,utf8_lithuanian_ci,utf8_slovak_ci,utf8_spanish2_ci,utf8_roman_ci,utf8_persian_ci,utf8_esperanto_ci,utf8_hungarian_ci,utf8_sinhala_ci,ucs2_general_ci,ucs2_bin,ucs2_unicode_ci,ucs2_icelandic_ci,ucs2_latvian_ci,ucs2_romanian_ci,ucs2_slovenian_ci,ucs2_polish_ci,ucs2_estonian_ci,ucs2_spanish_ci,ucs2_swedish_ci,ucs2_turkish_ci,ucs2_czech_ci,ucs2_danish_ci,ucs2_lithuanian_ci,ucs2_slovak_ci,ucs2_spanish2_ci,ucs2_roman_ci,ucs2_persian_ci,ucs2_esperanto_ci,ucs2_hungarian_ci,ucs2_sinhala_ci,cp866_general_ci,cp866_bin,keybcs2_general_ci,keybcs2_bin,macce_general_ci,macce_bin,macroman_general_ci,macroman_bin,cp852_general_ci,cp852_bin,latin7_estonian_cs,latin7_general_ci,latin7_general_cs,latin7_bin,utf8mb4_general_ci,utf8mb4_bin,utf8mb4_unicode_ci,utf8mb4_icelandic_ci,utf8mb4_latvian_ci,utf8mb4_romanian_ci,utf8mb4_slovenian_ci,utf8mb4_polish_ci,utf8mb4_estonian_ci,utf8mb4_spanish_ci,utf8mb4_swedish_ci,utf8mb4_turkish_ci,utf8mb4_czech_ci,utf8mb4_danish_ci,utf8mb4_lithuanian_ci,utf8mb4_slovak_ci,utf8mb4_spanish2_ci,utf8mb4_roman_ci,utf8mb4_persian_ci,utf8mb4_esperanto_ci,utf8mb4_hungarian_ci,utf8mb4_sinhala_ci,cp1251_bulgarian_ci,cp1251_ukrainian_ci,cp1251_bin,cp1251_general_ci,cp1251_general_cs,utf16_general_ci,utf16_bin,utf16_unicode_ci,utf16_icelandic_ci,utf16_latvian_ci,utf16_romanian_ci,utf16_slovenian_ci,utf16_polish_ci,utf16_estonian_ci,utf16_spanish_ci,utf16_swedish_ci,utf16_turkish_ci,utf16_czech_ci,utf16_danish_ci,utf16_lithuanian_ci,utf16_slovak_ci,utf16_spanish2_ci,utf16_roman_ci,utf16_persian_ci,utf16_esperanto_ci,utf16_hungarian_ci,utf16_sinhala_ci,cp1256_general_ci,cp1256_bin,cp1257_lithuanian_ci,cp1257_bin,cp1257_general_ci,utf32_general_ci,utf32_bin,utf32_unicode_ci,utf32_icelandic_ci,utf32_latvian_ci,utf32_romanian_ci,utf32_slovenian_ci,utf32_polish_ci,utf32_estonian_ci,utf32_spanish_ci,utf32_swedish_ci,utf32_turkish_ci,utf32_czech_ci,utf32_danish_ci,utf32_lithuanian_ci,utf32_slovak_ci,utf32_spanish2_ci,utf32_roman_ci,utf32_persian_ci,utf32_esperanto_ci,utf32_hungarian_ci,utf32_sinhala_ci,binary,geostd8_general_ci,geostd8_bin,cp932_japanese_ci,cp932_bin,eucjpms_japanese_ci,eucjpms_bin", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "collation_server", NULL, "The server\'s default collation.", "engine-default", "string", "big5_chinese_ci,big5_bin,dec8_swedish_ci,dec8_bin,cp850_general_ci,cp850_bin,hp8_english_ci,hp8_bin,koi8r_general_ci,koi8r_bin,latin1_german1_ci,latin1_swedish_ci,latin1_danish_ci,latin1_german2_ci,latin1_bin,latin1_general_ci,latin1_general_cs,latin1_spanish_ci,latin2_czech_cs,latin2_general_ci,latin2_hungarian_ci,latin2_croatian_ci,latin2_bin,swe7_swedish_ci,swe7_bin,ascii_general_ci,ascii_bin,ujis_japanese_ci,ujis_bin,sjis_japanese_ci,sjis_bin,hebrew_general_ci,hebrew_bin,tis620_thai_ci,tis620_bin,euckr_korean_ci,euckr_bin,koi8u_general_ci,koi8u_bin,gb2312_chinese_ci,gb2312_bin,greek_general_ci,greek_bin,cp1250_general_ci,cp1250_czech_cs,cp1250_croatian_ci,cp1250_bin,cp1250_polish_ci,gbk_chinese_ci,gbk_bin,latin5_turkish_ci,latin5_bin,armscii8_general_ci,armscii8_bin,utf8_general_ci,utf8_bin,utf8_unicode_ci,utf8_icelandic_ci,utf8_latvian_ci,utf8_romanian_ci,utf8_slovenian_ci,utf8_polish_ci,utf8_estonian_ci,utf8_spanish_ci,utf8_swedish_ci,utf8_turkish_ci,utf8_czech_ci,utf8_danish_ci,utf8_lithuanian_ci,utf8_slovak_ci,utf8_spanish2_ci,utf8_roman_ci,utf8_persian_ci,utf8_esperanto_ci,utf8_hungarian_ci,utf8_sinhala_ci,ucs2_general_ci,ucs2_bin,ucs2_unicode_ci,ucs2_icelandic_ci,ucs2_latvian_ci,ucs2_romanian_ci,ucs2_slovenian_ci,ucs2_polish_ci,ucs2_estonian_ci,ucs2_spanish_ci,ucs2_swedish_ci,ucs2_turkish_ci,ucs2_czech_ci,ucs2_danish_ci,ucs2_lithuanian_ci,ucs2_slovak_ci,ucs2_spanish2_ci,ucs2_roman_ci,ucs2_persian_ci,ucs2_esperanto_ci,ucs2_hungarian_ci,ucs2_sinhala_ci,cp866_general_ci,cp866_bin,keybcs2_general_ci,keybcs2_bin,macce_general_ci,macce_bin,macroman_general_ci,macroman_bin,cp852_general_ci,cp852_bin,latin7_estonian_cs,latin7_general_ci,latin7_general_cs,latin7_bin,utf8mb4_general_ci,utf8mb4_bin,utf8mb4_unicode_ci,utf8mb4_icelandic_ci,utf8mb4_latvian_ci,utf8mb4_romanian_ci,utf8mb4_slovenian_ci,utf8mb4_polish_ci,utf8mb4_estonian_ci,utf8mb4_spanish_ci,utf8mb4_swedish_ci,utf8mb4_turkish_ci,utf8mb4_czech_ci,utf8mb4_danish_ci,utf8mb4_lithuanian_ci,utf8mb4_slovak_ci,utf8mb4_spanish2_ci,utf8mb4_roman_ci,utf8mb4_persian_ci,utf8mb4_esperanto_ci,utf8mb4_hungarian_ci,utf8mb4_sinhala_ci,cp1251_bulgarian_ci,cp1251_ukrainian_ci,cp1251_bin,cp1251_general_ci,cp1251_general_cs,utf16_general_ci,utf16_bin,utf16_unicode_ci,utf16_icelandic_ci,utf16_latvian_ci,utf16_romanian_ci,utf16_slovenian_ci,utf16_polish_ci,utf16_estonian_ci,utf16_spanish_ci,utf16_swedish_ci,utf16_turkish_ci,utf16_czech_ci,utf16_danish_ci,utf16_lithuanian_ci,utf16_slovak_ci,utf16_spanish2_ci,utf16_roman_ci,utf16_persian_ci,utf16_esperanto_ci,utf16_hungarian_ci,utf16_sinhala_ci,cp1256_general_ci,cp1256_bin,cp1257_lithuanian_ci,cp1257_bin,cp1257_general_ci,utf32_general_ci,utf32_bin,utf32_unicode_ci,utf32_icelandic_ci,utf32_latvian_ci,utf32_romanian_ci,utf32_slovenian_ci,utf32_polish_ci,utf32_estonian_ci,utf32_spanish_ci,utf32_swedish_ci,utf32_turkish_ci,utf32_czech_ci,utf32_danish_ci,utf32_lithuanian_ci,utf32_slovak_ci,utf32_spanish2_ci,utf32_roman_ci,utf32_persian_ci,utf32_esperanto_ci,utf32_hungarian_ci,utf32_sinhala_ci,binary,geostd8_general_ci,geostd8_bin,cp932_japanese_ci,cp932_bin,eucjpms_japanese_ci,eucjpms_bin", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "completion_type", NULL, "The transaction completion type (0 - default, 1 - chain, 2 - release)", "engine-default", "integer", "0-2", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "concurrent_insert", NULL, "Allows INSERT and SELECT statements to run concurrently for MyISAM tables that have no free blocks in the middle of the data file.", "engine-default", "integer", "0-2", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "connect_timeout", NULL, "The number of seconds that the MySQLd  server waits for a connect packet before responding with Bad handshake.", "engine-default", "integer", "2-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "datadir", "/rdsdbdata/db/", "MySQL data directory", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "default_storage_engine", "InnoDB", "The default storage engine (table type).", "system", "string", "InnoDB,MRG_MYISAM,BLACKHOLE,CSV,MEMORY,FEDERATED,ARCHIVE,MyISAM", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "default_time_zone", NULL, "Server current time zone", "engine-default", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "default_week_format", NULL, "The default mode value to use for the WEEK() function.", "engine-default", "integer", "0-7", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "delay_key_write", NULL, "Determines when keys are flushed for MyISAM tables", "engine-default", "string", "OFF,ON,ALL", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "delayed_insert_limit", NULL, "After inserting delayed_insert_limit delayed rows, the INSERT DELAYED handler thread checks whether there are any SELECT statements pending. If so, it allows them to execute before continuing to insert delayed rows.", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "delayed_insert_timeout", NULL, "How many seconds an INSERT DELAYED handler thread should wait for INSERT statements before terminating.", "engine-default", "integer", "1-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "delayed_queue_size", NULL, "If the queue becomes full, any client that issues an INSERT DELAYED statement waits until there is room in the queue again.", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "div_precision_increment", NULL, "Number of digits by which to increase the scale of the result of division operations.", "engine-default", "integer", "0-30", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "event_scheduler", NULL, "Indicates the status of the Event Scheduler", "engine-default", "string", "ON,OFF,DISABLED", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "flush", NULL, "If ON, the server flushes all changes to disk after each SQL statement.", "engine-default", "boolean", "0,1", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "flush_time", NULL, "Frees up resources and synchronize unflushed data to disk. Recommended only on systems with minimal resources.", "engine-default", "integer", "0-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "ft_boolean_syntax", NULL, "The list of operators supported by boolean full-text searches", "engine-default", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "ft_max_word_len", NULL, "Maximum length of the word to be included in a FULLTEXT index.", "engine-default", "integer", "10-84", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "ft_min_word_len", NULL, "Minimum length of the word to be included in a FULLTEXT index.", "engine-default", "integer", "1-84", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "ft_query_expansion_limit", NULL, "Number of top matches to use for full-text searches performed using WITH QUERY EXPANSION.", "engine-default", "integer", "0-1000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "general_log", NULL, "Whether the general query log is enabled", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "group_concat_max_len", NULL, "Maximum allowed result length in bytes for the GROUP_CONCAT().", "engine-default", "integer", "4-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "init_connect", NULL, "String to be executed by the server for each client that connects.", "engine-default", "string", NULL, 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_adaptive_flushing", NULL, "Enables InnoDB Adaptive Flushing (default=on for RDS)", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_adaptive_hash_index", NULL, "Whether innodb adaptive hash indexes are enabled or disabled", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_additional_mem_pool_size", "2097152", "The size in bytes of a memory pool innodb uses to store data dictionary information and other internal data structures", "system", "integer", "524288-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_autoextend_increment", NULL, "The increment size (in MB) for extending the size of an auto-extending tablespace file when it becomes full", "engine-default", "integer", "1-1000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_autoinc_lock_mode", NULL, "The locking mode to use for generating auto-increment values", "engine-default", "integer", "0-2", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_buffer_pool_instances", NULL, "The number of regions that the InnoDB buffer pool is divided into", "engine-default", "integer", "1-64", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_buffer_pool_size", "{DBInstanceClassMemory*3/4}", "The size in bytes of the memory buffer innodb uses to cache data and indexes of its tables", "system", "integer", "1048576-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_change_buffering", NULL, "Controls InnoDB change buffering", "engine-default", "string", "none,inserts", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_commit_concurrency", NULL, "The number of threads that can commit at the same time.", "engine-default", "integer", "0-1000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_concurrency_tickets", NULL, "Number of times a thread can enter and leave Innodb before it is subject to innodb-thread-concurrency", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_data_home_dir", "/rdsdbdata/db/innodb", "Directory where innodb files are stored", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_file_format", NULL, "Sets InnoDB Plug-in default file format.", "engine-default", "string", "Antelope,Barracuda", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_file_per_table", "1", "Use tablespaces or files for Innodb.", "system", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_flush_log_at_trx_commit", NULL, "Determines Innodb transaction durability", "engine-default", "integer", "0-2", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_flush_method", "O_DIRECT", "Determines Innodb flush method", "system", "string", "O_DSYNC,O_DIRECT", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_force_load_corrupted", NULL, "Lets InnoDB load tables at startup that are marked as corrupted", "engine-default", "boolean", "0,1", 0, "5.5.20");
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_io_capacity", NULL, "The maximum number of I/O operations per second that InnoDB will perform.", "engine-default", "integer", "100-1000000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_large_prefix", NULL, "Enables or disables Innodb Large Prefix for Keys", "engine-default", "boolean", "0,1", 1, "5.5.20");
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_lock_wait_timeout", NULL, "Timeout in seconds an innodb transaction may wait for a row lock before giving up", "engine-default", "integer", "1-1073741824", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_locks_unsafe_for_binlog", NULL, "Affects how innodb uses gap locking for searches and index scans", "engine-default", "boolean", "0,1", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_log_buffer_size", "8388608", "The size in bytes of the buffer that innodb uses to write to the log files on disk", "system", "integer", "262144-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_log_file_size", "134217728", "The size in bytes of each log file in a log group", "system", "integer", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_log_group_home_dir", "/rdsdbdata/log/innodb", "The directory path to the innodb log files", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_max_dirty_pages_pct", NULL, "Maximum percentage of dirty pages in the buffer pool", "engine-default", "integer", "0-99", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_max_purge_lag", NULL, "Controls how to delay INSERT, UPDATE, and DELETE operations when purge operations are lagging", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_old_blocks_pct", NULL, "Specifies the approximate percentage of the InnoDB buffer pool used for the old block sublist.", "engine-default", "integer", "5-95", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_old_blocks_time", NULL, "Specifies how long in milliseconds (ms) a block inserted into the old sublist must stay there after its first access before it can be moved to the new sublist.", "engine-default", "integer", "0-100000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_open_files", NULL, "Relevant only if you use multiple tablespaces in innodb. It specifies the maximum number of .ibd files that innodb can keep open at one time", "engine-default", "integer", "20-300", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_purge_batch_size", NULL, "The granularity of changes, expressed in units of redo log records, that trigger a purge operation, flushing the changed buffer pool blocks to disk", "engine-default", "integer", "1-5000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_purge_threads", NULL, "The number of background threads devoted to the InnoDB purge operation", "engine-default", "integer", "0-1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_random_read_ahead", NULL, "Enables or disables Innodb Random Read Ahead", "engine-default", "boolean", "0,1", 1, "5.5.20");
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_read_ahead_threshold", NULL, "Controls the sensitivity of linear read-ahead that InnoDB uses to prefetch pages into the buffer cache.", "engine-default", "integer", "0-64", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_read_io_threads", NULL, "The number of I/O threads for read operations in InnoDB.", "engine-default", "integer", "1-16", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_replication_delay", NULL, "The replication thread delay (in ms) on a slave server if innodb_thread_concurrency is reached.", "engine-default", "integer", "0-100000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_rollback_on_timeout", NULL, "Controls whether timeouts rollback the last statement or the entire transaction", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_spin_wait_delay", NULL, "The maximum delay between polls for a spin lock.", "engine-default", "integer", "0-100", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_stats_on_metadata", NULL, "Controls whether table and index stats are updated when getting status information via SHOW STATUS or the INFORMATION_SCHEMA", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_stats_sample_pages", NULL, "The number of index pages to sample for index distribution statistics such as are calculated by ANALYZE TABLE.", "engine-default", "integer", "0-100000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_strict_mode", NULL, "Whether InnoDB returns errors rather than warnings for exceptional conditions.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_support_xa", NULL, "Enables two phase commit in XA transactions", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_sync_spin_loops", NULL, "The number of times a thread waits for an innodb mutex to be freed before the thread is suspended", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_table_locks", NULL, "If autocommit = 0, innodb honors LOCK TABLES", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_thread_concurrency", NULL, "The number of threads that can enter innodb concurrently", "engine-default", "integer", "0-1000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "innodb_thread_sleep_delay", NULL, "How long innodb threads sleep before joining the innodb queue, in microseconds.", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_use_native_aio", NULL, "Controles whether or not MySQL uses Linux native asynchronous IO.", "engine-default", "integer", "0-1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_use_sys_malloc", NULL, "Whether InnoDB uses the operating system memory allocator (ON) or its own (OFF).", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "innodb_write_io_threads", NULL, "The number of I/O threads for write operations in InnoDB.", "engine-default", "integer", "1-16", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "interactive_timeout", NULL, "Number of seconds the server waits for activity on an interactive connection before closing it.", "engine-default", "integer", "1-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "join_buffer_size", NULL, "Increase the value of join_buffer_size to get a faster full join when adding indexes is not possible.", "engine-default", "integer", "8200-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "keep_files_on_create", NULL, "Suppress behavior to overwrite MyISAM file created in DATA DIRECTORY or INDEX DIRECTORY.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "key_buffer_size", "16777216", "Increase the buffer size to get better index handling used for index blocks (for all reads and multiple writes).", "system", "integer", "8-9223372036854771712", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "key_cache_age_threshold", NULL, "Controls the demotion of buffers from the hot sub-chain of a key cache to the warm sub-chain. Lower values cause demotion to happen more quickly.", "engine-default", "integer", "100-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "key_cache_block_size", NULL, "Size in bytes of blocks in the key cache.", "engine-default", "integer", "512-16384", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "key_cache_division_limit", NULL, "The division point between the hot and warm sub-chains of the key cache buffer chain. The value is the percentage of the buffer chain to use for the warm sub-chain.", "engine-default", "integer", "1-100", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "lc_time_names", NULL, "This variable specifies the locale that controls the language used to display day and month names and abbreviations.", "engine-default", "string", "ar_AE,ar_BH,ar_DZ,ar_EG,ar_IN,ar_IQ,ar_JO,ar_KW,ar_LB,ar_LY,ar_MA,ar_OM,ar_QA,ar_SA,ar_SD,ar_SY,ar_TN,ar_YE,be_BY,bg_BG,ca_ES,cs_CZ,da_DK,de_AT,de_BE,de_CH,de_DE,de_LU,EE,en_AU,en_CA,en_GB,en_IN,en_NZ,en_PH,en_US,en_ZA,en_ZW,es_AR,es_BO,es_CL,es_CO,es_CR,es_DO,es_EC,es_ES,es_GT,es_HN,es_MX,es_NI,es_PA,es_PE,es_PR,es_PY,es_SV,es_US,es_UY,es_VE,eu_ES,fi_FI,fo_FO,fr_BE,fr_CA,fr_CH,fr_FR,fr_LU,gl_ES,gu_IN,he_IL,hi_IN,hr_HR,hu_HU,id_ID,is_IS,it_CH,it_IT,ja_JP,ko_KR,lt_LT,lv_LV,mk_MK,mn_MN,ms_MY,nb_NO,nl_BE,nl_NL,no_NO,pl_PL,pt_BR,pt_PT,ro_RO,ru_RU,ru_UA,sk_SK,sl_SI,sq_AL,sr_YU,sv_FI,sv_SE,ta_IN,te_IN,th_TH,tr_TR,uk_UA,ur_PK,vi_VN,zh_CN,zh_HK,zh_TW", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "local_infile", "1", "Controls whetther LOCAL is supported for LOAD DATA INFILE", "system", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "lock_wait_timeout", NULL, "Specifies the timeout in seconds for attempts to acquire metadata locks", "engine-default", "integer", "1-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "log-bin", "/rdsdbdata/log/binlog/mysql-bin-changelog", "Controls binary logging.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "log_bin_trust_function_creators", NULL, "Enforces restrictions on stored functions / triggers - logging for replication.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "log_error", "/rdsdbdata/log/error/mysql-error.log", "Location  of error log.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "log_output", "TABLE", "Controls where to store query logs", "system", "string", "TABLE,FILE,NONE", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "log_queries_not_using_indexes", NULL, "Logs queries that are expected to retrieve all rows to slow query log", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "log_warnings", NULL, "Controls whether to produce additional warning messages.", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "long_query_time", NULL, "Defines what MySQL considers long queries", "engine-default", "integer", "0-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "low_priority_updates", NULL, "INSERT, UPDATE, DELETE, and LOCK TABLE WRITE wait until no pending SELECT. Affects only storage engines that use only table-level locking (MyISAM, MEMORY, MERGE).", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "lower_case_table_names", NULL, "Affects how the server handles identifier case sensitivity", "engine-default", "integer", "0-1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_allowed_packet", NULL, "This value by default is small, to catch large (possibly incorrect) packets. Must be increased if using large BLOB columns or long strings. As big as largest BLOB. ", "engine-default", "integer", "1024-1073741824", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_binlog_cache_size", NULL, "Maximum binlog cache size a transaction may use", "engine-default", "integer", "4096-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_binlog_size", "134217728", "Server rotates the binlog once it reaches this size", "system", "integer", "4096-1073741824", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_connect_errors", NULL, "A host is blocked from further connections if there are more than this number of interrupted connections", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_connections", "{DBInstanceClassMemory/12582880}", "The number of simultaneous client connections allowed.", "system", "integer", "1-100000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_delayed_threads", NULL, "Do not start more than this number of threads to handle INSERT DELAYED statements.", "engine-default", "integer", "0-16384", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_error_count", NULL, "The maximum number of error, warning, and note messages to be stored for display.", "engine-default", "integer", "0-65535", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_heap_table_size", NULL, "Maximum size to which MEMORY tables are allowed to grow.", "engine-default", "integer", "16384-9223372036854774784", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_insert_delayed_threads", NULL, "Synonym for max_delayed_threads", "engine-default", "integer", "0-16384", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_join_size", NULL, "Catch SELECT statements where keys are not used properly and would probably take a long time. ", "engine-default", "integer", "100-4294967295", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_length_for_sort_data", NULL, "ORDER BY Optimization. The cutoff on the size of index values that determines which filesort algorithm to use.", "engine-default", "integer", "4-8388608", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_prepared_stmt_count", NULL, "Used if the potential for denial-of-service attacks based on running the server out of memory by preparing huge numbers of statements.", "engine-default", "integer", "0-1048576", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_seeks_for_key", NULL, "A low value can force MySQL to prefer indexes instead of table scans.", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_sort_length", NULL, "The number of bytes to use when sorting BLOB or TEXT values.", "engine-default", "integer", "4-8388608", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_sp_recursion_depth", NULL, "Limits the number of times a stored procedure can be called recursively minimizing the demand on thread stack space.", "engine-default", "integer", "0-255", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_tmp_tables", NULL, "The maximum number of temporary tables a client can keep open at the same time.", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_user_connections", NULL, "Maximum number of simultaneous connections allowed to any given MySQL account. ", "engine-default", "integer", "0-4294967295", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "max_write_lock_count", NULL, "After this many write locks, allow some pending read lock requests to be processed in between.", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "metadata_locks_cache_size", NULL, "The size of the metadata locks cache", "engine-default", "integer", "1..1048576", 1, "5.5.20");
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "min_examined_row_limit", NULL, "Can be used to cause queries which examine fewer than the stated number of rows not to be logged.", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "myisam_data_pointer_size", NULL, "The default pointer size in bytes, to be used by CREATE TABLE for MyISAM tables when no MAX_ROWS option is specified.", "engine-default", "integer", "2-7", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "myisam_max_sort_file_size", NULL, "The maximum size of the temporary file that MySQL is allowed to use while re-creating a MyISAM index", "engine-default", "integer", "0-9223372036853727232", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "myisam_mmap_size", NULL, "Maximum amount of memory to use for memory mapping compressed MyISAM files", "engine-default", "integer", "7-922337203685477807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "myisam_sort_buffer_size", NULL, "Size of the buffer that is allocated when sorting MyISAM indexes during a REPAIR TABLE or when creating indexes with CREATE INDEX or ALTER TABLE.", "engine-default", "integer", "4-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "myisam_stats_method", NULL, "How the server treats NULL values when collecting statistics about the distribution of index values for MyISAM tables", "engine-default", "string", "nulls_equal,nulls_unequal,nulls_ignored", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "myisam_use_mmap", NULL, "Memory mapping for reading and writing MyISAM tables.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "net_buffer_length", NULL, "This variable should not normally be changed. For use when very little memory is available. Set it to the expected length of statements sent by clients.", "engine-default", "integer", "1024-1048576", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "net_read_timeout", NULL, "The number of seconds to wait for more data from a TCP/IP connection before aborting the read.", "engine-default", "integer", "1-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "net_retry_count", NULL, "If a read on a communication port is interrupted, retry this many times before giving up. This value should be set quite high on freebsd because internal interrupts are sent to all threads. ", "engine-default", "integer", "1-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "net_write_timeout", NULL, "The number of seconds to wait on TCP/IP connections for a block to be written before aborting the write. ", "engine-default", "integer", "1-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "old-style-user-limits", NULL, "Enable old-style user limits.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "old_passwords", NULL, "Force the server to generate short (pre-4.1) password hashes for new passwords. This is useful for compatibility when the server must support older client programs.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "optimizer_prune_level", NULL, "Controls the heuristics applied during query optimization to prune less-promising partial plans from the optimizer search space.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "optimizer_search_depth", NULL, "The maximum depth of search performed by the query optimizer.", "engine-default", "integer", "0-63", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "optimizer_switch", NULL, "Controls optimizer behavior. ", "engine-default", "string", "engine_condition_pushdown=off,engine_condition_pushdown=on,index_merge=on,index_merge=off,index_merge_intersection=on,index_merge_intersection=off,index_merge_union=on,index_merge_union=off,index_merge_sort_union=on,index_merge_sort_union=off", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "performance_schema", NULL, "Enables or disables the Performance Schema", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "pid_file", "/rdsdbdata/log/mysql-{EndPointPort}.pid", "The path name of the process ID file. This file is used by other programs such as MySQLd_safe to determine the server\'s process ID.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "plugin_dir", NULL, "Directory searched by systems dynamic linker for UDF object files. Otherwise, user-defined function object files must be located the default directory.", "engine-default", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "port", "{EndPointPort}", "The number of the port on which the server listens for TCP/IP connections.", "system", "integer", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "preload_buffer_size", NULL, "The size of the buffer that is allocated when preloading indexes.", "engine-default", "integer", "1024-1073741824", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "profiling_history_size", NULL, "The number of statements for which to maintain profiling if profiling is enabled.", "engine-default", "integer", "0-100", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_alloc_block_size", NULL, "The allocation size of memory blocks that are allocated for objects created during statement parsing and execution. May help resolve fragmentation problems.", "engine-default", "integer", "1024-67108864", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_cache_limit", NULL, "Don\'t cache results that are larger than this number of bytes.", "engine-default", "integer", "0-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_cache_min_res_unit", NULL, "The minimum size (in bytes) for blocks allocated by the query cache.", "engine-default", "integer", "512-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_cache_size", NULL, "The amount of memory allocated for caching query results.", "engine-default", "integer", "0-9223372036854774784", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_cache_type", NULL, "For query results either don\'t cache (=OFF), cache except for NO_CACHE (=ON), or only CACHE (=DEMAND)", "engine-default", "integer", "0-2", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_cache_wlock_invalidate", NULL, "Setting this variable to 1 causes acquisition of a WRITE lock for a table to invalidate any queries in the query cache that refer to the table", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "query_prealloc_size", NULL, "Increased size might help improve perf for complex queries (i.e. Reduces server memory allocation)", "engine-default", "integer", "8192-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "range_alloc_block_size", NULL, "The size of blocks that are allocated when doing range optimization.", "engine-default", "integer", "4096-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "read_buffer_size", "262144", "Each thread that does a sequential scan allocates this buffer. Increased value may help perf if performing many sequential scans.", "system", "integer", "8200-2147479552", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "read_only", "{TrueIfReplica}", "When it is enabled, the server permits no updates except from updates performed by slave  threads.", "engine-default", "boolean", "1,0", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "read_rnd_buffer_size", "524288", "Avoids disk reads when reading rows in sorted order following a key-sort operation. Large values can improve ORDER BY perf.", "system", "integer", "8200-2147479552", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "relay-log", "/rdsdbdata/log/relaylog/relaylog", "The basename for the relay log.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "safe-user-create", NULL, "If this option is enabled, a user cannot create new MySQL users by using the GRANT  statement unless the user has the INSERT privilege for the mysql.user table or any column in the table.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "secure_auth", NULL, "Blocks connections from all accounts that have passwords stored in the old (pre-4.1) format.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "secure_file_priv", "/tmp", "Limits the effect of LOAD_FILE(), LOAD_DATA, and SELECT ??? INTO OUTFILE to specified directory.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "server_id", "{ServerId}", "Integer value used to identify the instance in a replication group", "system", "integer", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "skip-character-set-client-handshake", NULL, "Ignore character set information sent by the client.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "skip_external_locking", NULL, "Uses OS locking instead of internal", "engine-default", "boolean", "0,1", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "skip_name_resolve", NULL, "Host names are not resolved. All Host column values in the grant tables must be IP numbers or localhost.", "engine-default", "boolean", "0,1", 1, "5.5.12");
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "skip_show_database", NULL, "SHOW DATABASES statement is allowed only to users who have the SHOW DATABASES privilege", "engine-default", "boolean", "0,1", 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "slow_launch_time", NULL, "Increments Slow_launch_threads if creating thread takes longer than this many seconds.", "engine-default", "integer", "0-31536000", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "slow_query_log", NULL, "Enable or disable the slow query log", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "socket", "/tmp/mysql.sock", "(UNIX) socket file and (WINDOWS) named pipe used for local connections.", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "sort_buffer_size", NULL, "Larger value improves perf for ORDER BY or GROUP BY operations.", "engine-default", "integer", "32776-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "sql_mode", NULL, "Current SQL Server Mode.", "engine-default", "string", "ALLOW_INVALID_DATES,ANSI_QUOTES,ERROR_FOR_DIVISION_BY_ZERO,HIGH_NOT_PRECEDENCE,IGNORE_SPACE,NO_AUTO_CREATE_USER,NO_AUTO_VALUE_ON_ZERO,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_FIELD_OPTIONS,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_UNSIGNED_SUBTRACTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ONLY_FULL_GROUP_BY,PAD_CHAR_TO_FULL_LENGTH,PIPES_AS_CONCAT,REAL_AS_FLOAT,STRICT_ALL_TABLES,STRICT_TRANS_TABLES,TRADITIONAL", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "sql_select_limit", NULL, "The maximum number of rows to return from SELECT statements.", "engine-default", "integer", "0-18446744073709551615", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "sync_binlog", NULL, "Sync binlog (MySQL flush to disk or rely on OS)", "engine-default", "integer", "0-4294967295", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "sync_frm", NULL, "For non-temporary tables controls if .frm file is sync'ed to disk.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "sysdate-is-now", NULL, "Causes SYSYDATE() to be an alias for NOW(). Replication related", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "table_definition_cache", NULL, "The number of table definitions that can be stored in the definition cache", "engine-default", "integer", "256-524288", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "table_open_cache", NULL, "The number of open tables for all threads. Increasing this value increases the number of file descriptors.", "engine-default", "integer", "1-524288", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "temp-pool", NULL, "This option causes most temporary files created by the server to use a small set of names, rather than a unique name for each new file. This works around a problem in the Linux kernel dealing with creating many new files with different names.", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "thread_cache_size", NULL, "Number of threads to be cached. Doesn\'t improve perf for good thread implementations.", "engine-default", "integer", "0-16384", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "thread_stack", "196608", "If the thread stack size is too small, it limits the complexity of the SQL statements that the server can handle, the recursion depth of stored procedures, and other memory-consuming actions.", "engine-default", "integer", "131072-10737418240", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "timed_mutexes", NULL, "Controls whether innodb mutexes are timed out. ", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "tmp_table_size", NULL, "If an in-memory temporary table exceeds the limit, MySQL automatically converts it to an on-disk MyISAM table. Increased value can improve perf for many advanced GROUP BY queries.", "engine-default", "integer", "1024-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "static", "tmpdir", "/rdsdbdata/tmp", "The directory used for temporary files and temporary tables", "system", "string", NULL, 0, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "transaction_alloc_block_size", NULL, "The amount in bytes by which to increase a per-transaction memory pool which needs memory.", "engine-default", "integer", "1024-4294967295", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "transaction_prealloc_size", NULL, "There is a per-transaction memory pool from which various transaction-related allocations take memory. For every allocation that cannot be satisfied from the pool because it has insufficient memory available, the pool is incremented.", "engine-default", "integer", "1024-9223372036854775807", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "tx_isolation", NULL, "Sets the default transaction isolation level.", "engine-default", "string", "READ-UNCOMMITTED,READ-COMMITTED,REPEATABLE-READ,SERIALIZABLE", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "updatable_views_with_limit", NULL, "This variable controls whether updates to a view can be made when the view does not contain all columns of the primary key defined in the underlying table, if the update statement contains a LIMIT clause (Often generated by GUI tools).", "engine-default", "boolean", "0,1", 1, NULL);
INSERT INTO rds_parameter (rds_parameter_group_id, apply_type, parameter_name, parameter_value, description, source, data_type, allowed_values, is_modifiable, minimum_engine_version) VALUES ((select rds_parameter_group_id from rds_dbparameter_group where dbparameterGroupName = "default.mysql5.5"), "dynamic", "wait_timeout", NULL, "The number of seconds the server waits for activity on a non-interactive TCP/IP or UNIX File connection before closing it.", "engine-default", "integer", "1-31536000", 1, NULL);

CREATE TABLE IF NOT EXISTS `zones` (
  `id` varchar(255) NOT NULL,
  `accountId` bigint(20) NOT NULL,
  `callerReference` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `tableName` varchar(255) DEFAULT NULL,
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

CREATE DATABASE IF NOT EXISTS bind;
USE `bind`;
DROP TABLE IF EXISTS `zones`;
DROP TABLE IF EXISTS `changes`;

GRANT ALL ON `bind`.* TO 'topstack'@'localhost' identified by 'topstack_password';

# On dev boxes, allow from all hosts.
GRANT ALL ON `bind`.* TO 'topstack'@'%' identified by 'topstack_password';

USE `topstack`;
