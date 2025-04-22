output "ami_name" {
  value = data.aws_ami.ubuntu.name
}

output "instance_id" {
  value = aws_instance.main.id
}

output "subnet_id" {
  value = data.aws_subnet.selected.id
}

output "public_ip" {
  value = aws_instance.main.public_ip
}

output "private_ip" {
  value = aws_instance.main.private_ip
}

output "password_data" {
  value     = aws_instance.main.password_data
  sensitive = true
}

output "platform" {
  value     = data.aws_ami.ubuntu.platform
  sensitive = true
}
