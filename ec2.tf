resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.minecraft_traffic.id]
  key_name                    = aws_key_pair.minecraft_key.key_name

  user_data = file("${path.module}/scripts/user_data.sh")

  tags = merge(local.common_tags, {
    Name = "minecraft-server"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}