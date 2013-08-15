"AWS::CloudFormation::Init" : {
  "config" : {
    "packages" : {
      "rubygems" : {
         "chef" : [ "0.10.2" ]
      },
      "yum" : {
         "gcc-c++"    : [],
         "ruby-devel" : [],
         "make"       : [],
         "autoconf"   : [],
         "automake"   : [],
         "rubygems"   : []
      }
    },
    "files" : {
      "/root/.chef/client.pem" : {
        "content" : { "Ref" : "ChefPrivateKey" },
        "mode" : "000400",
        "owner" : "root",
        "group" : "root"
      },
      "/etc/chef/client.rb" : {
        "content" : { "Fn::Join" : ["\n", [
          "log_level :info",
          "log_location STDOUT",
		  "ssl_verify_mode :verify_none",
		  "chef_server_url \"http://$2:4000\"",
		  "file_cache_path  \"/var/cache/chef\"",
		  "pid_file \"/var/run/chef/client.pid\"",
		  "cache_options({ :path => \"/var/cache/chef/checksums\", :skip_expires => true})",
		  "signing_ca_user \"chef\"",
		  "Mixlib::Log::Formatter.show_time = true",
		  "validation_client_name \"chef-validator\"",
		  "client_key \"/root/.chef/client.pem\""
        ]] },
        "mode" : "000644",
        "owner" : "root",
        "group" : "root"
      },
      "/etc/chef/node.json" : {
        "content" : {                  
          "wordpress" : {
            "db" : {
              "database" : {"Ref" : "DBName"},
              "user"     : {"Ref" : "DBUser"},
              "host"     : {"Fn::GetAtt" : ["DBInstance", "Endpoint.Address"]},
              "password" : {"Ref" : "DBPassword" }
            }
          },
          "run_list": [ "recipe[wordpress]" ]
        },
        "mode" : "000644",
        "owner" : "root",
        "group" : "wheel"
      }
    }
  }
}
