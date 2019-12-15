output "region" {
    value = "${var.region}"
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = ["${aws_instance.node.*.private_ip}"]

}
output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = ["${aws_instance.node.*.public_ip}"]
}
output "instance_id" {
  description = "List of IDs of instances"
  value       = ["${aws_instance.node.*.id}"]
}

# output "instance_id" {
#   description = "List of IDs of instances"
#   value       = ["${aws_instance.node.*.id}"]
# }

# output "instance_ip_addr" {
#   value = aws_instance.node.private_ip
# }