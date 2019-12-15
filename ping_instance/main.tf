
resource "null_resource" "ping_instance_re_provision" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    # cluster_instance_ids = "${join(",", module.region-1.instance_id)}"
    # cluster_instance_ids = "${join(",", aws_instance.node.*.id)}"
    # cluster_instance_ids = "${module.region-1.0.instance_id}"
    # cluster_instance_ids = "${join(",", module.region-1.instance_id)}"
    cluster_instance_ids = "${var.instance_1_id}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    #   host = "${module.region-1.public_ip}"
    # host = "${element(aws_instance.node.*.public_ip, 0)}"
    # host = "${element(module.region-1.public_ip, 0)}"
    host = "${element(var.instance_1_public_ip, 0)}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
        # "ping -c 5  ${join(" ", module.region-2.0.private_ip)}"
        # "ping -c 5 ${module.region-2.private_ip}"
    #   "ping -c 5  ${join(" ", aws_instance.node.*.private_ip)}"
        "ping -c 5  ${var.instance_2_private_ip}"

    ]
  }
}