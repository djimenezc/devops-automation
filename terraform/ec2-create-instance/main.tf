provider "aws" {
  profile = "default"
  region  = var.aws_region
  assume_role {
    # This is a variable based on the AWS account
    role_arn     = var.jenkins_role_arn
    session_name = "terraform"
  }
}

data "aws_vpc" "main" {
  tags = {
    Name                     = var.vpc_name
  }
}

resource "aws_security_group" "instance_role" {
  name_prefix = "${var.instance_name}_"
  description = "${var.instance_name} role"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}.security_group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami_ids" "ubuntu_arm" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20220604"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
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
  name        = "image_builder_aws_cli"
  path        = "/"
  description = "Policy to build images and manage ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*"
        ]
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

resource "aws_iam_role_policy_attachment" "test-attach" {
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
    values = ["devVPC-private-1b"]
  }
}

resource "aws_instance" "main" {
  key_name             = var.keypair_name
  ami                  = one(data.aws_ami_ids.ubuntu_arm.ids)
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.name
  subnet_id            = data.aws_subnet.selected.id
  hibernation          = false

  user_data = filebase64("provision.sh")

  tags = {
    Name = var.instance_name
    Owner = var.owner
  }

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    //reliability: for prod purposes
    delete_on_termination = var.delete_root_disk_on_termination
    encrypted             = true
  }

  vpc_security_group_ids = [
    aws_security_group.instance_role.id
  ]

}
