#!/bin/bash

# deleteInstance.ftl
# terminate instances
# input config, account, instances, avzone
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

<#list instances as instanceId>

resp=`euca-describe-instances ${instanceId} | grep "${instanceId}"`
echo "response $resp"
insId=`echo $resp | cut -d ' ' -f 2`
ip=`echo $resp | cut -d ' ' -f 5`
dns=`echo $resp | cut -d ' ' -f 4`
stat=`echo $resp | cut -d ' ' -f 6`
echo "returned " $insId $dns $ip $stat

euca-terminate-instances ${instanceId} 

euca-release-address $dns

</#list>

