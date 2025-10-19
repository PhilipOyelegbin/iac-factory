output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "web_server_public_dns" {
  description = "Public DNS of the web server"
  value       = aws_instance.web.public_dns
}

output "app_server_private_ip" {
  description = "Private IP address of the app server"
  value       = aws_instance.app.private_ip
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "database_username" {
  description = "Database username"
  value       = var.db_username
  sensitive   = true
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to web server"
  value       = "ssh -i id_rsa ubuntu@${aws_instance.web.public_ip}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web.public_ip}"
}

output "environment_summary" {
  description = "Summary of the deployed environment"
  value       = <<EOT
  Environment: ${var.environment_id}
  Web Server: ${aws_instance.web.public_ip} (SSH: ssh -i id_rsa ubuntu@${aws_instance.web.public_ip})
  App Server: ${aws_instance.app.private_ip} (Private subnet with NAT Gateway: ${aws_eip.nat.public_ip})
  Database: ${aws_db_instance.postgres.endpoint}
  NAT Gateway: ${aws_eip.nat.public_ip} ✅ Enabled
  Access URL: http://${aws_instance.web.public_ip}
  EOT
}