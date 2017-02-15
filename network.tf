#######################
# Network Definitions #
#######################

#
# DHCP set options
#
resource "aws_vpc_dhcp_options" "default" {
  domain_name         = "${var.tld} node.${var.vdc}.consul node.consul"
  domain_name_servers = ["${data.terraform_remote_state.dns_rs.dns_ip}"]
  tags {
    Name  = "${var.owner}_default"
    owner = "${var.owner}"
  }
}
# Associate DHCP set to the VPC.
resource "aws_vpc_dhcp_options_association" "deault_assoc" {
  vpc_id          = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

#
# SUBNETS
#

# PUBLIC SUBNETS
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet( var.vpc_cidr, var.subnet_bits, count.index )}"
  availability_zone = "${var.region}${element( split( ",", lookup( var.azs, var.region ) ), count.index )}"
  count             = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  tags {
    Name            = "${var.owner}_public_${element( split( ",", lookup( var.azs, var.region ) ), count.index )}"
    Owner           = "${var.owner}"
  }
}

# PRIVATE SUBNETS
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet( var.vpc_cidr, var.subnet_bits, ( length( split( ",", lookup( var.azs, var.region ) ) ) + count.index ) )}"
  availability_zone = "${var.region}${element( split( ",", lookup( var.azs, var.region ) ), count.index )}"
  count             = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  tags {
    Name            = "${var.owner}_private_${element( split( ",", lookup( var.azs, var.region ) ), count.index )}"
    Owner           = "${var.owner}"
  }
}

#
# GATEWAYS
#

#
# EIPs
#
resource "aws_eip" "natgw" {
  vpc   = true
  count = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
}

# INTERNET GW
resource "aws_internet_gateway" "default" {
  vpc_id  = "${aws_vpc.default.id}"
  tags {
    Name  = "${var.owner}_default"
    Owner = "${var.owner}"
  }
}

# NAT GW
resource "aws_nat_gateway" "default" {
  allocation_id = "${element( aws_eip.natgw.*.id, count.index )}"
  subnet_id     = "${element( aws_subnet.public.*.id, count.index )}"
  count         = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  depends_on    = ["aws_internet_gateway.default"]
  # Tags not supported
}

#
# ROUTES
#

# DEFAULT ROUTE TO IGW
resource "aws_route_table" "default_to_igw" {
  vpc_id       = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name       = "${var.owner}_default_to_igw"
    Owner      = "${var.owner}"
  }
}

resource "aws_route_table" "default_to_natgw" {
  vpc_id           = "${aws_vpc.default.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element( aws_nat_gateway.default.*.id, count.index )}"
  }
  count            = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  tags {
    Name           = "${var.owner}_default_to_natgw_${element( split( ",", lookup( var.azs, var.region ) ), count.index )}"
    Owner          = "${var.owner}"
  }
}

resource "aws_route_table_association" "public_subnet_and_default_to_igw" {
  subnet_id      = "${element( aws_subnet.public.*.id, count.index )}"
  route_table_id = "${aws_route_table.default_to_igw.id}"
  count          = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  # Tags not supported
}

resource "aws_route_table_association" "private_subnet_and_default_to_natgw" {
  subnet_id      = "${element( aws_subnet.private.*.id, count.index )}"
  route_table_id = "${element( aws_route_table.default_to_natgw.*.id, count.index )}"
  count          = "${length( split( ",", lookup( var.azs, var.region ) ) )}"
  # Tags not supported
}

#
# VPC ENDPOINTS
#

# S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${aws_vpc.default.id}"
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${aws_vpc.default.main_route_table_id}"]
}

#
# Outputs
#
# TODO: refacto : remove the join pass directly the list.
output "private_subnet" {
  value = "${join( ",", aws_subnet.private.*.id )}"
}

output "public_subnet" {
  value = "${join( ",", aws_subnet.public.*.id )}"
}

output "vpc" {
  value = "${aws_vpc.default.id}"
}

output "vpc_cidr_block" {
  value = "${var.vpc_cidr}"
}

output "azs" {
  value = "${lookup( var.azs, var.region )}"
}
