{ "Fn::Base64" : { "Fn::Join" : ["", [
  "#!/bin/bash", "\n",
  "hostname ", "${__HOSTNAME__}", "\n",
  "cat > /etc/hostname << EOC\n",
  "${__HOSTNAME__}\n",
  "EOC\n",
  "cat >> /etc/hosts << EOC\n",
  "127.0.0.1 ${__HOSTNAME__}\n",
  "${configuration("YUMHOST", "${AvailabilityZone}")} YUMHOST\n",
  "${configuration("CHEF_IP", "${AvailabilityZone}")} ${configuration("CHEF_SERVER", "${AvailabilityZone}")}\n",
  "${configuration("CHEF_IP", "${AvailabilityZone}")} transcendmonitorhost\n",
  "${configuration("INTERNAL_SERVICE_IP", "${AvailabilityZone}")} ${configuration("INTERNAL_SERVICE_HOST", "${AvailabilityZone}")}\n",

  "EOC\n",
  "cat > /etc/chef/client.rb << EOC\n",
  "log_level          :info\n",
  "log_location       STDOUT\n",
  "chef_server_url \"${configuration("CHEF_API_URL", "${AvailabilityZone}")}\"\n",
  "environment \"${configuration("CHEF_ENV", "${AvailabilityZone}")}\"\n",
  "file_cache_path    \"/var/cache/chef\"\n",
  "file_backup_path   \"/var/lib/chef/backup\"\n",
  "pid_file           \"/var/run/chef/client.pid\"\n",
  "cache_options({ :path => \"/var/cache/chef/checksums\", :skip_expires => true})\n",
  "signing_ca_user \"chef\"\n",
  "Mixlib::Log::Formatter.show_time = true\n",
  "EOC\n",
  "curl -m 60 -s -d '",
  "Action=BootstrapDBInstance",
  "&Acid=", "${__ACID__}",
  "&Hostname=", "${__HOSTNAME__}",
  "&DBInstanceIdentifier=", "${DBInstanceIdentifier}",
  "' ",
  "${configuration("TRANSCEND_URL", "${AvailabilityZone}")}",
  "\n",
  "INST=`curl -m 60 -s http://169.254.169.254/latest/meta-data/instance-id`",
  "\n",
  "curl -m 60 -s -d \"",
  "Action=RegisterInstance",
  "&Id=$INST",
  "&Acid=", "${__ACID__}",
  "&Hostname=", "${__HOSTNAME__}",
  "\" ",
  "${configuration("TRANSCEND_URL", "${AvailabilityZone}")}",
  "\n"
]]}}
