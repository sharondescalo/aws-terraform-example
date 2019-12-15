provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# Network Resources
resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true

    tags = {
        Name = "${var.cluster_name}-${var.region_name}-vpc"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.vpc_cidr}"
    availability_zone = "${lookup(var.availability_zone, var.region)}"

    tags = {
        Name = "${var.cluster_name}-${var.region_name}-subnet"
    }
}

resource "aws_security_group" "ssh-sg" {
  name        = "allow-ssh"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id="${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

# resource "aws_security_group" "tls-sg" {
#   name        = "allow-tls"
#   description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
#   #vpc_id      = "${aws_vpc.my-vpc.id}"

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags {
#     Name = "allow-tls"
#   }
# }

resource "aws_security_group" "ping-ICMP-sg" {
  name        = "alow-ping"
  description = "Default security group that allows to ping the instance"
  vpc_id="${aws_vpc.vpc.id}"

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alow-ping"
  }
}


# Allow the web app to receive requests on port 8080
# resource "aws_security_group" "web_server" {
#   name        = "default-web_server-example"
#   description = "Default security group that allows to use port 8080"
#   vpc_id="${aws_vpc.vpc.id}"

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags {
#     Name = "web_server-example-default-vpc"
#   }
# }

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
        Name = "${var.cluster_name}-${var.region_name}-gateway"
    }
}

resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags = {
        Name = "${var.cluster_name}-${var.region_name}-subnet-rt"
    }
}

resource "aws_route_table_association" "public-rt" {
    subnet_id = "${aws_subnet.subnet.id}"
    route_table_id = "${aws_route_table.public-rt.id}"
}




# Instance Resources

resource "aws_key_pair" "kp" {
    key_name = "${var.cluster_name}-${var.region_name}-key"
    public_key = "${file("${var.public_key_path}")}"
}

resource "aws_instance" "node" {
    ami = "${lookup(var.ami, var.region)}"
    instance_type = "${var.instance_type}"
    count = "${var.nb_nodes}"

    key_name = "${aws_key_pair.kp.id}"
    subnet_id = "${aws_subnet.subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.ping-ICMP-sg.id}", "${aws_security_group.ssh-sg.id}"]
    source_dest_check = false
    associate_public_ip_address = true

    root_block_device {
        volume_size = 20
    }
    
    tags = {
        Name = "${var.cluster_name}-${var.region_name}-${count.index}"
    }
}
