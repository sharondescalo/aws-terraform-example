# Required Variables
variable "request_vpc_id" {}
variable "accept_vpc_id" {}
variable "request_region" {}
variable "accept_region" {}
variable "profile" {
  default = "terraform_iam_user"
}