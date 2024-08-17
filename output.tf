output "name" {
  value = data.aws_subnets.public.ids
}

output "private_subnet_id" {
  value = data.aws_subnets.private.ids
}

output "lb_dns_name" {

  value = aws_lb.prod.dns_name
}