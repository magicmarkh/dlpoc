# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "poc_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "poc_key_pair" {
  key_name   = "aws-poc-key-pair"  
  public_key = tls_private_key.poc_key_pair.public_key_openssh
}
# Save file
resource "local_file" "aws_poc_ssh_key" {
  filename = "${aws_key_pair.poc_key_pair.key_name}.pem"
  content  = tls_private_key.poc_key_pair.private_key_pem
}