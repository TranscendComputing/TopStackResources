{
  "AWS::CloudFormation::Init" : {
    "config" : {
      "packages" : {
        "yum" : {
          "memcached": []
        }
      }
    }
  }
}
