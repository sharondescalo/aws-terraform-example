variable "cluster_name"{
    default = "aws-multi-region"
}

variable "nodes_per_region" {
    default = "1"
}

module "region-1" {
    source  = "./simple_region/"
    region = "us-east-1"
    cluster_name = "${var.cluster_name}"
    region_name = "east"
    vpc_cidr = "10.0.0.0/24"
    nb_nodes = "${var.nodes_per_region}"
}

module "region-2" {
    source  = "./simple_region/"
    region = "us-east-1"
    cluster_name = "${var.cluster_name}"
    region_name = "west"
    vpc_cidr = "11.1.1.0/24"
    nb_nodes = "${var.nodes_per_region}"
}
module "vpc_peer_1" {
    source  = "./vpc_peer/"
    request_region = "${module.region-1.region}"
    request_vpc_id = "${module.region-1.vpc_id}"
    accept_region = "${module.region-2.region}"
    accept_vpc_id = "${module.region-2.vpc_id}"
}

module "vpc_ping_1" {
    source  = "./ping_instance/"
    vm_depends_on = "${module.region-1}"
    instance_1_id = "${module.region-1.0.instance_id}"
    instance_1_public_ip = "${module.region-1.public_ip}"
    instance_2_private_ip = "${module.region-2.0.private_ip}"
}



module "vpc_ping_2" {
    source  = "./ping_instance/"
    vm_depends_on = "${module.region-2}"
    instance_1_id = "${module.region-2.0.instance_id}"
    instance_1_public_ip = "${module.region-2.public_ip}"
    instance_2_private_ip = "${module.region-1.0.private_ip}"
}


#  #trying ping the machine by Changing existing instance. requiredre-provisioning
# resource "null_resource" "ping_instance_re_provision" {
#   # Changes to any instance of the cluster requires re-provisioning
#   triggers = {
#     # cluster_instance_ids = "${join(",", module.region-1.instance_id)}"
#     # cluster_instance_ids = "${join(",", aws_instance.node.*.id)}"
#     cluster_instance_ids = "${module.region-1.0.instance_id}"
#     # cluster_instance_ids = "${join(",", module.region-1.instance_id)}"

#   }

#   # Bootstrap script can run on any instance of the cluster
#   # So we just choose the first in this case
#   connection {
#     #   host = "${module.region-1.public_ip}"
#     # host = "${element(aws_instance.node.*.public_ip, 0)}"
#     host = "${element(module.region-1.public_ip, 0)}"
#   }

#   provisioner "remote-exec" {
#     # Bootstrap script called with private_ip of each node in the cluster
#     inline = [
#         "ping -c 5  ${join(" ", module.region-2.0.private_ip)}"
#         # "ping -c 5 ${module.region-2.private_ip}"
#     #   "ping -c 5  ${join(" ", aws_instance.node.*.private_ip)}"
#     ]
#   }
# }