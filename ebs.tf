resource "aws_volume_attachment" "ebs_att" {
    provider     = "aws.${var.aws_region}"
    device_name  = "${var.device_file}"
    volume_id    = "${aws_ebs_volume.storage-jenkins.id}"
    instance_id  = "${element(aws_instance.node.*.id, 0)}"
    skip_destroy = true
    force_detach = false
}
resource "aws_ebs_volume" "storage-jenkins" {
    provider          = "aws.${var.aws_region}"
    availability_zone = "${element(var.availability_zones, (length(aws_instance.node.*.id)-1))}"
    size              = 50
    type              = "gp2"
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
            "echo '====== Creating Mount point =====';if [ -d ${var.mount_point} ];then echo \"=> The mount endpoint has existed.\";else sudo mkdir ${var.mount_point};sudo chown -R ubuntu:ubuntu ${var.mount_point};sudo chmod 777 ${var.mount_point};echo \"Mount point created.\";fi",
            "echo '====== Creating Partition =====';if [ ! -b ${var.partition_file} ]; then sudo parted ${var.device_file} --script -- mklabel msdos mkpart primary ext4 0 -1;else echo '=> Partition has created, skipping this step...';fi",
            "echo '====== Making File system =====';if [ ! \"$(sudo lsblk --fs ${var.partition_file} --nodeps -o FSTYPE -t -n)\" = \"ext4\" ]]; then sudo mkfs.ext4 -F ${var.partition_file};else echo '=> File system has created, skipping this step...';fi",
            "echo '====== Updating fstab file =====';if ! grep -e \"$$(sudo file -s ${var.partition_file}|awk -F\\  '{print $8}')    ${var.mount_point}\" /etc/fstab 1> /dev/null;then echo \"`sudo file -s ${var.partition_file}|awk -F\\  '{print $8}'`    ${var.mount_point}    ext4    defaults,errors=remount-ro    0    0\"| sudo tee -a /etc/fstab;else echo '=> Fstab has updated, no change in this step...'; fi ",
            "echo '====== Mounting Volume =====';if grep -qs '${var.mount_point}' /proc/mounts; then echo \"=> ${var.mount_point} has mounted.\"; else sudo mount `sudo file -s ${var.partition_file}|awk -F\\  '{print $8}'` ${var.mount_point}; fi",
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
