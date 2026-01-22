locals {
  common_tags = {
    Name      = "minecraft-server"
    ManagedBy = "Terraform"
    Project   = "minecraft-server"
  }
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = merge(local.common_tags, {
    Name = "minecraft-public-subnet"
    }
  )
}

resource "aws_internet_gateway" "minecraft_igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "minecraft-igw"
    }
  )
}

resource "aws_route_table" "minecraft_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "minecraft-route-table"
    }
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.minecraft_rtb.id
}

resource "aws_security_group" "minecraft_traffic" {
  name        = "allow-minecraft-traffic"
  description = "SG allowing traffic on port 25565 for Minecraft"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "Minecraft Server SG"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_minecraft" {
  security_group_id = aws_security_group.minecraft_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 25565
  ip_protocol       = "tcp"
  to_port           = 25565
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.minecraft_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Egress Rule - Important for updates and server functionality
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.minecraft_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
