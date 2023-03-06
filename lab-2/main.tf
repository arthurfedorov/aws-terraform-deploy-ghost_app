provider "aws" {
}

data "aws_ami" "latest_amazon_linux" {
  owners = [ "137112412989" ]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}

# Create VPC
resource "aws_vpc" "cloudx" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "cloudx"
    }
}

# Create subnet
resource "aws_subnet" "public_a" {
    cidr_block = "10.10.1.0/24"
    vpc_id = aws_vpc.cloudx.id
    map_public_ip_on_launch = true
    availability_zone = "eu-central-1a"

    tags = {
        Name = "public_a"
    }
}

resource "aws_subnet" "public_b" {
    cidr_block = "10.10.2.0/24"
    vpc_id = aws_vpc.cloudx.id
    map_public_ip_on_launch = true
    availability_zone = "eu-central-1b"
    
    tags = {
        Name = "public_b"
        }
}

resource "aws_subnet" "public_c" {
    cidr_block = "10.10.3.0/24"
    vpc_id = aws_vpc.cloudx.id
    map_public_ip_on_launch = true
    availability_zone = "eu-central-1c"

    tags = {
        Name = "public_b"
        }
}

# Create internet gateaway

resource "aws_internet_gateway" "cloudx-igw" {
    vpc_id = aws_vpc.cloudx.id

    tags = {
        Name = "cloudx-igw"
    }
}

# Create route table

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.cloudx.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cloudx-igw.id
    }

    tags = {
        Name = "public_rt"
    }
}

# Create subnet association

resource "aws_route_table_association" "public_a" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
    subnet_id = aws_subnet.public_b.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_c" {
    subnet_id = aws_subnet.public_c.id
    route_table_id = aws_route_table.public_rt.id
}

# Create security group for bastion

resource "aws_security_group" "bastion" {
  name_prefix = "bastion"
  description = "allows access to bastion"
  vpc_id = aws_vpc.cloudx.id 
}

# Add ingress and egress rules to the bastion security group
resource "aws_security_group_rule" "bastion_ingress" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.your_ip]
}

resource "aws_security_group_rule" "bastion_egress" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create the ec2_pool security group
resource "aws_security_group" "ec2_pool" {
  name_prefix = "ec2_pool"
  description = "allows access to ec2 instances"
  vpc_id = aws_vpc.cloudx.id
}

# Add ingress and egress rules to the ec2_pool security group
resource "aws_security_group_rule" "ec2_pool_ingress_1" {
  security_group_id = aws_security_group.ec2_pool.id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "ec2_pool_ingress_2" {
  security_group_id = aws_security_group.ec2_pool.id
  type = "ingress"
  from_port = 2049
  to_port = 2049
  protocol = "tcp"
  cidr_blocks = [aws_vpc.cloudx.cidr_block]
}

resource "aws_security_group_rule" "ec2_pool_ingress_3" {
  security_group_id = aws_security_group.ec2_pool.id
  type = "ingress"
  from_port = 2368
  to_port = 2368
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_pool_egress" {
  security_group_id = aws_security_group.ec2_pool.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# Create the alb security group
resource "aws_security_group" "alb" {
  name_prefix = "alb"
  description = "allows access to alb"
  vpc_id = aws_vpc.cloudx.id
}

# Add ingress and egress rules to the alb security group
resource "aws_security_group_rule" "alb_ingress" {
  security_group_id = aws_security_group.alb.id
  type = "ingress"
  from_port = 80
  to_port  = 80
  protocol = "tcp"
  cidr_blocks = [var.your_ip]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = aws_security_group.ec2_pool.id
}

# Create the efs security group
resource "aws_security_group" "efs" {
  name_prefix = "efs"
  description = "defines access to efs mount points"
  vpc_id = aws_vpc.cloudx.id
}

# Add ingress and egress rules to the efs security group
resource "aws_security_group_rule" "efs_ingress" {
  security_group_id = aws_security_group.efs.id
  type = "ingress"
  from_port = 2049
  to_port  = 2049
  protocol = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "efs_egress" {
  security_group_id = aws_security_group.efs.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [aws_vpc.cloudx.cidr_block]
}

# Create EFS
resource "aws_efs_file_system" "ghost_content" {
    tags = {
        Name = "ghost_content"
    }
}

# Create EFS mount target for each subnet

resource "aws_efs_mount_target" "subnet_a" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id = aws_subnet.public_a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "subnet_b" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id = aws_subnet.public_b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "subnet_c" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id = aws_subnet.public_c.id
  security_groups = [aws_security_group.efs.id]
}

# Create IAM role, policy, profile and attachs
resource "aws_iam_policy" "ghost_app_policy" {
  name = "ghost_app_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ec2:Describe*",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticloadbalancing:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ghost_app_role" {
  name = "ghost_app_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
    }
    ]
})
}

resource "aws_iam_role_policy_attachment" "nghost_app_role_policy_attachmentame" {
  policy_arn = aws_iam_policy.ghost_app_policy.arn
  role = aws_iam_role.ghost_app_role.name
}

resource "aws_iam_instance_profile" "ghost_app" {
  name = "ghost_app"
  role = aws_iam_role.ghost_app_role.name
}

# Create Application load balancer
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.alb.id]
  ip_address_type = "ipv4"
  name = "ghost-alb"

  subnet_mapping {
    subnet_id = aws_subnet.public_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.public_b.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.public_c.id
  }
}

# Create target group for load balancer
resource "aws_lb_target_group" "ghost-ec2" {
  name = "ghost-ec2"
  port = 2368
  protocol = "HTTP"
  vpc_id = aws_vpc.cloudx.id
  target_type = "instance"
}

# Create listener for alb
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ghost-ec2.arn
  }
}

# Create template with alb resource reference varibale
data "template_file" "user_data" {
  template = file("./user_data.sh.tpl")

  vars = {
    load_balancer_dns_name = "${aws_lb.alb.dns_name}"
  }
}


# Create Launch template
resource "aws_launch_template" "ghost-launch_template" {
  name_prefix = "ghost-app-"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_pool.id]
  image_id = data.aws_ami.latest_amazon_linux.id
  key_name = "ghost-ec2-pool"
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost_app.id
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ghost-app"
    }
  }
  user_data = base64encode(data.template_file.user_data.rendered)
}

# Create autoscaling group
resource "aws_autoscaling_group" "ghost_ec2_pool" {
  name = "ghost_ec2_pool"
  desired_capacity = 1
  max_size = 3
  min_size = 1
  health_check_type = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  target_group_arns = [aws_lb_target_group.ghost-ec2.arn]
  launch_template {
    id = aws_launch_template.ghost-launch_template.id
    version = "$Latest"
    }
}

# Attach autoscale group to elb
resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.ghost_ec2_pool.id
  lb_target_group_arn = aws_lb_target_group.ghost-ec2.arn
}

# Create bastion EC2 instance for connectin to instances
resource "aws_instance" "bastion" {
    ami = data.aws_ami.latest_amazon_linux.id
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = aws_subnet.public_a.id
    vpc_security_group_ids = [aws_security_group.bastion.id]
    key_name = "ghost-ec2-pool"
    iam_instance_profile = aws_iam_instance_profile.ghost_app.id

    tags = {
      Name = "bastion"
    }
}