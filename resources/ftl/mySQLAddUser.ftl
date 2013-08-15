#!/bin/bash

# mySQLAddUser.ftl
# input config, ac, instance, rootUser, rootPassword, newUser, newPassword, ACL
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#install MySql55
cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
<#if rootPassword== "" >
mysql -u ${rootUser} << EOC
<#else>
mysql -u ${rootUser} -p${password} << EOC
</#if>
CREATE USER '${newUser}'@'%' IDENTIFIED BY '${newPassword}';
GRANT ALL PRIVILEGES ON *.* TO '${newUser}'@'%' WITH GRANT OPTION;
CREATE USER '${newUser}'@'localhost' IDENTIFIED BY '${newPassword}';
GRANT ALL PRIVILEGES ON *.* TO '${newUser}'@'localhost' WITH GRANT OPTION;
EOC
EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.ipAddress />
<#else>
  <#assign ip=instance.dns />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
