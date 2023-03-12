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

output "aws_region" {
  value = data.aws_region.current.name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
