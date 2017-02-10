#
# ROUTE 53
#
resource "aws_route53_zone" "default" {
  name    = "${var.tld}"
  vpc_id  = "${aws_vpc.default.id}"

  tags {
    Name  = "${var.owner}_default"
    Owner = "${var.owner}"
  }
}

#
# Outputs
#

output "default_route53_zone" {
  value = "${aws_route53_zone.default.zone_id}"
}
