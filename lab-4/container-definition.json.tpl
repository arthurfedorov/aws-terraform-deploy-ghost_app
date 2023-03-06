[
{
	"name": "ghost_container",
	"image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/ghost:4.12.1",
	"essential": true,
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
		"containerPort": 2368,
		"hostPort": 2368
	}]
}
]