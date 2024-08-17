output "name" {
  value = data.aws_subnets.public.ids
}

output "private_subnet_id" {
  value = data.aws_subnets.private.ids
}