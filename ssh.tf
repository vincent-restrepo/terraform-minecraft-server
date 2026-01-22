resource "tls_private_key" "minecraft_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-server-key"
  public_key = tls_private_key.minecraft_ssh.public_key_openssh

  tags = merge(local.common_tags, {
    Name = "Minecraft Server Key"
  })
}

resource "local_file" "private_key" {
  content         = tls_private_key.minecraft_ssh.private_key_pem
  filename        = "${path.module}/minecraft-server-key.pem"
  file_permission = "0400"
}
