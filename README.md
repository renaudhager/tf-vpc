# tf-vpc

## Description
This repo contain terrraform code to build needed elements for a VPC :
- VPC / Subnets
- NAT GW / Interet GW
- Route53 TLD zone
- S3 endpoint


You will need to create a file named : terraform.tfvars to store sensitives variables.
Please see terraform.tfvars.example.

## Limitation

- Currently one stack so any change can bring down the infrastructure.

## TODO

- Create separate stacks for instances to avoid down time during change.
