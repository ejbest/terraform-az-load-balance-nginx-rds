resource "aws_launch_template" "EJB_asg_template" {
  name                   = "EJB_asg_template"
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.EJB-web-app.id]
  user_data              = base64encode(data.template_file.user_data.rendered)
  key_name               = aws_key_pair.EJB_generated.key_name

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.EJB_private_key_pem.filename}"
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "EJB-ubuntu-server"
      Owner       = local.team
      App         = local.application
      project_tag = local.project_tag
    }
  }
}

resource "aws_autoscaling_group" "EJB_asg" {
  depends_on        = [aws_launch_template.EJB_asg_template]
  name_prefix       = "EJB-"
  desired_capacity  = 1
  min_size          = 1
  max_size          = 5
  health_check_type = "EC2"
  load_balancers    = [aws_elb.EJB-elb.id]
  #load_balancers            = ["${aws_elb.elb.id}"]
  launch_template {
    id      = aws_launch_template.EJB_asg_template.id
    version = "$Latest"
  }
  #launch_configuration      = aws_launch_template.asg_template.name
  vpc_zone_identifier = local.ec2_subnet_list
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "EJB_up" {
  name                   = "EJB_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.EJB_asg.name
  #autoscaling_group_name    = "${aws_autoscaling_group.asg.name}"
}


resource "aws_cloudwatch_metric_alarm" "EJB_cpu_alarm_up" {
  alarm_name          = "EJB_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "65"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.EJB_asg.name
    #AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.EJB_up.arn]
  #alarm_actions = [ "${aws_autoscaling_policy.up.arn}" ]
}

resource "aws_autoscaling_policy" "EJB_down" {
  name                   = "EJB-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.EJB_asg.name
  #autoscaling_group_name    = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "EJB_cpu_alarm_down" {
  alarm_name          = "EJB_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.EJB_asg.name
    #AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.EJB_down.arn]
  #alarm_actions = [ "${aws_autoscaling_policy.down.arn}" ]
}

data "aws_instances" "EJB_ec2_instances" {
  depends_on           = [aws_autoscaling_group.EJB_asg]
  instance_state_names = ["running", "pending"]
  instance_tags = {
    Name = "EJB-ubuntu-server"
  }

}
