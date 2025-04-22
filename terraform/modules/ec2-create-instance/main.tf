terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.92.0"
    }
    random = {
      source  = "random"
      version = "~> 3.1.0"
    }
    tls = {
      source  = "tls"
      version = "~> 3.1.0"
    }
  }
}

data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_security_group" "create_instance" {
  name_prefix = "${var.instance_name}_rules_"
  description = "${var.instance_name} ingress rules"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "${var.instance_name}_rules"
    Env  = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.create_instance.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "instance" {
  for_each = var.egress_rules
  #checkov:skip=CKV_AWS_382:"Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
  # https://developers.cloudflare.com/cloudflare-one/policies/gateway/egress-policies/
  security_group_id = aws_security_group.create_instance.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
  description       = each.value.description
}

# Add a default deny all egress rule if no egress rules are specified
resource "aws_vpc_security_group_egress_rule" "default_deny" {
  count = length(var.egress_rules) == 0 ? 1 : 0

  description       = "default deny all egress rule if no egress rules are specified"
  security_group_id = aws_security_group.create_instance.id
  ip_protocol       = "-1"
  cidr_ipv4         = "127.0.0.1/32"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "root-device-type"
    values = [var.ami_root_device_type]
  }

}

resource "aws_iam_instance_profile" "profile" {
  name = aws_iam_role.role.name
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "role-assume-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "image_builder_aws_cli" {
  name        = var.policy_name
  path        = "/"
  description = "Policy to build images and manage ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.policy_permissions
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "role" {
  name = var.role_name

  assume_role_policy = data.aws_iam_policy_document.role-assume-policy-document.json
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws-cli" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.image_builder_aws_cli.arn
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

locals {
  joined_files = join("\n", concat([var.userdata_extra_file_string], [
    for fn in var.userdata_files : file(fn)
  ]))

  user_data = base64encode(
  templatestring(local.joined_files, var.userdata_template_variables))
}

resource "aws_instance" "main" {
  key_name             = var.keypair_name
  ami                  = data.aws_ami.ubuntu.image_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.name
  subnet_id            = data.aws_subnet.selected.id
  hibernation          = false
  ebs_optimized        = true
  monitoring           = true

  get_password_data = var.get_password_data
  user_data         = local.user_data

  metadata_options {
    http_tokens   = "required" # Forces use of IMDSv2
    http_endpoint = "enabled"  # Enables metadata endpoint
  }

  tags = {
    Name  = var.instance_name
    Owner = var.owner
    Env   = var.env
  }

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    //reliability: for prod purposes
    delete_on_termination = var.delete_root_disk_on_termination
    encrypted             = true
  }

  vpc_security_group_ids = [
    # aws_security_group.instance_role.id,
    aws_security_group.create_instance.id,
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-utilization-${var.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # in seconds (5 minutes)
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers when CPU usage is above 80% for 10 minutes."
  actions_enabled     = true

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  # alarm_actions = [aws_sns_topic.alerts.arn] # Optional: send alerts to SNS
}

data "aws_route53_zone" "public_zone" {
  count        = var.dns_public_zone_domain != "" ? 1 : 0
  name         = var.dns_public_zone_domain
  private_zone = false
}

resource "aws_route53_record" "public_record" {
  count   = var.dns_public_zone_domain != "" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name    = var.dns_public_subdomain
  type    = "A"
  ttl     = "60"
  records = [aws_instance.main.public_ip]
}

data "aws_route53_zone" "private_zone" {
  count        = var.dns_public_zone_domain != "" ? 1 : 0
  name         = var.dns_public_zone_domain
  private_zone = true
}

resource "aws_route53_record" "private_record" {
  count   = var.dns_public_zone_domain != "" ? 1 : 0
  zone_id = data.aws_route53_zone.private_zone[0].zone_id
  name    = var.dns_public_subdomain
  type    = "A"
  ttl     = "60"
  records = [aws_instance.main.private_ip]
}
