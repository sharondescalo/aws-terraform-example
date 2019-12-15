data "aws_caller_identity" "current" {}

provider "aws" {
    region = "${var.request_region}"
    profile = "${var.profile}"
}
provider "aws" {
  alias  = "peer"
  region = "${var.accept_region}"
  profile = "${var.profile}"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${var.request_vpc_id}"
  peer_vpc_id   = "${var.accept_vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_region   = "${var.accept_region}"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}         

# resource "aws_vpc_peering_connection" "con" {
#     peer_owner_id = "${data.aws_caller_identity.current.account_id}"
#     vpc_id        = "${var.request_vpc_id}"
#     peer_vpc_id   = "${var.accept_vpc_id}"
#     auto_accept   = true
# }