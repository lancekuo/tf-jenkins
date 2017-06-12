variable "vpc_default_id" {}

resource "aws_security_group" "node" {
    provider    = "aws.${var.region}"
    name        = "${terraform.env}-${var.project}-node"
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

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    tags {
        Name    = "${terraform.env}-${var.project}-node"
        Env     = "${terraform.env}"
        Project = "${var.project}"
    }
}

resource "aws_security_group" "bastion" {
    provider    = "aws.${var.region}"
    name        = "${terraform.env}-${var.project}-bastion"
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
        Name    = "${terraform.env}-${var.project}-bastion"
        Env     = "${terraform.env}"
        Project = "${var.project}"
    }
}

resource "aws_security_group" "jenkins-elb" {
    provider    = "aws.${var.region}"
    name        = "${terraform.env}-jenkins-elb"
    description = "Provide the access to internet to connect to internal jenkins site"
    vpc_id      = "${var.vpc_default_id}"

    ingress {
        from_port   = 80
        to_port     = 80
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
        Name    = "${terraform.env}-jenkins-elb"
        Env     = "${terraform.env}"
        Project = "${var.project}"
    }
}
