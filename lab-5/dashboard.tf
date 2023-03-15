# Define the CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "ghost-metrics" {
  dashboard_name = "ghost-metrics"
  dashboard_body = jsonencode({
    widgets = [
      # EC2 Auto Scaling Group metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "${data.aws_region.current.name}"
          stacked = false
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "ghost_ec2_pool", { stat = "Average" }]
          ]
          title = "EC2 Auto Scaling Group CPU Utilization"
        }
      },
      # ECS metrics
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "${data.aws_region.current.name}"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "ghost", "ServiceName", "${aws_ecs_service.ghost.name}", { stat = "Average" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", "ghost", "ServiceName", "${aws_ecs_service.ghost.name}", { stat = "Sum" }]
          ]
          title = "ECS Service CPU Utilization and Running Tasks Count"
        }
      },
      # EFS metrics
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "${data.aws_region.current.name}"
          stacked = false
          metrics = [
            ["AWS/EFS", "ClientConnections", "FileSystemId", "${aws_efs_file_system.ghost_content.id}", { stat = "Sum" }],
            ["AWS/EFS", "VolumeBytesUsed", "FileSystemId", "${aws_efs_file_system.ghost_content.id}", { stat = "Average" }]
          ]
          title = "EFS Client Connections and Storage Bytes Used"
        }
      },
      # RDS metrics
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "${data.aws_region.current.name}"
          stacked = false
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_db_instance.ghost.id}", { stat = "Sum" }],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.ghost.id}", { stat = "Average" }],
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${aws_db_instance.ghost.id}", { stat = "Average" }],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "${aws_db_instance.ghost.id}", { stat = "Average" }]
          ]
          title = "RDS Database Connections, CPU Utilization, and IOPS"
        }
      }
  ] })
}
