#security group for linux instances
resource "aws_security_group" "sg_ssh" {
  name = "SSH_Security_Group"

  ingress {
    cidr_blocks = ["208.127.94.133/32","208.127.93.165/32","66.37.42.10/32","66.37.42.11/32","208.127.190.40/32","134.238.168.126/32","208.127.83.50/32","208.127.70.67/32","208.127.93.164/32"]
    description = "Public IPs for SSH access"
    from_port = 22
    protocol = "tcp"
    to_port = 22
  } 

  ingress {
    description = "flat access on local subnet"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["172.31.0.0/16"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


#security group for Windows Instances
resource "aws_security_group" "sg_rdp" {
  name = "RDP_Security_Group"

    ingress {
    cidr_blocks = ["208.127.94.133/32","208.127.93.165/32","66.37.42.10/32","66.37.42.11/32","208.127.190.40/32","134.238.168.126/32","208.127.83.50/32","208.127.70.67/32","208.127.93.164/32"]
    description = "Public IPs for RDP access"
    from_port = 3389
    protocol = "tcp"
    to_port = 3389
  } 

  ingress {
    description = "flat access on local subnet"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["172.31.0.0/16"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


#dc
resource "aws_instance" "dc01" {
  ami = "ami-0ca58e4cb9e83244e"
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.sg_rdp.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.poc_key_pair.key_name
  private_ip = "172.31.16.10"
  subnet_id = var.poc_private_subnet

  tags = {
    Name = "dc01"
  }
}

#win connector
resource "aws_instance" "win-conn01" {
  ami = "ami-0ca58e4cb9e83244e"
  instance_type = "c4.2xlarge"
  vpc_security_group_ids = [aws_security_group.sg_rdp.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.poc_key_pair.key_name
  private_ip = "172.31.0.15"
  subnet_id = var.poc_public_subnet

  tags = {
    Name = "win-conn01"
  }
}

#win tgt
resource "aws_instance" "win-tgt01" {
  ami = "ami-0ca58e4cb9e83244e"
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.sg_rdp.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.poc_key_pair.key_name
  private_ip = "172.31.16.20"
  subnet_id = var.poc_private_subnet

  tags = {
    Name = "win-tgt01"
    dpa = "dev"
  }
}

#lin connector
resource "aws_instance" "lin-conn01" {
  ami = "ami-02f97949d306b597a"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.poc_key_pair.key_name
  private_ip = "172.31.0.25"
  subnet_id = var.poc_public_subnet

  tags = {
    Name = "lin-conn01"
  }
}

#lin target
resource "aws_instance" "lin-tgt01" {
  ami = "ami-02f97949d306b597a"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.poc_key_pair.key_name
  private_ip = "172.31.16.30"
  subnet_id = var.poc_private_subnet

  tags = {
    Name = "lin-tgt01"
    dpa = "dev"
  }
}
