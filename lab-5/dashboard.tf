# Define the CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "example_dashboard" {
  dashboard_name = "example-dashboard"

  # Define the widgets for each metric
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
        stacked = false
        metrics = [
          ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "example-asg", { stat = "Average" }]
        ]
        title = "EC2 Auto Scaling Group CPU Utilization"
      }
    },

    # ECS Service metrics
    {
      type   = "metric"
      x      = 6
      y      = 0
      width  = 6
      height = 6
      properties = {
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "example-service", { stat = "Average" }],
          ["AWS/ECS", "TaskCount", "ServiceName", "example-service", { stat = "Sum" }]
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
        stacked = false
        metrics = [
          ["AWS/EFS", "ClientConnections", "FileSystemId", "example-efs", { stat = "Sum" }],
          ["AWS/EFS", "VolumeBytesUsed", "FileSystemId", "example-efs", { stat = "Average" }]
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
        stacked = false
        metrics = [
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "example-db", { stat = "Sum" }],
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "example-db", { stat = "Average" }],
          ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "example-db", { stat = "Average" }],
          ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "example-db", { stat = "Average" }]
        ]
        title = "RDS Database Connections, CPU Utilization, and IOPS"
      }
    }
  ]
}
