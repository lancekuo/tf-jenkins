resource "aws_key_pair" "node" {
    provider   = "aws.${var.region}"
    key_name   = "${terraform.workspace}-${var.region}-${var.node_aws_key_name}"
    public_key = "${file("${path.root}${var.node_public_key_path}")}"
}

data "template_file" "user-data-node" {
    template = "${file("${path.module}/cloud-init/hostname")}"
    count    = "${var.jenkins_node_count}"

    vars {
        hostname = "${terraform.workspace}-${lower(var.project)}-node-${count.index}"
        domain   = "${var.domain}"
    }
}
resource "aws_instance" "node" {
    provider               = "aws.${var.region}"
    count                  = "${var.jenkins_node_count}"
    instance_type          = "t2.small"
    ami                    = "${var.ami}"
    key_name               = "${aws_key_pair.node.id}"
    vpc_security_group_ids = ["${aws_security_group.node.id}"]
    subnet_id              = "${element(split(",", var.subnet_public_app), (count.index))}"

    root_block_device = {
        volume_size = 20
    }

    connection {
        bastion_host        = "${aws_eip.bastion.public_ip}"
        bastion_user        = "ubuntu"
        bastion_private_key = "${file("${path.root}${var.bastion_private_key_path}")}"

        type                = "ssh"
        user                = "ubuntu"
        host                = "${self.private_ip}"
        private_key         = "${file("${path.root}${var.node_private_key_path}")}"
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
    depends_on = [
        "aws_instance.bastion"
    ]
}
