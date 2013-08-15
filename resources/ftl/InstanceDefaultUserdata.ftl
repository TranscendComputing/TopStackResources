{ "Fn::Base64" : { "Fn::Join" : ["", [
  "curl ${configuration(\"TRANSCENDURL\", ${AvailabilityZone})}",
  "?Action=BootstrapChefRoles",
  "&InstanceName=", "${InstanceName}",
  "&ChefRoles=","${ChefRoles}",
  "\n"
]]}}
