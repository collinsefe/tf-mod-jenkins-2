##################################################################################
# PROVIDERS
##################################################################################
/*

module "vpc" {
  vpc_cidr                        = "${var.vpc_cidr}"
  source                          = "git::https://code.deloittecloud.co.uk/ITS/tf-mod-jenkins.git"
  azs                             = "${var.azs}"
  region                          = "${var.region}"
  vpc_name                        = "${var.vpc_name}"
  vpc_public_subnets              = "${var.vpc_public_subnets}"
  vpc_private_subnets             = "${var.vpc_private_subnets}"
  vpc_instance_tenancy            = "${var.vpc_instance_tenancy}"
  connect_to_transit_vpc          = "${var.connect_to_transit_vpc}"
  set_dhcp_option                 = "${var.set_dhcp_option}"
  active_directory_domain_name    = "${var.active_directory_domain_name}"
  active_directory_dc_private_ips = "${var.active_directory_dc_private_ips}"
}

*/

######################
## PROVIDER
######################

provider "aws" {
  region = "eu-west-1"
}

#########################
## DATA FILES
#########################

data "terraform_remote_state" "vpc_state" {
  backend = "s3"

  config {
    bucket = "${var.tf_s3_bucket_original}"
    region = "${var.region}"
    key    = "${var.vpc_state_file_original}"
  }
}

data "template_file" "ecs_container_def" {
  template = "${file("ecs_container.json")}"
}

data "template_file" "jenkins_server_def" {
  template = "${file("user_data_jenkins_server.sh")}"
}

data "template_file" "ecs_assume_role_policy" {
  template = "${file("ecs_assume_role.json")}"
}

data "template_file" "ec2_assume_role_policy" {
  template = "${file("ec2_assume_role.json")}"
}

data "template_file" "ecs_jenkins_policy" {
  template = "${file("ecs_policy.json")}"
}

data "template_file" "jenkins_task_template" {
  template = "${file("ecs_container.json")}"
}

data "template_file" "instance_profile" {
  template = "${file("instance_profile.json")}"
}

##################################
# Jenkins Master Task Definition
##################################

resource "aws_ecs_task_definition" "jenkins-master" {
  family                = "${var.ecs_task_family}"
  network_mode          = "${var.ecs_task_network_mode}"
  container_definitions = "${data.template_file.jenkins_task_template.rendered}"

  volume {
    name      = "jenkins-home"
    host_path = "/ecs/jenkins-home"
  }
}


resource "aws_ecs_service" "jenkins_ecs_master" {
  name            = "${var.ecs_cluster_name}"
  cluster         = "${aws_ecs_cluster.jenkins.id}"
  task_definition = "${aws_ecs_task_definition.jenkins-master.arn}"
  desired_count   = "${var.desired_service_count}"
  iam_role        = "${aws_iam_role.jenkins_ecs_role.arn}"

  depends_on = [
    "aws_iam_role_policy.jenkins_ecs_policy",
    "aws_alb_listener.jenkins_listener",
  ]

  load_balancer {
    elb_name       = "${aws_elb.jenkins_elb.name}"
    container_name = "${var.ecs_task_family}"
    container_port = "${var.jenkins_web_port}"
  }
}

# ------------
# Auto Scaling
# ------------
data "template_file" "user_data_jenkins_ecs" {
  template = "${file("user_data_jenkins_ecs.sh")}"

  vars {
    ecs_cluster_name     = "${var.ecs_cluster_name}"
    efs_mountpoint       = "${var.ecs_user_data_efs_mountpoint}"
    aws_region           = "${var.region}"
    efs_filesystem_id    = "${aws_efs_file_system.jenkins_efs.id}"
    efs_mountpoint_owner = "${var.ecs_user_data_efs_owner}"
  }
}

resource "aws_alb_target_group" "jenkins_alb_tg" {
  name     = "jenkins-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc_state.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "jenkins_alb" {
  name            = "jenkins-alb"
  subnets         = ["${data.terraform_remote_state.vpc_state.vpc_private_subnet_ids}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_listener" "jenkins_listener" {
  load_balancer_arn = "${aws_alb.jenkins_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins_alb_tg.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "alb_sg" {
  description = "controls access to the application ELB"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"
  name        = "alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

/*
# ------------
# Auto Scaling
# ------------
data "template_file" "user_data_jenkins_ecs" {
  template = "${file("user_data_jenkins_ecs.sh")}"

  vars {
    ecs_cluster_name     = "${var.ecs_cluster_name}-2"
    efs_mountpoint       = "${var.ecs_user_data_efs_mountpoint}"
    aws_region           = "${var.region}"
    efs_filesystem_id    = "${aws_efs_file_system.jenkins_efs.id}"
    efs_mountpoint_owner = "${var.ecs_user_data_efs_owner}"
  }
}
*/

# -------------------
# Jenkins ECS Cluster
# -------------------

resource "aws_ecs_cluster" "jenkins" {
  name = "${var.ecs_cluster_name}"
}


###################################
# JENKINS INSTANCE Security Group
####################################

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Jenkins Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
   ingress {
    from_port   = 50000
    to_port     = 50000
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "jenkins-sg"
  }
}

##########################
# JENKINS EC2 INSTANCE
##########################

resource "aws_instance" "jenkins_server" {
  ami                  = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  subnet_id            = "${var.subnet_id}"
  key_name             = "${var.key_name}"
  source_dest_check    = true
  security_groups      = ["${aws_security_group.jenkins_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_ec2_instance.id}"
  user_data            = "${data.template_file.jenkins_server_def.rendered}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
    file_name   = "${var.key_name}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name                   = "jenkins-server"
    Termination_protection = true
  }
}

# --------------------------
# Jenkins ELB Security Group
# --------------------------
resource "aws_security_group" "jenkins_elb_sg" {
  name        = "jenkins-elb-sg"
  description = "Jenkins ELB Instance Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"

  # Jenkins EXT WEB Ingress Rule
  ingress {
    from_port   = "${var.ext_web_port}"
    to_port     = "${var.ext_web_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Jenkins EXT SSL Ingress Rule
  ingress {
    from_port   = "${var.ext_ssl_port}"
    to_port     = "${var.ext_ssl_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Default Egress Rule
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "jenkins-elb-sg"
    Terraform = "true"
  }
}

########################
#Jenkins ELB
########################
resource "aws_elb" "jenkins_elb" {
  name    = "jenkins-elb"
  subnets = "${var.subnet_ids}"

  #["${data.terraform_remote_state.vpc_state.private_subnet_ids}"]
  security_groups = ["${aws_security_group.jenkins_elb_sg.id}"]

  idle_timeout                = "300"
  connection_draining         = true
  connection_draining_timeout = "300"
  instances                   = ["${aws_instance.jenkins_server.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    instance_port     = "8000"
    instance_protocol = "http"
    lb_port           = "80"
    lb_protocol       = "http"
  }

  listener {
    instance_port     = "8000"
    instance_protocol = "tcp"
    lb_port           = "8080"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "8000"
    instance_protocol = "tcp"
    lb_port           = "443"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    timeout             = "3"
    target              = "HTTP:8000/"
    interval            = "30"
  }

  tags {
    Name = "jenkins-elb"
  }

# ----------------
# ECS Service Role
# ----------------
resource "aws_iam_role" "jenkins_ecs_role" {
  name = "jenkins-ecs-role"

  assume_role_policy = "${data.template_file.ecs_assume_role_policy.rendered}"
}

# -----------------------
# ECS Service Role Policy
# -----------------------
resource "aws_iam_role_policy" "jenkins_ecs_policy" {
  name   = "jenkins-ecs-policy"
  role   = "${aws_iam_role.jenkins_ecs_role.name}"
  policy = "${data.template_file.ecs_jenkins_policy.rendered}"
}

#############################
## ECS INSTANCE PROFILE
#############################
resource "aws_iam_instance_profile" "jenkins_ecs_instance_profile" {
  name = "jenkins-ecs-instance-profile"
  role = "${aws_iam_role.jenkins_ecs_role.id}"
}

# --------
# EC2 Role
# --------
resource "aws_iam_role" "jenkins_ec2_role" {
  name = "jenkins-ec2-role"
  assume_role_policy = "${data.template_file.ec2_assume_role.rendered}"
}

# ---------------
# EC2 Role Policy
# ---------------
resource "aws_iam_role_policy" "jenkins_ec2_policy" {
  name = "jenkins-ec2-policy"
  role = "${aws_iam_role.jenkins_ec2_role.id}"
  policy = "${data.template_file.ec2_policy.rendered}"

# --------------------
# EC2 Instance Profile 
# --------------------
resource "aws_iam_instance_profile" "jenkins_ec2_instance" {
  name = "jenkins-ec2-instance"
  role = "${aws_iam_role.jenkins_ec2_role.name}"
}

# ------------------
# EFS Security Group
# ------------------

resource "aws_security_group" "efs_sg" {
  name        = "${var.customer_name}_efs_sg"
  description = "EFS Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc_state.vpc_id}"

  # Default EFS Ingress Rule
  ingress {
    from_port = "${var.efs_port}"
    to_port   = "${var.efs_port}"
    protocol  = "tcp"
  }

  # Default Egress Rule
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    #vpc_cidr    = "var.vpc_cidr"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "${var.customer_name}_efs_sg"
    Terraform = "true"
  }
}

# --------------
# EFS Filesystem
# --------------
resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "jenkins-efs"

  tags {
    Name      = "jenkins-efs"
    Terraform = "true"
    Project   = "artemis"
    Protected = "false"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------
# EFS Mount targets
# -----------------
resource "aws_efs_mount_target" "efs_mount_target" {
  count               = "${var.subnet_count}"
  file_system_id      = "${aws_efs_file_system.jenkins_efs.id}"
  subnet_id           = "${element(var.subnet_ids, count.index)}"
  security_groups     = ["${aws_security_group.efs_sg.id}"]
}

##########################
#LAUNCH CONFIGURATION
###########################
resource "aws_launch_configuration" "jenkins_lc" {
  name_prefix          = "lc-${var.ecs_cluster_name}-"
  image_id             = "${var.ecs_lc_image_id}"
  instance_type        = "${var.ecs_lc_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_ecs_instance_profile.name}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.jenkins_sg.id}"]

  user_data         = "${data.template_file.user_data_jenkins_ecs.rendered}"
  enable_monitoring = "${var.enable_monitoring}"
  placement_tenancy = "${var.placement_tenancy}"
  ebs_optimized     = "${var.ebs_optimized}"

  #subnet_id             =  ["${var.subnet_ids}"]

  associate_public_ip_address = false
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]
  root_block_device = [
    {
      volume_size           = "50"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]
  lifecycle {
    create_before_destroy = true
  }
}

##########################
# AUTO-SCALING GROUP
###########################

resource "aws_autoscaling_group" "jenkins_asg" {
  name                      = "jenkins-asg"
  launch_configuration      = "${aws_launch_configuration.jenkins_lc.name}"
  availability_zones        = ["${var.availability_zones}"]
  vpc_zone_identifier       = ["${var.vpc_zone_identifier}"]
  health_check_type         = "${var.ecs_asg_health_check_type}"
  min_size                  = "${var.ecs_asg_min_size}"
  max_size                  = "${var.ecs_asg_max_size}"
  desired_capacity          = "${var.ecs_asg_desired_capacity}"
  wait_for_capacity_timeout = "${var.ecs_asg_wait_for_capacity_timeout}"
  load_balancers            = ["${aws_elb.jenkins_elb.id}"]
  target_group_arns         = ["${aws_alb.jenkins_alb.arn}"]

  tags = [
    {
      key                 = "Name"
      value               = "jenkins-slaves"
      propagate_at_launch = true
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}

# -------------------------------
# Jenkins Cluster Scale Up Policy
# -------------------------------

resource "aws_autoscaling_policy" "jenkins_scale_up_policy" {
  name                      = "ecs_jenkins_scale_up_policy"
  adjustment_type           = "${var.scale_up_adjustment_type}"
  autoscaling_group_name    = "${aws_autoscaling_group.jenkins_asg.id}"
  estimated_instance_warmup = "${var.scale_up_estimated_instance_warmup}"
  metric_aggregation_type   = "${var.scale_up_metric_aggregation_type}"
  policy_type               = "${var.scale_up_policy_type}"

  step_adjustment {
    metric_interval_lower_bound = "${var.scale_up_metric_interval_lower_bound}"
    scaling_adjustment          = "${var.scale_up_scaling_adjustment}"
  }
}

# ------------------------------
# Jenkins Cluster Scale Up Alarm
# ------------------------------
resource "aws_cloudwatch_metric_alarm" "jenkins_scale_up_alarm" {
  alarm_name          = "ecs_jenkins_scale_up_alarm"
  alarm_description   = "CPU utilization peaked at 60% during the last minute"
  alarm_actions       = ["${aws_autoscaling_policy.jenkins_scale_up_policy.arn}"]

  dimensions = {
    ClusterName = "${var.ecs_cluster_name}"
  }

  metric_name           = "${var.scale_up_alarm_metric_name}"
  namespace             = "${var.scale_up_alarm_namespace}"
  comparison_operator   = "${var.scale_up_alarm_comparison_operator}"
  statistic             = "${var.scale_up_alarm_statistic}"
  threshold             = "${var.scale_up_alarm_threshold}"
  period                = "${var.scale_up_alarm_period}"
  evaluation_periods    = "${var.scale_up_alarm_evaluation_periods}"
  treat_missing_data    = "${var.scale_up_alarm_treat_missing_data}"
}

# ---------------------------------
# Jenkins Cluster Scale Down Policy
# ---------------------------------
resource "aws_autoscaling_policy" "jenkins_scale_down_policy" {
  name                   = "ecs_jenkins_scale_down_policy"
  adjustment_type        = "${var.scale_down_adjustment_type}"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_asg.id}"
  cooldown               = "${var.scale_down_cooldown}"
  scaling_adjustment     = "${var.scale_down_scaling_adjustment}"
}

# --------------------------------
# Jenkins Cluster Scale Down Alarm
# --------------------------------

resource "aws_cloudwatch_metric_alarm" "jenkins_scale_down_alarm" {
  alarm_name            = "ecs_jenkins_scale_down_alarm"
  alarm_description     = "CPU utilization is under 50% for the last 5 min..."
  alarm_actions         = ["${aws_autoscaling_policy.jenkins_scale_down_policy.arn}"]

  dimensions = {
    ClusterName = "${var.ecs_cluster_name}"
  }

  metric_name           = "${var.scale_down_alarm_metric_name}"
  namespace             = "${var.scale_down_alarm_namespace}"
  comparison_operator   = "${var.scale_down_alarm_comparison_operator}"
  statistic             = "${var.scale_down_alarm_statistic}"
  threshold             = "${var.scale_down_alarm_threshold}"
  period                = "${var.scale_down_alarm_period}"
  evaluation_periods    = "${var.scale_down_alarm_evaluation_periods}"
  treat_missing_data    = "${var.scale_down_alarm_treat_missing_data}"
}
