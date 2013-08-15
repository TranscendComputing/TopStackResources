#!/bin/bash

# installLB_haproxy.ftl
# Configure a load balancer on startup using haproxy
# input config, account, loadBalancer, instance
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

<#if config.useIpforInstances == "yes" >
  <#assign lbdns=instance.internalIp />
<#else>
  <#assign lbdns=instance.publicIp />
</#if>
	
# install
cat << EOSH >  ${config.tmpDir}/${instance.instanceId}.sh
# update YUM respository location
${configuration("YUMREPO_CMD", avzone)}

#getting haproxy
wget -q ${config.YUMHOST}/loadbalancer/haproxy
chmod +x haproxy

#getting pound
wget http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt
rpm --import RPM-GPG-KEY.dag.txt
rm -f RPM-GPG-KEY.dag.txt
echo "[dag]" > /etc/yum.repos.d/dag.repo
echo "name=Dag RPM Repository for Red Hat Enterprise Linux" >> /etc/yum.repos.d/dag.repo
echo "baseurl=http://apt.sw.be/redhat/el5/en/x86_64/dag/" >> /etc/yum.repos.d/dag.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/dag.repo
echo "enabled=0" >> /etc/yum.repos.d/dag.repo
yum --enablerepo=dag --nogpgcheck -y install pound
useradd -s /sbin/nologin -d /root pound
EOSH

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${lbdns}:/root  
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${lbdns} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh" 
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${lbdns} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh" 
