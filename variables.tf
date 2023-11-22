
variable "instance_count" {
  description = "Number of EC2 instances to create"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}