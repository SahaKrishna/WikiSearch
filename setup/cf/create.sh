#!/bin/bash
export AWS_PAGER=""

PASSWORD=`gpg --gen-random --armor 1 14`

aws cloudformation create-stack \
--region eu-west-1 \
--stack-name tech-test-cf \
--template-body file://tech-test-cf.yml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Password,ParameterValue=$PASSWORD
