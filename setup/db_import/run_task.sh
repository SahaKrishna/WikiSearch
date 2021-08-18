#!/bin/sh
export AWS_PAGER=""

APP_IMAGE=`aws ecs list-task-definitions \
--region eu-west-1 \
--output text | grep dbimport | cut -d '/' -f 2`
SG=`aws ec2 describe-security-groups \
--region eu-west-1 \
--output text \
--filters 'Name=group-name,Values=dbimport-ecs-db' \
--query 'SecurityGroups[*].[GroupId]'`
SUB=`aws ec2 describe-subnets \
--output text \
--region eu-west-1 \
--filters 'Name=tag:Name,Values=private*' \
--query 'Subnets[*].[SubnetId]' \
 | awk -vORS=, '{ print "\"" $1 "\"" }' | sed 's/,$/\n/'`

export APP_IMAGE SG SUB

cat runtask.json | envsubst > .runtask.json

aws ecs run-task --region eu-west-1 --cli-input-json file://./.runtask.json
