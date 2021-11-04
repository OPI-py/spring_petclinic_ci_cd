
#output "Jenkins-main-public-ip" {
#  value = aws_instance.jenkins-master.public_ip
#}

output "qa-instance-ip" {
  value = aws_instance.qa-instance.public_ip
}

output "docker-instance-ip" {
  value = {
    for instance in aws_instance.docker-instance :
    instance.id => instance.public_ip
  }
}
