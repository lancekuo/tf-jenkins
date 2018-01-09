output "bastion_public_ip" {
    value = "${aws_eip.bastion.public_ip}"
}
output "bastion_private_ip" {
    value = "${aws_eip.bastion.private_ip}"
}

output "node_private_ip" {
    value = "${join(",", aws_instance.node.*.private_ip)}"
}
output "security_group_node_id" {
    value = "${aws_security_group.node.id}"
}
output "ebs_jenkins_id" {
    value = "${aws_ebs_volume.storage-jenkins.id}"
}

output "elb_jenkins_dns" {
    value = "${aws_elb.jenkins.dns_name}"
}

