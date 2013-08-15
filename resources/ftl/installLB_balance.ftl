#!/bin/bash

# installLB_haproxy.ftl
# Install a load balancer on startup using haproxy
# input config, loadBalancer, instanceIds
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

<#assign lbb=loadBalancer.lbbean />
<#list lbb.lbInstances as lbinst>
	<#assign lbip=lbinst.ipAddress />
	scp -i ${config.instSshKey} -o StrictHostKeyChecking=false ${config.binUploadPath} root@${lbip}:${config.lbBin}  
	ssh -i ${config.instSshKey} root@${lbip} -o StrictHostKeyChecking=false "chmod +x ${config.lbBin}" 
	
	# install Pound
	cat << EOSH >  ${config.tmpDir}/${lbinst.instanceId}.sh
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
	scp -i ${config.instSshKey} -o StrictHostKeyChecking=false ${config.tmpDir}/${lbinst.instanceId}.sh root@${lbip}:/root  
	ssh -i ${config.instSshKey} root@${lbip} -o StrictHostKeyChecking=false "chmod +x /root/${lbinst.instanceId}.sh" 
	ssh -i ${config.instSshKey} root@${lbip} -o StrictHostKeyChecking=false "/root/${lbinst.instanceId}.sh" 
	
</#list>

