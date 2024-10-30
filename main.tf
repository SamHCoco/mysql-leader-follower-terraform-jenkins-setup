# Provider configuration
provider "aws" {
  region = "eu-west-2"
}

# Create a default VPC if one doesn't exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Get all availability zones in the region
data "aws_availability_zones" "available_zones" {}

# Create a default subnet if one doesn't exist
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# Create security group for MySQL instances
resource "aws_security_group" "mysql_security_group" {
  name        = "mysql security group"
  description = "allow MySQL and SSH access"
  vpc_id      = aws_default_vpc.default_vpc.id

  # Allow MySQL access (port 3306) from specific CIDR blocks if necessary
  ingress {
    description = "MySQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify to restrict access as needed
  }

  # Allow SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify for added security in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL Replication Security Group"
  }
}

# Define the MySQL Master EC2 instance
resource "aws_instance" "mysql_masterdb" {
  ami                    = "ami-0acc77abdfc7ed5a6"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.mysql_security_group.id]
  key_name               = "ec2-key"

  tags = {
    Name = "MySQLMaster"
  }
}

# Define the MySQL Slave EC2 instance
resource "aws_instance" "mysql_slavedb" {
  ami                    = "ami-0acc77abdfc7ed5a6"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.mysql_security_group.id]
  key_name               = "ec2-key"

  tags = {
    Name = "MySQLSlave"
  }
}

# Outputs for the public IPs of the MySQL instances, for use in Ansible inventory
output "master_ip" {
  description = "Public IP of the MySQL Master instance"
  value       = aws_instance.mysql_masterdb.public_ip
}

output "slave_ip" {
  description = "Public IP of the MySQL Slave instance"
  value       = aws_instance.mysql_slavedb.public_ip
}
