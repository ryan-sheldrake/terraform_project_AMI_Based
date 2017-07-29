
variable "region" {
  description = "The AWS region to create resources in."
  default = "us-west-2"
}

variable "availability_zone" {
  description = "The availability zone"
  default = "us-west-2a"
}


variable "instance_type" {
  default = "t2.large"
}

variable "amis" {
  type = "map"
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  # TODO: support other regions.
  #default = {"us-west-2" = "ami-6df1e514"}
  default = {"us-west-2" = "ami-f98e6b81"} #this is a vanilla pipeline AMI created by Ryan July 12 2017
}


