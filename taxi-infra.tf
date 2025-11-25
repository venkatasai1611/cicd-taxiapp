provider "aws" {
  region = "ap-southeast-2"
}
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "ansible" {
    ami                     = "ami-01e2093820bf84df1"
    instance_type           = "t2.micro"
    key_name                = "taxi"
    vpc_security_group_ids  = [aws_security_group.demo-sg.id]
    //subnet_id               = "subnet-077471d3c705ea769"
    tags                    = {
        Name      = "ansible"
    }
}
    


resource "aws_instance" "jenkins_master" {
  ami                        = "ami-01e2093820bf84df1"
  instance_type              = "t2.medium"
  key_name                   = "taxi"
  vpc_security_group_ids     = [aws_security_group.demo-sg.id]
  
  tags                       = {
    Name = "jenkins-master"
  }
  

}

resource "aws_instance" "jenkins_slave" {
  ami                        = "ami-01e2093820bf84df1"
  instance_type              = "t2.medium"
  key_name                   = "taxi"
  vpc_security_group_ids     = [aws_security_group.demo-sg.id]
  
  tags                       = {
    Name = "jenkins-slave"
  }
  
}


resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"

  
  ingress {
    description      = "SHH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "Container  port"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "https  port"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "http  port"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"

  }
}

module "sgs" {
  source = "./sg_eks"
  vpc_id = data.aws_vpc.default.id
}

# EKS Cluster Module
module "eks" {
  source     = "../eks"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
  sg_ids     = module.sgs.security_group_public
}


output "eks_cluster_endpoint" {
  value = module.eks.endpoint
}
