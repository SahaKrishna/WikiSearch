#/bin/bash
export AWS_PAGER=""

STACK=`aws-vault exec techtest.scalefactory.net -- \
aws cloudformation describe-stacks \
--region eu-west-1 \
--stack-name tech-test-cf`
