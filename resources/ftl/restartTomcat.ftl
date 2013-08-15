#!/bin/bash

# restartTomcat.ftl
# Restart Tomcat
# input config, ac, instance, tomcatDir
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#restart tomcat
cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
export JAVA_HOME=/usr/java/latest
cd ${tomcatDir}/bin
./shutdown.sh
./startup.sh
cd /root

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.internalIp />
<#else>
  <#assign ip=instance.publicIp />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
