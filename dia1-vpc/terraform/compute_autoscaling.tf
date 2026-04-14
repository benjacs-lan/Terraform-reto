resource "aws_launch_template" "web_templates" {
  name_prefix   = "aws-realworld-lab-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.public_web.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>App from AutoScaling</h1>" > /usr/share/nginx/html/index.html
  EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  name_prefix         = "aws-realworld-lab-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.web_templates.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "aws-realworld-lab-asg-instance"
    propagate_at_launch = true
  }
}
