#!/bin/bash
export AWS_PAGER=""

PASSWORD=`gpg --gen-random --armor 1 14`

CLOUDSTACK=`aws cloudformation update-stack \
--region eu-west-1 \
--stack-name tech-test-cf \
--template-body file://tech-test-cf.yml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Password,ParameterValue=$PASSWORD`

echo "## AWS Console Access"
echo ""
echo "If you wish to login to the AWS console the login URL is"
echo "https://sf-tech-test.signin.aws.amazon.com/console/"
echo "* User is ScaleFactory"
echo "* Password is $PASSWORD"
echo ""
echo "This is running in the AWS eu-west-1 region."
echo ""

echo "## AWS Console" >> ../../.creds
echo "Login: https://sf-tech-test.signin.aws.amazon.com/console/" >> ../../.creds
echo "* User is ScaleFactory" >> ../../.creds
echo "* Password is $PASSWORD" >> ../../.creds
echo "" >> ../../.creds
