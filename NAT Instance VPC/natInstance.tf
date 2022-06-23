resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "Internet-Gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.default.id
  cidr_block = var.public_Subnet_Cidr_Block

  tags = {
    Name = var.public_Subnet_Name
  }
}

resource "aws_route_table" "public_To_Internet" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "Route-To-internet"
  }

  depends_on = [
    aws_instance.nat_Instance
  ]
}

resource "aws_route_table_association" "main_Public_Route" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_To_Internet.id
}

resource "aws_security_group" "nat" {
  name        = "nat-instance-sg"
  description = "Default NAT instance SG"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "Port 22 opened"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all traffic from private subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_Instance" {
  ami                         = var.nat_Instance_Ami
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  private_ip                  = var.nat_Instance_Private_Ip
  source_dest_check           = false
  subnet_id                   = aws_subnet.public.id
  user_data                   = <<EOF
   #!/bin/bash
    sudo yum update -y
    sudo yum install ec2-instance-connect -y
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -j MASQUERADE
  EOF

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = var.nat_Instance_Name
  }

  depends_on = [
    aws_subnet.public
  ]
}


resource "aws_network_interface_sg_attachment" "to_Public_Instance" {
  security_group_id    = aws_security_group.nat.id
  network_interface_id = aws_instance.nat_Instance.primary_network_interface_id
}

