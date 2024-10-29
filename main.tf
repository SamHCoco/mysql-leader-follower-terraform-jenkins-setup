provider "aws" {
  region  = "eu-west-2"
}

resource "aws_instance" "mysql_masterdb" {
  ami           = "ami-0acc77abdfc7ed5a6"
  instance_type = "t2.micro"
  tags = {
    Name = "MySQLMaster"
  }
}

resource "aws_instance" "mysql_slavedb" {
  ami           = "ami-0acc77abdfc7ed5a6"
  instance_type = "t2.micro"
  tags = {
    Name = "MySQLSlave"
  }
}

output "master_ip" {
  value = aws_instance.mysql_masterdb.public_ip
}

output "slave_ip" {
  value = aws_instance.mysql_slavedb.public_ip
}
