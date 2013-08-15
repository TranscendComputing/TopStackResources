#!/bin/bash

# registerInstance.ftl
# Register an instance with load balancer
# input config, loadBalancer, instanceId
# return instanceId

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

<#assign lbb=loadBalancer.lbbean />
<#list lbb.lbInstances as lbinst>
	<#assign lbip=lbinst.ipAddress />
	
	<#list lbb.listeners as lisn>
		<#assign lbport=lisn.loadBalancerPort />
	</#list>
	
	<#list lbb.listeners as lisn>
		<#assign instport=lisn.instancePort />
	</#list>
	
	
	cmd="${config.lbBin} -c kill ${lbport}; ${config.lbBin} ${lbport}"
	<#list lbb.instances as inst>
		cmd="$cmd ${inst.ipAddress}:${instport}"
	</#list>
	
	# execute command on LB
	ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${lbip} -o StrictHostKeyChecking=false "$cmd" 
</#list>

