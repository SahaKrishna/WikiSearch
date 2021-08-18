#!/bin/bash
export AWS_PAGER=""

PASSWORD=`aws cloudformation describe-stacks \
--region eu-west-1 \
--stack-name tech-test-cf  \
--query "Stacks[0].Outputs[?OutputKey=='Password'][OutputValue]" \
--output text`

aws cloudformation update-stack \
--region eu-west-1 \
--stack-name tech-test-cf \
--template-body file://tech-test-cf.yml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Password,ParameterValue=$PASSWORD
