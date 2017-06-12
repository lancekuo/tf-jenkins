output "bastion_public_ip" {
    value = "${aws_eip.bastion.public_ip}"
}
output "bastion_private_ip" {
    value = "${aws_eip.bastion.private_ip}"
}

output "registry" {
    value = "${aws_s3_bucket.registry.arn}"
}
