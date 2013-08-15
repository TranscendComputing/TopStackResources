#!/bin/bash

# installMySQL55.ftl
# input config, ac, instance, user, password, database, dbinstance, masterDBInstance, masterInstance, snapshot
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh

/etc/init.d/mysqld restart

cat << EOC > mysql.sql
CHANGE MASTER TO
	MASTER_HOST='${masterInstance.ipAddress}',
    MASTER_USER='${masterDBInstance.replicateUser}',
    MASTER_PASSWORD='${masterDBInstance.replicatePassword}',
    MASTER_LOG_FILE='${snapshot.logFile}',
    MASTER_LOG_POS=${snapshot.logPosition};
EOC

mysql -u ${user} -p${password} ${database} < mysql.sql 

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.ipAddress />
<#else>
  <#assign ip=instance.dns />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
