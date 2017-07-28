# Configure the AWS Provider
provider "aws" {
  #access_key = "xxxxxxxx" #Obtained from ~/.aws/credentials
  #secret_key = "xxxxxxxx" #Obtained from ~/.aws/credentials
  region     = "us-west-2"
  profile = "ryan.sheldrake" #This is only required if you have more than one profile in ~/.aws/credentials
}


resource "aws_vpc" "poc-vpc" {
  cidr_block       = "10.0.0.0/16"
  #instance_tenancy = "dedicated"
  enable_dns_hostnames = "true"

  tags {
    Name = "POC-VPC"
  }
}

resource "aws_subnet" "poc-subnet" {
  vpc_id     = "${aws_vpc.poc-vpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "POC-subnet"
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

  tags {
    Name = "POC Instance"
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
}




