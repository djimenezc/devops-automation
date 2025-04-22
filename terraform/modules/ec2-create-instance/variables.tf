variable "aws_region" {
  type        = string
  description = "Region where the instance must be installed"
}

variable "keypair_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "role_name" {
  type = string
}

variable "delete_root_disk_on_termination" {
  type    = bool
  default = true
}

variable "root_volume_type" {
  type    = string
  default = "gp2"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "vpc_name" {
  type = string
}

variable "ami_name" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"
}

variable "ami_root_device_type" {
  type    = string
  default = "ebs"
}

variable "ami_owner" {
  type    = string
  default = "099720109477"
}

variable "userdata_files" {
  type = list(string)
}

variable "ingress_rules" {
  type = map(object({
    description : string,
    cidr_ipv4 : string,
    from_port : number,
    ip_protocol : string,
    to_port : number,
  }))
  default = {}
}

variable "egress_rules" {
  type = map(object({
    description : string,
    cidr_ipv4 : string,
    from_port : number,
    ip_protocol : string,
    to_port : number,
  }))
  default = {}
}

variable "subnet_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "dns_public_subdomain" {
  type    = string
  default = ""
}

variable "dns_public_zone_domain" {
  type    = string
  default = ""
}

variable "policy_name" {
  type = string
}

variable "secrets_file_path" {
  type    = string
  default = ""
}

variable "get_password_data" {
  type    = bool
  default = false
}

variable "userdata_extra_file_string" {
  type        = string
  description = "include an extra fragment of code at the beginning of the userdata"
  default     = ""
}

variable "userdata_template_variables" {
  type        = map(string)
  description = "variable to use in the userdata template string"
  default     = {}
}

variable "env" {
  type    = string
  default = ""
}

variable "policy_permissions" {
  type    = list(string)
  default = []
}
