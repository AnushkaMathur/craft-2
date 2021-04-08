resource "aws_ami_from_instance" "wordpress-ami" {
  name               = "wordpress"
  source_instance_id = data.aws_instance.wp-instance.id
}


resource "aws_launch_template" "wordpress_launch_template" {
  
  name_prefix            = "wordpress"
  image_id               = aws_ami_from_instance.wordpress-ami.id
  instance_type          = var.type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.wordpress_instance.id]
}


resource "aws_autoscaling_group" "wordpress_asg" {
name = "wordpress-asg"
vpc_zone_identifier = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
max_size         = 3
  min_size         = 1
  desired_capacity = 2
  health_check_type         = "EC2"
 mixed_instances_policy {
 launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.wordpress_launch_template.id
        version            = aws_launch_template.wordpress_launch_template.latest_version
      }
    }
  }
}
