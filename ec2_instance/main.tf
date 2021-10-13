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
  cidr_blocks       = [aws_vpc.dev-vpc.cidr_block]
  security_group_id = aws_security_group.dev-ssh-sg.id
  depends_on = [ aws_security_group.dev-ssh-sg ]
}



resource "aws_instance" "dev-bastion" {
  ami           = lookup(var.amis, var.aws_region)
  instance_type = "t2.micro"
  
  tags = {
    Name = "dev-bastion"
  }
}


# resource "aws_instance" "dev-freeinstance" {
#   ami           = lookup(var.amis, var.aws_region)
#   instance_type = "t2.micro"
#   tags = {
#     Name = "dev-freeinstancer"
#     terraform = "true"
#   }
# }