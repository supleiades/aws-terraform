# Required plugin
# https://marketplace.visualstudio.com/items?itemName=KyleDavidE.vscode-project-links

# instance: project://ec2_instance/main.tf#92

resource "aws_vpc" "dev-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev-pub-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1d"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-pub-subnet"
  }
}

resource "aws_subnet" "dev-pri-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "dev-pri-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dev-pri-subnet.id
  route_table_id = aws_route_table.dev-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.dev-pub-subnet.id
  route_table_id = aws_route_table.dev-rt.id
}
resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-rt"
  }
}

resource "aws_route" "dev-r" {
  route_table_id         = aws_route_table.dev-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev-gw.id
  depends_on             = [aws_route_table.dev-rt]
}


resource "aws_security_group" "dev-ssh-sg" {
  name        = "dev-ssh-sg"
  description = "access ssh"
  vpc_id      = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-ssh-sg"
  }
}

resource "aws_security_group_rule" "dev-ssh-sg-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [
    aws_vpc.dev-vpc.cidr_block,
    var.private-ip
  ]
  security_group_id = aws_security_group.dev-ssh-sg.id
  depends_on        = [aws_security_group.dev-ssh-sg]
}

resource "aws_key_pair" "dev-key" {
  key_name   = "dev-key"
  public_key = file(var.key_pair_filepath)

}
resource "aws_network_interface" "dev-eni" {
  subnet_id   = aws_subnet.dev-pub-subnet.id
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dev-bastion" {
  ami           = lookup(var.amis, var.aws_region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.dev-key.id
  network_interface {
    network_interface_id = aws_network_interface.dev-eni.id

    device_index         = 0
  }
  tags = {
    Name = "dev-bastion"
  }
}

resource "aws_network_interface_sg_attachment" "dev-sg-attach" {
  security_group_id    = aws_security_group.dev-ssh-sg.id
  network_interface_id = aws_network_interface.dev-eni.id
}


# resource "aws_instance" "dev-freeinstance" {
#   ami           = lookup(var.amis, var.aws_region)
#   instance_type = "t2.micro"
#   tags = {
#     Name = "dev-freeinstancer"
#     terraform = "true"
#   }
# }