#
# AWS Provisioning
#
variable "access_key" {}
variable "secret_key" {}
variable "owner"      { default = "r.hager" }
variable "tld"        { default = "ue2.aws" }
variable "vdc"        { default = "ue2" }
variable "region"     { default = "us-east-2" }


variable "azs" {
  default = {
    "eu-west-1"      = "a,b,c"
    "eu-central-1"   = "a,b"
    "us-east-1"      = "a,b,c"
    "us-east-2"      = "a,b,c"
    "us-west-1"      = "a,c"
    "us-west-2"      = "b,c"
    "ap-southeast-2" = "a,b,c"
  }
}

#
# NETWORK
#
variable "vpc_cidr"    { default = "172.16.8.0/24" }
variable "subnet_bits" { default = "3" }

#
# Remote state
#
variable "dns_rs_bucket" {}
variable "dns_rs_key" {}
