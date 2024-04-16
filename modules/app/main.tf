resource "aws_security_group" "demoapp_sg" {
  name   = "demoapp-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow http from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demoapp-sg"
  }
}

resource "aws_lb" "demoapp_alb" {
  name               = "demoapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demoapp_sg.id]
  subnets            = [var.public_subnet_az1_id, var.public_subnet_az2_id]
}

resource "aws_lb_listener" "demoapp_lb_listener" {
  load_balancer_arn = aws_lb.demoapp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demoapp_tg.arn
  }
}

resource "aws_lb_target_group" "demoapp_tg" {
  name        = "demoapp-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_launch_template" "demoapp_launch_template" {

  name = "demoapp_launch_template"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #key_name      = "carlcauchi-key"

  user_data = filebase64("${path.module}/server.sh")

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.demoapp_sg.id]
  }
}

resource "aws_autoscaling_group" "demoapp_asg" {
  name              = "demoapp_asg"
  max_size          = 3
  min_size          = 2
  health_check_type = "ELB"
  desired_capacity  = 2
  target_group_arns = [aws_lb_target_group.demoapp_tg.arn]

  vpc_zone_identifier = [var.private_subnet_az1_id, var.private_subnet_az2_id]

  launch_template {
    id      = aws_launch_template.demoapp_launch_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.demoapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"   # add one instance
  cooldown               = "300" # cooldown period after scaling
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.demoapp_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.demoapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.demoapp_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}