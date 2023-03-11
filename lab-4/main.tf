terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      }
  }
}

provider "aws" {
}
provider "docker" {
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

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

# Create public route table
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

# Create public subnet association with route table
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

# Create private subnets for database
resource "aws_subnet" "private_db_a" {
    cidr_block = "10.10.20.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1a"

    tags = {
        Name = "private_db_a"
    }
}

resource "aws_subnet" "private_db_b" {
    cidr_block = "10.10.21.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1b"

    tags = {
        Name = "private_db_b"
    }
}

resource "aws_subnet" "private_db_c" {
    cidr_block = "10.10.22.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1c"

    tags = {
        Name = "private_db_c"
    }
}

# Create private route table
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.cloudx.id

    tags = {
        Name = "private_rt"
    }
}

# Create private subnet association with private route table
resource "aws_route_table_association" "private_db_a" {
  subnet_id = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_b" {
  subnet_id = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_c" {
  subnet_id = aws_subnet.private_db_c.id
  route_table_id = aws_route_table.private_rt.id
}

# Create private subnets for ecs
resource "aws_subnet" "private_a" {
    cidr_block = "10.10.10.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1a"

    tags = {
        Name = "private_a"
    }
}

resource "aws_subnet" "private_b" {
    cidr_block = "10.10.11.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1b"

    tags = {
        Name = "private_b"
    }
}

resource "aws_subnet" "private_c" {
    cidr_block = "10.10.12.0/24"
    vpc_id = aws_vpc.cloudx.id
    availability_zone = "eu-central-1c"

    tags = {
        Name = "private_c"
    }
}

# Create private subnet association with private route table
resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}

# Create VPC endpoint security group
resource "aws_security_group" "vpc_endpoint" {
  name = "vpc_endpoint"
  vpc_id = aws_vpc.cloudx.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

# Create security group for database
resource "aws_security_group" "mysql" {
  name_prefix = "mysql"
  description = "defines access to ghost db"
  vpc_id = aws_vpc.cloudx.id
}

# Create ingress and egress rules for database security group
resource "aws_security_group_rule" "mysql_ingress_1" {
  security_group_id = aws_security_group.mysql.id
  type = "ingress"
  from_port = 0
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "mysql_ingress_2" {
  security_group_id = aws_security_group.mysql.id
  type = "ingress"
  from_port = 0
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.fargate_pool.id
}

resource "aws_security_group_rule" "mysql_egress_1" {
  security_group_id = aws_security_group.mysql.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_security_group_rule" "efs_ingress_1" {
  security_group_id = aws_security_group.efs.id
  type = "ingress"
  from_port = 2049
  to_port  = 2049
  protocol = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "efs_ingress_2" {
  security_group_id = aws_security_group.efs.id
  type = "ingress"
  from_port = 2049
  to_port  = 2049
  protocol = "tcp"
  source_security_group_id = aws_security_group.fargate_pool.id
}

resource "aws_security_group_rule" "efs_egress" {
  security_group_id = aws_security_group.efs.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [aws_vpc.cloudx.cidr_block]
}

# Create ECS security group
resource "aws_security_group" "fargate_pool" {
  name_prefix = "fargate_pool"
  description = "Allows access for Fargate instances"
  vpc_id = aws_vpc.cloudx.id
}

# Create rules for ECS security group
resource "aws_security_group_rule" "fargate_ingress_1" {
  security_group_id = aws_security_group.fargate_pool.id
  type = "ingress"
  from_port = 2049
  to_port  = 2049
  protocol = "tcp"
  source_security_group_id = aws_security_group.efs.id
}

resource "aws_security_group_rule" "fargate_ingress_2" {
  security_group_id = aws_security_group.fargate_pool.id
  type = "ingress"
  from_port = 2368
  to_port  = 2368
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "fargate_egress" {
  security_group_id = aws_security_group.fargate_pool.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
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
          "elasticloadbalancing:Describe*",
          "ssm:GetParameter*",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
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

resource "aws_iam_role_policy_attachment" "ghost_app_role_policy_attachment" {
  policy_arn = aws_iam_policy.ghost_app_policy.arn
  role = aws_iam_role.ghost_app_role.name
}

resource "aws_iam_instance_profile" "ghost_app" {
  name = "ghost_app"
  role = aws_iam_role.ghost_app_role.name
}


# Create an IAM role for ecs
resource "aws_iam_role" "ghost_ecs_role" {
  name = "ghost_ecs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Create an IAM role policy for ecs
resource "aws_iam_policy" "ghost_ecs_policy" {
  name        = "ghost_ecs_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
          "logs:*",
          "ecs:*",
          "ssm:*",
          "ssmmessages:*",
          "elasticfilesystem"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM role policy to the IAM role
resource "aws_iam_role_policy_attachment" "ghost_ecs_role_policy_attachment" {
  policy_arn = aws_iam_policy.ghost_ecs_policy.arn
  role       = aws_iam_role.ghost_ecs_role.name
}

# Create an IAM role profile
resource "aws_iam_instance_profile" "ghost_ecs_role_profile" {
  name = "ghost_ecs_profile"
  role = aws_iam_role.ghost_ecs_role.name
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
  health_check {
    enabled = true
    timeout = 120
    unhealthy_threshold = 5
    healthy_threshold = 2
    interval = 180
  }

  tags = {
    Name = "ghost-ec2"
  }
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

# Create template for ec2 instance
data "template_file" "user_data" {
  template = file("./user_data.sh.tpl")

  vars = {
    load_balancer_dns_name = "${aws_lb.alb.dns_name}"
    DB_NAME = "${aws_db_instance.ghost.db_name}"
    DB_USER = "${aws_db_instance.ghost.username}"
    DB_URL = "${aws_db_instance.ghost.address}"
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

  depends_on = [
    aws_db_instance.ghost
  ]
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

# Create database subnet group
resource "aws_db_subnet_group" "ghost" {
  name = "ghost"
  description = "ghost database subnet group"
    subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id,
    aws_subnet.private_db_c.id,
  ]
}

# Create password and put it into ssm
resource "random_password" "db_password" {
  length = 16
  special = false
}

resource "aws_ssm_parameter" "ghost_db_password" {
  name = "/ghost/db_password"
  description = "Storing password in ssm"
  type = "SecureString"
  value = random_password.db_password.result
  tags = {
    Name = "/ghost/db_password"
  }
  depends_on = [
    random_password.db_password
  ]
}

# Create database
resource "aws_db_instance" "ghost" {
  db_name = "ghost"
  instance_class = "db.t2.micro"
  engine = "mysql"
  engine_version = "8.0"
  allocated_storage = 20
  storage_type = "gp2"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name = aws_db_subnet_group.ghost.name
  username = "ghost"
  password = aws_ssm_parameter.ghost_db_password.value
  depends_on = [
    aws_ssm_parameter.ghost_db_password
  ]

  tags = {
    Name = "ghost"
  }
}

# Create ECR repo
resource "aws_ecr_repository" "ghost" {
  name = "ghost"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "ghost"
  }
}

# Push ghost:4.12.1 image into ghost ECR
# resource "null_resource" "upload_ghost_image" {
#   depends_on = [aws_ecr_repository.ghost]
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash" ,"-c"]
#     command = "./docker_login.sh"

#     # environment = {
#     #   ghost_app_image_version = var.ghost_app_image_version
#     #  }
#   }
# }

# Create ECS cluster
resource "aws_ecs_cluster" "ghost" {
  name = "ghost"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "ghost"
  }
}

# data "template_file" "container_definitions" {
#   template = file("./container-definition.json.tpl")

#   vars = {
#     DB_NAME = "${aws_db_instance.ghost.db_name}"
#     DB_USER = "${aws_db_instance.ghost.username}"
#     DB_URL = "${aws_db_instance.ghost.address}"
#     DB_PASSWORD = "${aws_ssm_parameter.ghost_db_password.value}"
#     aws_account_id = "${data.aws_caller_identity.current.account_id}"
#     aws_region = "${data.aws_region.current.name}"
#   }
# }

# # Create task definition
# resource "aws_ecs_task_definition" "task_def_ghost" {
#   family = "task_def_ghost"
#   requires_compatibilities = ["FARGATE"]
#   memory = 1024
#   cpu = 256
#   network_mode = "awsvpc"
#   volume {
#     name = "ghost_volume"
#     efs_volume_configuration {
#       file_system_id = aws_efs_file_system.ghost_content.id
#     }
#   }
#   container_definitions = data.template_file.container_definitions.rendered
# }

# resource "aws_ecs_service" "ghost" {
#   name = "ghost"
#   launch_type = "FARGATE"
#   task_definition = aws_ecs_task_definition.task_def_ghost.arn
#   cluster = aws_ecs_cluster.ghost.arn
#   desired_count = 1
#   network_configuration {
#     assign_public_ip = false
#     subnets = [
#       aws_subnet.private_a.id,
#       aws_subnet.private_b.id,
#       aws_subnet.private_c.id
#     ]
#     security_groups = [aws_security_group.fargate_pool.id]
    
#   }

# }