output "sonarqube-ip" {
  value = aws_instance.sonarqube-server.public_ip
}