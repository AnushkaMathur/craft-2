resource "aws_instance" "wp-instance" {
  ami           = var.ami
  instance_type =  var.type
  vpc_security_group_ids = [aws_security_group.wordpress_instance.id]
  key_name  = var.key
  user_data =  file("userdata.sh")
  subnet_id = aws_subnet.public_subnet1.id
  tags = {
    env = "wordpress"
  }
  
}

output "wp_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.wp-instance.public_ip
}

resource "null_resource" "shell" {
  provisioner "local-exec" {
  command = "echo  ${aws_instance.wp-instance.public_ip} ansible_user=ubuntu >> hosts"
    }
    }

data "aws_instance" "wp-instance" {

  filter {
    name   = "tag:env"
    values = ["wordpress"]
  }

}

