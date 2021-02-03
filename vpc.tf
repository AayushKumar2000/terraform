provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "vpc_terr" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames="true"
}

resource "aws_subnet" "subnet_terr1" {
  vpc_id     = aws_vpc.vpc_terr.id
  cidr_block = "192.168.1.0/24"
  availability_zone="us-east-1a"
}
resource "aws_subnet" "subnet_terr2" {
  vpc_id     = aws_vpc.vpc_terr.id
  cidr_block = "192.168.2.0/24"
  availability_zone="us-east-1b"
}

resource "aws_internet_gateway" "igw_terr" {
  vpc_id = aws_vpc.vpc_terr.id
  
}
resource "aws_security_group" "security_group_terr" {
    name= "sg_terr"
    description="sg made using terraform"
    vpc_id=aws_vpc.vpc_terr.id
    
    ingress{
      from_port=22
      to_port=22
      protocol="tcp"
      cidr_blocks=["0.0.0.0/0"]
      ipv6_cidr_blocks=["::/0"]
    }
    ingress{
      from_port=80
      to_port=80
      protocol="tcp"
      cidr_blocks=["0.0.0.0/0"]
      ipv6_cidr_blocks=["::/0"]
    }
     
    egress{
      from_port=0
      to_port=0
      protocol="-1"
      cidr_blocks=["0.0.0.0/0"] 
      ipv6_cidr_blocks=["::/0"] 
    }
  
}



resource "aws_instance" "ec2_terr" {
  ami = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"
  key_name="first_cli"
   
  vpc_security_group_ids=[aws_vpc.vpc_terr.default_security_group_id]
  security_groups=[aws_security_group.security_group_terr.id]
  subnet_id=aws_subnet.subnet_terr1.id
  associate_public_ip_address="true"
  depends_on=[aws_internet_gateway.igw_terr]
}


resource "aws_route_table" "rt_terr" {
  vpc_id = aws_vpc.vpc_terr.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_terr.id
  }
}

resource "aws_route_table_association" "rta_terr" {
  subnet_id      = aws_subnet.subnet_terr1.id
  route_table_id = aws_route_table.rt_terr.id
  
}


output "instanceIP" {
 value=aws_instance.ec2_terr.public_ip
}

resource "aws_security_group" "security_group_terr2" {
    name= "sg_terr2"
    description="sg made using terraform for private instance"
    vpc_id=aws_vpc.vpc_terr.id
   
    ingress{
      from_port=22
      to_port=22
      protocol="tcp"
      security_groups=[aws_security_group.security_group_terr.id]
      
    }
     ingress{
      from_port=3306
      to_port=3306
      protocol="tcp"
      security_groups=[aws_security_group.security_group_terr.id]
      
    }
    egress{
      from_port=0
      to_port=0
      protocol="-1"
      cidr_blocks=["0.0.0.0/0"] 
      
    }
  
}


resource "aws_instance" "ec2_terr2" {
  ami = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"
  key_name="first_cli"
   
  vpc_security_group_ids=[aws_vpc.vpc_terr.default_security_group_id]
  security_groups=[aws_security_group.security_group_terr2.id]
  subnet_id=aws_subnet.subnet_terr2.id
  associate_public_ip_address="false"
  
}





resource "aws_eip" "eip_terr" {
  vpc  = true
  depends_on=[aws_internet_gateway.igw_terr]
}

resource "aws_nat_gateway" "ngw_terr" {
  allocation_id = aws_eip.eip_terr.id
  subnet_id     = aws_subnet.subnet_terr1.id

  depends_on = [aws_internet_gateway.igw_terr]
}

resource "aws_route_table" "rt_terr2" {
  vpc_id = aws_vpc.vpc_terr.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_terr.id
  }
}

resource "aws_route_table_association" "rta_terr2" {
  subnet_id      = aws_subnet.subnet_terr2.id
  route_table_id = aws_route_table.rt_terr2.id
  
}