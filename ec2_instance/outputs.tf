output "bastion-public-ip" {
    value = aws_instance.dev-bastion.public_ip
}