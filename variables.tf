########################
#DATA FILES
########################
variable "security_group_id" {
  default = ""

  #${aws_security_group.jenkins_sg.id}"
}

variable "create_lc" {
  description = "Whether to create launch configuration"
  default     = true
}

variable "create_asg" {
  description = "Whether to create autoscaling group"
  default     = true
}

variable "lc_name" {
  description = "Creates a unique name for launch configuration beginning with the specified prefix"
  default     = "ecs_lc"
}

variable "asg_name" {
  description = "Creates a unique name for autoscaling group beginning with the specified prefix"
  default     = "jenkins-asg"
}

variable "launch_configuration" {
  description = "The name of the launch configuration to use (if it is created outside of this module)"
  default     = "jenkins-lc"
}

# Launch configuration
variable "image_id" {
  description = "The EC2 image ID to launch"
  default     = "ami-4cbe0935"
}

variable "instance_type" {
  description = "The size of instance to launch"
  default     = "t2.micro"
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with launched instances"
  default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  default     = "jenkinskey"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the launch configuration"
  type        = "list"
  default     = []

  #"${aws_security_group.jenkins_sg.id}", "${aws_security_group.efs_sg.id}"]
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring. This is enabled by default."
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance"
  type        = "list"
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = "list"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as 'Instance Store') volumes on the instance"
  type        = "list"
  default     = []
}

variable "spot_price" {
  description = "The price to use for reserving spot instances"
  default     = 0
}

variable "placement_tenancy" {
  description = "The tenancy of the instance. Valid values are 'default' or 'dedicated'"
  default     = "default"
}

#########################
#VARAIABLES
#########################
variable "tf_s3_bucket" {
  default = "tf-state-dcuk074-jenkins-dev"
}

variable "jenkins_lc" {
  default = ""
}

variable "jenkins_state_file" {
  default = "tf_jenkins.tfstate"
}

variable "region" {
  default = "eu-west-1"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "subnet_id" {
  default = "subnet-94d288dd"
}

variable "efs_filesystem_id" {
  default = ""
}

variable "subnet" {
  default = "subnet-94d288dd"
}

variable "elb_subnets" {
  default = ["subnet-94d288dd", "subnet-b3f06ce8"]
}

variable "subnets" {
  default = ["subnet-94d288dd", "subnet-b3f06ce8"]
}

variable "ami_id" {
  default = "ami-4cbe0935"
}

#############
# EFS
###############

variable "efs_security_group" {
  default = ""

  #${aws_security_group.efs_sg.id}"
}

variable "security_group" {
  default = ""
}

variable "private_key_path" {
  default = "/Users/corighose/Documents/aws/"
}

variable "efs_port" {
  description = "Default port for EFS"
  default     = "2049"
}

variable "subnet_count" {
  description = "Number of subnets used to deploy EFS"
  default     = "2"
}

variable "subnet_ids" {
  default = ["subnet-94d288dd", "subnet-b3f06ce8"]
}

variable "environment" {
  description = "The programming environment - poc, dev, uat, prod, etc."
  default     = "dev"
}

variable "customer_name" {
  description = "The customer unique name"
  default     = "artemis"
}

variable "tf_s3_bucket_original" {
  default = "tf-state-dcuk074-deloittecloud-co-uk"
}

variable "vpc_state_file_original" {
  default = "tf_vpc.tfstate"
}

variable "vpc_id" {
  default = "vpc-5194b536"
}

variable "name" {
  description = "description of the resources"
  default     = "jenkins"
}

# Jenkins
variable "jenkins_web_port" {
  description = "Default port for Jenkins web services"
  default     = "8080"
}

variable "jenkins_jnlp_port" {
  description = "Default port for Jenkins JNLP slave agents"
  default     = "50000"
}

variable "jenkins_ext_web_port" {
  description = "Default external port for Jenkins web services"
  default     = "80"
}

variable "jenkins_ext_ssl_port" {
  description = "Default SSL port for Jenkins web services"
  default     = "443"
}

variable "jenkins_sg" {
  description = "Jenkins security group"
  default     = ""

  #${aws_security_group.jenkins_sg.id}"
}

variable "efs_sg" {
  default = ""

  #  "${aws_security_group.efs_sg.id}"
}

# Jenkins ELB

variable "elb_security_groups" {
  description = "ELB Security Group"
  type        = "list"
  default     = []

  #["${aws_security_group.jenkins_sg.id}", "${aws_security_group.efs_sg.id}"]
}

variable "elb_internal" {
  description = "State whether the ELB is internal or public facing"
  default     = "false"
}

variable "int_web_port" {
  description = "ELB port assigned for internal WEB communication"
  default     = "80"
}

variable "ext_web_port" {
  description = "ELB port assigned for external WEB communication"
  default     = "80"
}

variable "ext_ssl_port" {
  description = "ELB port assigned for external SSL communication"
  default     = "22"
}

variable "int_ssl_port" {
  description = "ELB port assigned for external SSL communication"
  default     = "22"
}

variable "ssl_certificate_id" {
  description = "The ARN of an SSL certificate you have uploaded to AWS IAM"
  default     = ""
}

variable "elb_health_target" {
  description = "Target for checks"
  default     = "HTTP:8080/login"
}

variable "elb_health_interval" {
  description = "Interval for Health Checks"
  default     = "20"
}

variable "elb_health_healthy_threshold" {
  description = "healthy threshold"
  default     = "3"
}

variable "elb_health_unhealthy_threshold" {
  description = "unhealthy threshold"
  default     = "10"
}

variable "elb_health_timeout" {
  description = "health timeout"
  default     = "2"
}

variable "elb_cookie_expiration_period" {
  default = "3600"
}

variable "jenkins_elb" {
  description = "ELB for Jenkins service"
  default     = ""

  #"${aws_elb.jenkins_elb.id}"
}

variable "jenkins_elb_cookie_expiration_period" {
  description = "The time period after which the Jenkins session cookie should be considered stale, expressed in seconds."
  default     = "3000"
}

# ASG

variable "max_size" {
  description = "The maximum size of the auto scale group"
  default     = "5"
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
  default     = "1"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default     = "1"
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
  default     = ["subnet-94d288dd", "subnet-b3f06ce8"]

  #["${split(",",var.subnet_ids)}"]
}

# ECS
variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  default     = "jenkins"
}

variable "desired_service_count" {
  default     = 1
  description = "Desired number of ECS services."
}

variable "ecs_task_family" {
  description = "A unique name for your task definition"
  default     = "jenkins-master"
}

variable "ecs_task_image" {
  description = "The specified Docker image to use"
  default     = "jenkinsci/jnlp-slave"
}

variable "ecs_task_network_mode" {
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, and host"
  default     = "bridge"
}

variable "ecs_task_volume_name" {
  description = "The name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section"
  default     = "jenkins-home"

  #data-volume
}

variable "ecs_task_volume_host_path" {
  description = "The path on the host container instance that is presented to the container. If not set, ECS will create a nonpersistent data volume that starts empty and is deleted after the task has finished"
  default     = "/data/"
}

variable "ecs_task_container_path" {
  description = "The path on the container that is presented to the host container instance"
  default     = "/var/jenkins-home"
}

variable "ecs_user_data_efs_mountpoint" {
  description = "EFS mount point on the ECS instance"
  default     = "data"
}

variable "efs_mountpoint" {
  description = "EFS mount point on the ECS instance"
  default     = "data"
}

variable "ecs_user_data_efs_owner" {
  description = "EFS mount point owner on the ECS instance"
  default     = "1000"
}

variable "ecs_lc_image_id" {
  description = "The AMI image ID for the ECS instance"
  default     = "ami-4cbe0935"
}

variable "ecs_lc_instance_type" {
  description = "The EC2 instance type for the ECS instance"
  default     = "t2.micro"
}

##ECS - launch configuration           

variable "ecs_lc_data_block_device_name" {
  description = "The name of the EBS data block device for the ECS instance"
  default     = "/dev/xvdz"
}

variable "ecs_lc_data_block_device_type" {
  description = "The type of the EBS data block device for the ECS instance"
  default     = "gp2"
}

variable "ecs_lc_data_block_device_size" {
  description = "The size (GB) of the EBS data block device for the ECS instance"
  default     = "24"
}

variable "ecs_lc_root_device_type" {
  description = "The type of the root block device for the ECS instance"
  default     = "gp2"
}

variable "ecs_lc_root_device_size" {
  description = "The size of the root block device for the ECS instance"
  default     = "12"
}

variable "ecs_asg_health_check_type" {
  description = "Controls how health checking is done (EC2 or ELB)"
  default     = "EC2"
}

variable "ecs_asg_min_size" {
  description = "The minimum size of the auto scale group"
  default     = "1"
}

variable "ecs_asg_max_size" {
  description = "The maximum size of the auto scale group"
  default     = "5"
}

variable "ecs_asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default     = "1"
}

variable "ecs_asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  default     = "0"
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  default     = "0"
}

variable "ecs_task_name" {
  description = "A name for ecs task definition"
  default     = ""
}

variable "availability_zones" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
  default     = ["eu-west-1", "eu-west-1b"]
}

### Cluster Scaling Policies

variable "asg_autoscaling_group_name" {
  default = "jenkins-ecs-1"
}

variable "scale_up_adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity"
  default     = "ChangeInCapacity"
}

variable "scale_up_estimated_instance_warmup" {
  description = "The estimated time, in seconds, until a newly launched instance will contribute CloudWatch metrics"
  default     = "60"
}

variable "scale_up_metric_aggregation_type" {
  description = "The aggregation type for the policy's metrics"
  default     = "Average"
}

variable "scale_up_policy_type" {
  description = "The policy type, either SimpleScaling or StepScaling"
  default     = "StepScaling"
}

variable "scale_up_metric_interval_lower_bound" {
  description = " The lower bound for the difference between the alarm threshold and the CloudWatch metric"
  default     = "0"
}

variable "scale_up_scaling_adjustment" {
  description = "The number of instances by which to scale"
  default     = "2"
}

variable "scale_down_adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity"
  default     = "PercentChangeInCapacity"
}

variable "scale_down_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
  default     = "120"
}

variable "scale_down_scaling_adjustment" {
  description = "The percentage of instances by which to scale down"
  default     = "-50"
}

# CloudWatch Alarms
variable "scale_up_alarm_metric_name" {
  description = "The name for the alarm's associated metric"
  default     = "CPUReservation"
}

variable "scale_up_alarm_namespace" {
  description = "The namespace for the alarm's associated metric"
  default     = "ECS"
}

variable "scale_up_alarm_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "scale_up_alarm_statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  default     = "Maximum"
}

variable "scale_up_alarm_threshold" {
  description = "The value against which the specified statistic is compared"
  default     = "20"
}

variable "scale_up_alarm_period" {
  description = "The period in seconds over which the specified statistic is applied"
  default     = "30"
}

variable "scale_up_alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  default     = "1"
}

variable "scale_up_alarm_treat_missing_data" {
  description = "Sets how this alarm is to handle missing data points"
  default     = "notBreaching"
}

variable "scale_down_alarm_metric_name" {
  description = "The name for the alarm's associated metric"
  default     = "CPUReservation"
}

variable "scale_down_alarm_namespace" {
  description = "The namespace for the alarm's associated metric"
  default     = "ECS"
}

variable "scale_down_alarm_comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold"
  default     = "LessThanThreshold"
}

variable "scale_down_alarm_statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  default     = "Maximun"
}

variable "scale_down_alarm_threshold" {
  description = "The value against which the specified statistic is compared"
  default     = "50"
}

variable "scale_down_alarm_period" {
  description = "The period in seconds over which the specified statistic is applied"
  default     = "120"
}

variable "scale_down_alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  default     = "1"
}

variable "scale_down_alarm_treat_missing_data" {
  description = "Sets how this alarm is to handle missing data points"
  default     = "notBreaching"
}
