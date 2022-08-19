variable "aws_region" {
  description = "Region where the instance must be installed"
}

variable "jenkins_role_arn" {
  description = "Role for the automation to be able to deploy the resources"
  default     = ""
}

variable "keypair_name" {
  type = string
  default = "david-key"
}

variable "instance_name" {
  type = string
  default = "david_image_builder"
}

variable "instance_type" {
  type = string
  default = "t4g.medium"
}

variable "role_name" {
  type = string
  default = "image-builder-ec2"
}

variable "delete_root_disk_on_termination" {
  type = bool
  default = true
}

variable "root_volume_type" {
  type    = string
  default = "gp2"
}

variable "root_volume_size" {
  type    = number
  default = 10
}

variable "vpc_name" {
  type    = string
  default = "devVPC"
}

variable "owner" {
  type    = string
  default = "david"
}
