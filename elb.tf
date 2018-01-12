resource "aws_elb" "jenkins" {
    name = "${terraform.workspace}-jenkins"

    subnets         = ["${var.subnet_public_app_ids}"]
    security_groups = ["${aws_security_group.jenkins-elb.id}"]
    instances       = ["${aws_instance.node.*.id}"]

    listener {
        instance_port     = 8080
        instance_protocol = "http"
        lb_port           = 443
        lb_protocol       = "http"
    }
    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 4
        target              = "TCP:8080"
        interval            = 5
    }
    tags  {
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
    }
}
