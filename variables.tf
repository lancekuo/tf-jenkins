variable "aws_region"                     {}

variable "count_bastion_subnet_on_public" {}
variable "count_instance_per_az"          {}
variable "count_jenkins_node"             {}

variable "subnet_public_bastion_ids"      {type="list"}
variable "subnet_public_app_ids"          {type="list"}
variable "subnet_private_ids"             {type="list"}
variable "project"                        {}
variable "domain"                         {}
variable "availability_zones"             {type="list"}

variable "aws_ami_docker"                 {}
variable "instance_type_bastion"          {}
variable "instance_type_node"             {}

variable "rsa_key_bastion"                {type="map"}
variable "rsa_key_node"                   {type="map"}

provider "aws" {
    alias  = "${var.aws_region}"
    region = "${var.aws_region}"
}
