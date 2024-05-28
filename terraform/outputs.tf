# outputs.tf

output "alb_hostname" {
  value = aws_alb.main.name
}