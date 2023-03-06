#!/bin/bash

docker pull ghost: && \ 
docker tag ghost:4.12.1 ${aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ghost:4.12.1 && \
$(aws ecr get-login --no-include-email --region ${var.aws_region}) && \ 
docker push ${aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ghost:4.12.1"
