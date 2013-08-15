#!/bin/bash

# input config, account, volumeId, instanceId, device
# return null

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

resp=`euca-attach-volume -i ${instanceId} -d ${device} ${volumeId}`
echo "response $resp"
sleep 5
