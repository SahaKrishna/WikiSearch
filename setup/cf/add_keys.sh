#!/bin/bash
export AWS_PAGER=""

CAN_USER_KEYS=`aws iam create-access-key \
--region eu-west-1 \
--user-name ScaleFactory`

TF_USER_KEYS=`aws iam create-access-key \
--region eu-west-1 \
--user-name Terraform`

WC_USER_KEYS=`aws iam create-access-key \
--region eu-west-1 \
--user-name Wikicheck`

CAN_AWS_ACCESS_KEY_ID=`echo $CAN_USER_KEYS | jq -r '.[].AccessKeyId'`
CAN_AWS_SECRET_ACCESS_KEY=`echo $CAN_USER_KEYS | jq -r '.[].SecretAccessKey'`

echo "## AWS CREDENTIALS"
echo ""
echo "If you want to use cli tools then the following access key pair will give you readonly access."
echo '```'
echo "AWS_ACCESS_KEY_ID=${CAN_AWS_ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY=${CAN_AWS_SECRET_ACCESS_KEY}"
echo '```'
echo ""
echo "You can use the following commands to get the credentials into the environment"
echo '```'
echo "export AWS_ACCESS_KEY_ID=${CAN_AWS_ACCESS_KEY_ID}; export AWS_SECRET_ACCESS_KEY=${CAN_AWS_SECRET_ACCESS_KEY}"
echo '```'
echo ""

echo "## AWS CLI Secrets" >> ../../.creds
echo "AWS_ACCESS_KEY_ID=${CAN_AWS_ACCESS_KEY_ID}" >> ../../.creds
echo "AWS_SECRET_ACCESS_KEY=${CAN_AWS_SECRET_ACCESS_KEY}" >> ../../.creds
echo "" >> ../../.creds



AWS_ACCESS_KEY_ID=`echo $TF_USER_KEYS | jq -r '.[].AccessKeyId'`
AWS_SECRET_ACCESS_KEY=`echo $TF_USER_KEYS | jq -r '.[].SecretAccessKey'`

echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > ../../.env
echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ../../.env

echo "export TF_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > ../.KEYIDS
echo "export CAN_AWS_ACCESS_KEY_ID=${CAN_AWS_ACCESS_KEY_ID}" >> ../.KEYIDS
