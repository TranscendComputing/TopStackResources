#!/bin/bash

# registerInstance_proxy.ftl
# Configure load balancer using haproxy
# input config, account, loadBalancer, instances, lbinst
# return instanceId

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#------ config haproxy 
	<#if config.useIpforInstances == "yes" >
	  <#assign lbdns=lbinst.internalIp />
	<#else>
	  <#assign lbdns=lbinst.publicIp />
	</#if>	
	
  # create haproxy config file
  cat << EOF > ${config.tmpDir}/${lbinst.instanceId}.conf
global
daemon
maxconn 256

defaults
mode http
timeout connect 5000ms
timeout client 50000ms
timeout server 50000ms

frontend http-in
<#list loadBalancer.listeners as lisn>
  <#assign proto=lisn.protocol />	
  <#assign lbport=lisn.loadBalancerPort />
  <#assign instport=lisn.instancePort />
  <#if lisn.protocol="HTTP">
bind *:${lbport?string.computer}
    
default_backend servers
backend servers 
    <#list instances as inst>
server server${inst_index} ${inst.ipAddress}:${instport?string.computer} maxconn 32
    </#list>
  </#if>
</#list>
EOF

  # copy haproxy configuration
  scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${lbinst.instanceId}.conf root@${lbdns}:${config.lbConfigDir}

#------ config pound 

  # create pound config file
  cat << EOF > ${config.tmpDir}/${lbinst.instanceId}.pound
#Global settings
# specify a user execute pound
User "pound"
# specify a group execute pound
Group "pound"
# log level (max = 5)
LogLevel 0
# send heartbeat ?/per second
Alive 30
# run as a daemon
Daemon 1

  <#list loadBalancer.listeners as lisn>
  	<#assign proto=lisn.protocol />	
	<#assign lbport=lisn.loadBalancerPort />
	<#assign instport=lisn.instancePort />
  	<#if lisn.protocol="HTTPS">
ListenHTTPS
Address ${lbdns}
Port    ${lbport?string.computer}
Cert    "${config.lbConfigDir}/server.chain"
End

Service
      <#list instances as inst>
BackEnd
Address ${inst.ipAddress}
Port    ${instport?string.computer}
End
	  </#list>
End
  	</#if>
  </#list>
EOF

  # config pound on LB
  scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${lbinst.instanceId}.pound root@${lbdns}:${config.lbConfigDir}  
  scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false /home/raj/MsiWorkspace/server.chain root@${lbdns}:${config.lbConfigDir}/server.chain  

#----- restart haproxy and pound
  cat << EOF > ${config.tmpDir}/${lbinst.instanceId}.sh
date
kill -9 \`ps -ef | grep "[h]aproxy" | awk '{print \$2}'\`
sleep 1
${config.lbBin} -f ${config.lbConfigDir}/${lbinst.instanceId}.conf
date
kill -9 \`ps -ef | grep "[p]ound" | awk '{print \$2}'\`
pound -f ${config.lbConfigDir}/${lbinst.instanceId}.pound
date
EOF
  echo "reconfiguring LB" 
  scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false "${config.tmpDir}/${lbinst.instanceId}.sh" root@${lbdns}:${config.lbConfigDir}
  date
  ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${lbdns} -o StrictHostKeyChecking=false "${config.lbConfigDir}/${lbinst.instanceId}.sh" 
  date
  echo "LB reconfigured"
