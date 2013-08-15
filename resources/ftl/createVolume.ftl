#!/bin/bash

# input config, account, size, avzone
# return volumeId

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

echo "creating volume ${avzone} ${size}"

#run instance
resp=`euca-create-volume -z ${avzone} -s ${size}`
echo "creation response $resp"
volumeId=`echo $resp | grep "VOLUME" | cut -d ' ' -f 2`
echo "volumeId returned " $volumeId

# returning 
echo "returnVolumeId=$volumeId"  
