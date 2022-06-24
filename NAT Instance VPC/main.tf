resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags = {
    date = timestamp()
    Name = var.vpc_Name
  }
}

resource "aws_network_acl" "main_Acl" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port  = 22
    to_port    = 22
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = var.ec2_Connect_Ip_Range
  }

  ingress {
    from_port  = 22
    to_port    = 22
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = var.my_Ip
  }

  ingress {
    from_port  = 443
    to_port    = 443
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 80
    to_port    = 80
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Main network ACL"
  }
}

resource "aws_security_group" "main" {
  name        = "main-instance-sg"
  description = "Default main SG"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.default.id
  cidr_block = var.private_Subnet_Cidr_Block

  tags = {
    Name = var.private_Subnet_Name
  }
}

resource "aws_network_acl_association" "main" {
  network_acl_id = aws_network_acl.main_Acl.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table" "private_To_Internet" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_Instance.primary_network_interface_id
  }

  tags = {
    Name = var.private_To_Internet_Route_Table_Name_Tag
  }

  depends_on = [
    aws_instance.nat_Instance
  ]
}

resource "aws_route_table_association" "main_Private_Route" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_To_Internet.id
}

resource "aws_instance" "test_Instance" {
  ami                         = var.private_Subnet_Vm_Ami
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  user_data                   = <<EOF
   #!/bin/bash
    sleep 360
    sudo yum update -y
  EOF

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = var.private_Subnet_Vm_Name
  }

  depends_on = [
    aws_subnet.private,
  ]
}

resource "aws_network_interface_sg_attachment" "to_Private_Instance" {
  security_group_id    = aws_security_group.main.id
  network_interface_id = aws_instance.test_Instance.primary_network_interface_id
}