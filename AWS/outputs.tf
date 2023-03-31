output "windows_connector_public_ip" {
  value = aws_instance.win-conn01.public_ip
}


output "linux_connector_public_ip" {
  value = aws_instance.lin-conn01.public_ip
}
