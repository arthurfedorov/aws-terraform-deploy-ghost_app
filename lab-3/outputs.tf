output "load_balancer_dns_name" {
  value = aws_lb.alb.dns_name
}

output "bastion_public_ip_address" {
  value = aws_instance.bastion.public_ip
}

output "bastion_dns_name" {
  value = aws_instance.bastion.public_dns
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

output "database_url" {
  value = aws_db_instance.ghost.address
}
