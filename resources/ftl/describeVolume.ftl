#!/bin/bash

# input config, account, volumeId
# return volumeId, volumeStatus

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

resp=`euca-describe-volumes ${volumeId}`
echo "response $resp"
volumeId=`echo $resp | cut -d ' ' -f 2`
volumeStatus=`echo $resp | cut -d ' ' -f 5`
echo "volumeId returned " $volumeId $volumeStatus

# returning 
echo "returnVolumeId=$volumeId"  
echo "returnVolumeStatus=$volumeStatus"  
