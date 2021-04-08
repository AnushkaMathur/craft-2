
resource "aws_security_group_rule" "wordpress-instance-from-load-balancer" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_group_id = aws_security_group.wordpress_instance.id
  source_security_group_id = aws_security_group.wordpress_elb.id
}

resource "aws_security_group_rule" "wordpress-load-balancer-to-instance" {
type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
security_group_id        = aws_security_group.wordpress_elb.id
  source_security_group_id = aws_security_group.wordpress_instance.id
}

resource "aws_lb" "wordpress" {
 
name = "wordpress-alb"
load_balancer_type = "application"
security_groups = [aws_security_group.wordpress_elb.id]
  subnets         = [aws_subnet.public_subnet1.id , aws_subnet.public_subnet2.id ]


}


resource "aws_lb_target_group" "wp-tg" {
  name     = "wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wp_vpc.id

  
}

resource "aws_autoscaling_attachment" "asg_attachment_wp" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  alb_target_group_arn   = aws_lb_target_group.wp-tg.arn
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp-tg.arn
  }
}


resource "aws_security_group" "wordpress_elb" {
  name        = "wordpress-elb-sg"
  description = "Allow http/s traffic from the internet and forward to wordpress instance"
  vpc_id      = aws_vpc.wp_vpc.id
ingress {
     from_port       = 80
     to_port         = 80
     protocol        = "tcp"
     cidr_blocks = ["0.0.0.0/0"] ## whole internet
  }

}
