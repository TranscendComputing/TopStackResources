#!/bin/bash

# copyS3Resources.ftl
# input config, ac, instance, S3Bucket, S3Key, fileName, toDir
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
yum -y install unzip perl-Digest-HMAC

cat <<EOC >> /etc/hosts

${config.S3_SERVER_IP}	${config.S3_SERVER}

EOC

#create S3 ID file
cat <<EOS3 > /root/.s3curl
%awsSecretAccessKeys = (
    # s3 account
    s3 => {
        id => '${account.accessKey}',
        key => '${account.secretKey}'
    },
);
EOS3

chmod 600 /root/.s3curl

wget -q http://${config.YUMHOST}/amazon/s3-curl-momentumsoftware/s3curl.pl
chmod +x s3curl.pl

./s3curl.pl --id=s3 ${config.S3_URL}/${S3Bucket}/${S3Key} > /root/${fileName}
cp /root/${fileName} ${toDir}/${fileName}

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.internalIp />
<#else>
  <#assign ip=instance.publicIp />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
