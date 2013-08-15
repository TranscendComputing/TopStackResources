#!/bin/bash

# installMySQL55.ftl
# input config, ac, instance, serverId, dbinstance, avzone
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#install MySql55

cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
yum -y install unzip perl-Digest-HMAC

wget -q ${config.YUMHOST}/amazon/s3-curl-momentumsoftware/s3-curl.zip
unzip s3-curl.zip
cd s3-curl
chmod +x s3curl.pl

cat <<EOC >> /etc/hosts
${configuration("S3_SERVER_IP", avzone)}	${configuration("S3_SERVER", avzone)}
EOC

cat <<EOC > /root/.s3curl
%awsSecretAccessKeys = (
    # personal account
    s3id => {
        id => '${account.accessKey}',
        key => '${account.secretKey}',
    },
);
EOC

chmod 600 /root/.s3curl

/root/s3-curl/s3curl.pl --id s3id --createBucket ${configuration("S3_URL", avzone)}/${dbinstance.dbinstanceId}_snapshots

rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm
yum -y install libmysqlclient15 --enablerepo=webtatic
yum -y install mysql55 mysql55-server --enablerepo=webtatic

/etc/init.d/mysqld restart
/etc/init.d/mysqld stop

cat <<EOC > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-bin=mysql-bin
server-id=${serverId}

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOC

/etc/init.d/mysqld restart

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.ipAddress />
<#else>
  <#assign ip=instance.dns />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
