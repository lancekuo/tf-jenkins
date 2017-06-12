variable "subnet_public" {}
variable "subnet_public_app" {}
variable "subnet_private" {}
variable "subnet_on_public" {}
variable "subnet_per_zone" {}
variable "instance_per_subnet" {}
variable "jenkins_node_count" {}
variable "region" {}
variable "ami" {}
variable "project" {}
variable "domain" {}
variable "availability_zones" {}

variable "bastion_public_key_path" {}
variable "bastion_private_key_path" {}
variable "bastion_aws_key_name" {}
variable "node_public_key_path" {}
variable "node_private_key_path" {}
variable "node_aws_key_name" {}

provider "aws" {
    alias  = "${var.region}"
    region = "${var.region}"
}
