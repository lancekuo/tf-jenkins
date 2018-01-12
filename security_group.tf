variable "vpc_default_id" {}

resource "aws_security_group" "node" {
    name        = "${terraform.workspace}-${var.project}-node"
    description = "Gossip and port for docker internal"
    vpc_id      = "${var.vpc_default_id}"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = ["${aws_security_group.bastion.id}"]
    }
    ingress {
        from_port       = 2375
        to_port         = 2375
        protocol        = "tcp"
        security_groups = ["${aws_security_group.bastion.id}"]
    }
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = ["${aws_security_group.jenkins-elb.id}"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    tags {
        Name    = "${terraform.workspace}-${var.project}-node"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
    }
}

resource "aws_security_group" "bastion" {
    name        = "${terraform.workspace}-${var.project}-bastion"
    description = "Access to the bastion machine"
    vpc_id      = "${var.vpc_default_id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name    = "${terraform.workspace}-${var.project}-bastion"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
    }
}

resource "aws_security_group" "private_registry" {
    name        = "${terraform.workspace}-${var.project}-private_registry"
    description = "Access to Private Registry service"
    vpc_id      = "${var.vpc_default_id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = ["${aws_security_group.node.id}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name    = "${terraform.workspace}-${var.project}-private_registry"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
    }
}
resource "aws_security_group" "jenkins-elb" {
    name        = "${terraform.workspace}-jenkins-elb"
    description = "Provide the access to internet to connect to internal jenkins site"
    vpc_id      = "${var.vpc_default_id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    tags {
        Name    = "${terraform.workspace}-jenkins-elb"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
    }
}
