# Required Variables
variable "region" {}
variable "profile" {
  default = "terraform_iam_user"
}
variable "cluster_name" {}
variable "region_name" {}
variable "nb_nodes" {}
variable "vpc_cidr" {}

# Default Variables
variable "instance_type" {
    default = "t3.nano"
}
variable "public_key_path" {
    default = "~/.ssh/AWSKeyPair.pub"
}
variable "private_key_path" {
    default = "~/.ssh/AWSKeyPair.pem"
}
variable "ami-username" {
    default = "ubuntu"
}
variable "ami" {
    type = "map"
    default = {
        us-east-1 = "ami-0f9cf087c1f27d9b1"
        us-east-2 = "ami-0653e888ec96eab9b"
    }
}
variable "availability_zone" {
    type = "map"
    default = {
        us-east-1 = "us-east-1a"
        us-east-2 = "us-east-2a"
    }
}
