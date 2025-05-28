output "baston-public-ip" {
  value = module.bastion.bastion_public_ip
}

output "nexus-public-ip" {
  value = module.nexus.nexus_ip
}

output "nexus-private-ip" {
  value = module.nexus.nexus_private_ip
}

output "ansible-server-ip" {
  value = module.ansible.ansible_ip
}

output "sonarqube-server-ip" {
  value = module.sonarqube.sonarqube-ip
}

output "DB-endpoint" {
  value = module.database.db_endpoint
}