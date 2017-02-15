#
# Remote State of Core module
#
data "terraform_remote_state" "dns_rs" {
    backend = "s3"
    config {
        bucket = "${var.dns_rs_bucket}"
        key    = "${var.dns_rs_key}"
        region = "${var.region}"
    }
}
