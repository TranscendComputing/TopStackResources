#!/bin/bash

# createLoadBalancer.ftl
# create a load balancer instance in Eucalyptus
# input config, account, launch, avzones
# return instanceId

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzones)}
export EC2_URL=${configuration("EC2_URL", avzones)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzones)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzones)}

echo "using ${launch.imageId} ${account.accessKey}"

#run instance
resp=`euca-run-instances -n 1 -k ${launch.key} -t ${launch.instType} -z ${avzones} --kernel ${launch.kernel} --ramdisk ${launch.ramdisk} ${launch.imageId}`
echo "creation response $resp"
instanceId=`echo $resp | grep "INSTANCE" | cut -d ' ' -f 6`
echo "instanceId returned " $instanceId

sleep 10

# returning 
echo "returnInstanceId=$instanceId"  
