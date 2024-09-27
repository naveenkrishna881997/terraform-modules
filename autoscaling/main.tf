data "aws_availability_zones" "all" {}


resource "aws_launch_template" "demo" {
  count = var.create_launch_template ? 1 : 0

  name        = var.launch_template_name
  image_id      = var.image_id
  key_name      = var.key_name
  user_data     = var.user_data

  vpc_security_group_ids = var.security_groups
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  #availability_zones = data.aws_availability_zones.all.names
  vpc_zone_identifier = var.vpc_zone_identifier
  load_balancers = var.load_balancers
  max_size           = var.max_size
  min_size           = var.min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete          = var.force_delete

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 100
  }

   initial_lifecycle_hook {
    name                 = "demo"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 60
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_metadata = jsonencode({ "hello" = "world" })
  }

  launch_template {
    id      = aws_launch_template.demo[0].id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "demo" {
  name                   = "test_scale_down"
  autoscaling_group_name = aws_autoscaling_group.demo.name
  adjustment_type        = "ChangeInCapacity"
  #cooldown = 300
  policy_type            = "TargetTrackingScaling"
   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

