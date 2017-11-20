resource "aws_volume_attachment" "ebs_att" {
    provider     = "aws.${var.aws_region}"
    device_name  = "/dev/xvdg"
    volume_id    = "${aws_ebs_volume.storage-jenkins.id}"
    instance_id  = "${element(aws_instance.node.*.id, 0)}"
    skip_destroy = true
    force_detach = false
}
resource "aws_ebs_volume" "storage-jenkins" {
    provider          = "aws.${var.aws_region}"
    availability_zone = "${element(var.availability_zones, (length(aws_instance.node.*.id)-1))}"
    size              = 50
    lifecycle         = {
        ignore_changes  = "*"
        prevent_destroy = true
    }
    tags  {
        Name    = "${terraform.workspace}-${lower(var.project)}-storage-jenkins"
        Env     = "${terraform.workspace}"
        Project = "${var.project}"
        Role    = "storage"
    }
}

resource "null_resource" "ebs_trigger" {
    triggers {
        att_id = "${aws_volume_attachment.ebs_att.id}"
    }

    provisioner "remote-exec" {
        inline = [
            "if [ -d /opt/jenkins/ ];then echo \"The folder exists.\";else sudo mkdir /opt/jenkins;sudo chown -R ubuntu:ubuntu /opt/jenkins;sudo chmod 777 /opt/jenkins;echo \"Mount point created.\";fi",
            "if [ ! -b /dev/xvdg1 ]; then sudo parted /dev/xvdg --script -- mklabel msdos mkpart primary ext4 0 -1;fi",
            "if [ ! \"$(sudo lsblk --fs /dev/xvdg1 --nodeps -o FSTYPE -t -n)\" = \"ext4\" ]]; then sudo mkfs.ext4 -F /dev/xvdg1;fi",
            "if ! grep -e \"$$(sudo file -s /dev/xvdg1|awk -F\\  '{print $8}')    /opt/jenkins\" /etc/fstab 1> /dev/null;then echo \"`sudo file -s /dev/xvdg1|awk -F\\  '{print $8}'`    /opt/jenkins    ext4    defaults,errors=remount-ro    0    0\"| sudo tee -a /etc/fstab;else echo 'Fstab has the mount point'; fi ",
            "if grep -qs '/opt/jenkins' /proc/mounts; then echo \"/opt/jenkins has mounted.\"; else sudo mount `sudo file -s /dev/xvdg1|awk -F\\  '{print $8}'` /opt/jenkins; fi",
        ]
        connection {
            bastion_host        = "${aws_eip.bastion.public_ip}"
            bastion_user        = "ubuntu"
            bastion_private_key = "${file("${path.root}${var.rsa_key_bastion["private_key_path"]}")}"

            type                = "ssh"
            user                = "ubuntu"
            host                = "${element(aws_instance.node.*.private_ip, 0)}"
            private_key         = "${file("${path.root}${var.rsa_key_node["private_key_path"]}")}"
        }
    }
}
