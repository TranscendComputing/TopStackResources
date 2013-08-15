#!/bin/bash

# installHazelcast.ftl
# Install Hazelcast
# input config, account, instance, dir, URL, content
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#install hazelcast

cat <<EOSH > ${config.tmpDir}/${instance.instanceId}.sh
#export JAVA_HOME="/usr/java/latest"
#wget -q ${config.YUMHOST}/java/jdk-6u24-linux-amd64.rpm
#rpm -Uvh ./jdk-6u24-linux-amd64.rpm 
#echo "export JAVA_HOME=/usr/java/latest" >>/root/.bashrc
yum -y install java
java -version

yum -y install unzip

wget -q ${URL}
mkdir -p ${dir}
cd ${dir}
unzip /root/hazelcast-1.9.3.1.zip
ln -s hazelcast-1.9.3.1 hazelcast

cd ${dir}
cd hazelcast/lib
wget -q ${config.YUMHOST}/tough/hazelcast/hazelcast-executor.jar

cd ${dir}
cd hazelcast/bin

cat << EOC  > hazelcast.xml
${content}
EOC

#run hazelcast
java -Djava.net.preferIPv4Stack=true -cp ../lib/hazelcast-1.9.3.1.jar:../lib/hazelcast-executor.jar com.tough.hazelcast.HazelcastExecutor &

cd /root

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.internalIp />
<#else>
  <#assign ip=instance.publicIp />
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -f -n -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
