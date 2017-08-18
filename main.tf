# Configure the AWS Provider
provider "aws" {
  #access_key = "xxxxxxxx" #Obtained from ~/.aws/credentials
  #secret_key = "xxxxxxxx" #Obtained from ~/.aws/credentials
  region     = "${var.region}"
  profile = "ryan.sheldrake" #This is only required if you have more than one profile in ~/.aws/credentials
}


//testing
resource "aws_vpc" "poc-vpc" {
  cidr_block       = "10.0.0.0/16"
  #instance_tenancy = "dedicated"
  enable_dns_hostnames = "true"

  tags {
    Name = "Terrform-VPC ${var.prospect_name} ${var.se_name}"
    SE-Name = "${var.se_name}"
  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.poc-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.poc-internet-gateway.id}"
  }
}

resource "aws_route_table_association" "external-main" {
  subnet_id = "${aws_subnet.poc-subnet.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_internet_gateway" "poc-internet-gateway" {
  vpc_id = "${aws_vpc.poc-vpc.id}"
}

resource "aws_subnet" "poc-subnet" {
  vpc_id     = "${aws_vpc.poc-vpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  depends_on = ["aws_vpc.poc-vpc"]
  tags {
    Name = "Terraform-Subnet ${var.prospect_name} ${var.se_name}"
    SE-Name = "${var.se_name}"
  }
}


resource "aws_instance" "POC-Instance" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.availability_zone}"
  associate_public_ip_address = true
  key_name = "Pipeline-POC-Key-Pair"
  vpc_security_group_ids = ["${aws_security_group.poc-sec-group.id}"]
  subnet_id = "${aws_subnet.poc-subnet.id}"
  depends_on = ["aws_security_group.poc-sec-group", "aws_subnet.poc-subnet"]
  tags {
    Name = "Terraform-Instance ${var.prospect_name} ${var.se_name}"
    SE-Name = "${var.se_name}"
  }
}


/*
  POC security group
*/
resource "aws_security_group" "poc-sec-group" {
  name = "POC-Sec-Group"
  description = "Allow incoming HTTP connections."
  vpc_id = "${aws_vpc.poc-vpc.id}"

  ingress {
    from_port = 8070
    to_port = 8070
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}




