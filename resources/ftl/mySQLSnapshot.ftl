#!/bin/bash

# mySQLSnapshotL.ftl
# input config, ac, instance, user, password, database, snapshotId, dbinstance
# return returnBinFile, returnCoord

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#dump MySql
cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
mysql -u ${user} -p${password} ${database} << EOC > mysql.out 
SHOW MASTER STATUS;
EOC

mysqldump -u ${user} -p${password} ${database} > mysqldump.sql

/root/s3-curl/s3curl.pl --id s3id --put mysqldump.sql ${config.S3_URL}/${dbinstance.dbinstanceId}_snapshots/${snapshotId}

echo
echo

echo "returnBinFile="\`grep mysql-bin  mysql.out | cut -f 1\`
echo "returnCoord="\`grep mysql-bin  mysql.out | cut -f 2\`
EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.ipAddress />
<#else>
  <#assign ip=instance.dns />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
