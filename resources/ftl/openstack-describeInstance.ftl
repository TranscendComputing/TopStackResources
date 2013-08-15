#!/bin/bash

# createLoadBalancer.ftl
# create a load balancer instance in Eucalyptus
# input configuration, loadBalancer, avzone
# return instanceId

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#run instance
resp=`euca-describe-instances ${instanceId} | grep "${instanceId}"`
echo "response $resp"
insId=`echo $resp | cut -d ' ' -f 2`
ip=`echo $resp | cut -d ' ' -f 5`
dns=`echo $resp | cut -d ' ' -f 4`
stat=`echo $resp | cut -d ' ' -f 6`
echo "returned " $insId $dns $ip $stat

if [ $insId != '${instanceId}' ]; then 
stat='not-found';
fi

if [ "$stat" == "running" ]; then
	ipAddress=`euca-allocate-address | cut -f 2` 
	echo "ipAddress $ipAddress"
	euca-associate-address -i ${instanceId} $ipAddress
	resp=`euca-describe-instances ${instanceId} | grep "${instanceId}"`
	echo "response $resp"
	insId=`echo $resp | cut -d ' ' -f 2`
	ip=`echo $resp | cut -d ' ' -f 5`
	dns=`echo $resp | cut -d ' ' -f 4`
	stat=`echo $resp | cut -d ' ' -f 6`
	echo "returned " $insId $dns $ip $stat
	sleep 10
fi

# returning 
echo "returnInstanceId=$insId"  
echo "returnIpAddress=$ip"  
echo "returnDNSName=$dns"  
echo "returnStatus=$stat"  
