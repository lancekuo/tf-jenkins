data "template_file" "user-data-node" {
    template = "${file("${path.module}/cloud-init/hostname")}"
    count    = "${var.count_jenkins_node}"

    vars {
        hostname = "${terraform.workspace}-${lower(var.project)}-node-${count.index}"
        domain   = "${var.domain}"
    }
}
resource "aws_key_pair" "node" {
    provider   = "aws.${var.aws_region}"
    key_name   = "${terraform.workspace}-${var.aws_region}-${var.rsa_key_node["aws_key_name"]}"
    public_key = "${file("${path.root}${var.rsa_key_node["public_key_path"]}")}"
}
resource "aws_instance" "node" {
    provider               = "aws.${var.aws_region}"
    count                  = "${var.count_jenkins_node}"
    instance_type          = "${var.instance_type_node}"
    ami                    = "${var.aws_ami_docker}"
    key_name               = "${aws_key_pair.node.id}"
    vpc_security_group_ids = ["${aws_security_group.node.id}"]
    subnet_id              = "${element(split(",", var.subnet_public_app), (count.index))}"
    subnet_id              = "${element(var.subnet_public_app_ids, (count.index))}"


    root_block_device = {
        volume_size = 20
    }

    connection {
        bastion_host        = "${aws_eip.bastion.public_ip}"
        bastion_user        = "ubuntu"
        bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

        type                = "ssh"
        user                = "ubuntu"
        host                = "${self.private_ip}"
        private_key         = "${file("${path.root}${var.rsa_key_node["private_key_path"]}")}"
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'Hello World.'"
        ]
    }
    tags  {
        Name    = "${terraform.workspace}-${lower(var.project)}-node-${count.index}"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
        Role    = "node"
        Index   = "${count.index}"
    }
    user_data  = "${element(data.template_file.user-data-node.*.rendered, count.index)}"
}
