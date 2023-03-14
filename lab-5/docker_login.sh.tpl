#!/bin/bash
docker pull ${ghost_app_image}:${ghost_app_image_version}
docker tag ${ghost_app_image}:${ghost_app_image_version} ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/ghost:${ghost_app_image_version}
aws ecr get-login-password --region ${aws_region}| docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
docker push ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/ghost:${ghost_app_image_version}