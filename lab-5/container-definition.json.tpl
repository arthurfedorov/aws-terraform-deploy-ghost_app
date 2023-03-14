[
{
	"name": "ghost_container",
	"image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/ghost:${ghost_app_image_version}",
	"essential": true,
	"linuxParameters": {
        "initProcessEnabled": true
	},
	"environment": [{
			"name": "database__client",
			"value": "mysql"
		},
		{
			"name": "database__connection__host",
			"value": "${DB_URL}"
		},
		{
			"name": "database__connection__user",
			"value": "${DB_USER}"
		},
		{
			"name": "database__connection__password",
			"value": "${DB_PASSWORD}"
		},
		{
			"name": "database__connection__database",
			"value": "${DB_NAME}"
		}
	],
	"mountPoints": [{
		"containerPath": "/var/lib/ghost/content",
		"sourceVolume": "ghost_volume"
	}],
	"portMappings": [{
		"name": "ghost-2368-tcp",
		"containerPort": 2368,
		"hostPort": 2368
	}],
	"logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
			"awslogs-group": "/ecs/ghost_def",
			"awslogs-region": "eu-central-1",
			"awslogs-stream-prefix": "ecs"
                }
            }
}
]