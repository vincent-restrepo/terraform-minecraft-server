output "minecraft_server_ip" {
  description = "Public IP address of the Minecraft server"
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_connection" {
  description = "Minecraft server connection details"
  value       = "Connect to: ${aws_instance.minecraft.public_ip}:25565"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i minecraft-server-key.pem ubuntu@${aws_instance.minecraft.public_ip}"
}

output "ssh_key_location" {
  description = "Location of the SSH private key"
  value       = "minecraft-server-key.pem"
}
