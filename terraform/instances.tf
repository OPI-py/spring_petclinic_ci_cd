#Get Linux AMI ID using SSM Parameter endpoint
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2 instance
resource "aws_key_pair" "master-key" {
  provider   = aws.region
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create EC2 instance
#resource "aws_instance" "jenkins-master" {
#  provider                    = aws.region
#  ami                         = data.aws_ssm_parameter.linuxAmi.value
#  instance_type               = var.instance-type
#  key_name                    = aws_key_pair.master-key.key_name
#  associate_public_ip_address = true
#  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
#  subnet_id                   = aws_subnet.subnet_1.id

#  tags = {
#    Name = "tf-jenkins-master"
#  }

#  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

#  provisioner "local-exec" {
#    command = <<EOF
#  aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region} \
#--instance-ids ${self.id} && ansible-playbook --extra-vars \
#'our_hosts=${self.public_ip}' ansible_templates/jenkins-master.yaml
#  EOF
#  }

#}

#Create EC2 workers instance
resource "aws_instance" "qa-instance" {
  provider                    = aws.region
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-workers.id]
  subnet_id                   = aws_subnet.subnet_2.id

  tags = {
    Name = "qa-instance"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region} \
--instance-ids ${self.id} && ansible-playbook --extra-vars \
'our_hosts=${self.public_ip}' ansible_templates/qa-instance.yaml
EOF
  }
}

#Create EC2 docker workers instance
resource "aws_instance" "docker-instance" {
  provider                    = aws.region
  count                       = var.instance_count
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-workers.id]
  subnet_id                   = aws_subnet.subnet_2.id

  tags = {
    Name = join("_", ["docker-instance", count.index + 1])
  }

  #depends_on = [aws_main_route_table_association.set-master-default-rt-assoc, aws_instance.jenkins-master]
  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region} \
--instance-ids ${self.id} && ansible-playbook --extra-vars \
'our_hosts=${self.public_ip}' ansible_templates/docker-instance.yaml
EOF
  }
}
