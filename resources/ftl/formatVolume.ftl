#!/bin/bash

# Format a device and mount it
# input config, account, instance, device, fstype, mountPoint
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

<#if config.useIpforInstances == "yes" >
  <#assign dns=instance.ipAddress />
<#else>
  <#assign dns=instance.dns />
</#if>
	
cat << EOSH >  ${config.tmpDir}/${instance.instanceId}.sh
mkfs -t ${fstype} ${device} <<EOC
y
EOC

mkdir -p ${mountPoint}

mount -t ${fstype} ${device} ${mountPoint}

EOSH

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${dns}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${dns} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${dns} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
