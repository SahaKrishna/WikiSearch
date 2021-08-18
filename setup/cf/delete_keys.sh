#!/bin/bash
export AWS_PAGER=""

TF_ACCESS_KEY_ID=`aws iam list-access-keys \
--region eu-west-1 \
--user-name Terraform \
--query "AccessKeyMetadata[0].[AccessKeyId]" \
--output text`

CAN_ACCESS_KEY_ID=`aws iam list-access-keys \
--region eu-west-1 \
--user-name ScaleFactory \
--query "AccessKeyMetadata[0].[AccessKeyId]" \
--output text`

WC_ACCESS_KEY_ID=`aws iam list-access-keys \
--region eu-west-1 \
--user-name Wikicheck \
--query "AccessKeyMetadata[0].[AccessKeyId]" \
--output text`


aws iam delete-access-key \
--region eu-west-1 \
--user-name Terraform \
--access-key-id "${TF_ACCESS_KEY_ID}"

aws iam delete-access-key \
--region eu-west-1 \
--user-name ScaleFactory \
--access-key-id "${CAN_ACCESS_KEY_ID}"

aws iam delete-access-key \
--region eu-west-1 \
--user-name Wikicheck \
--access-key-id "${WC_ACCESS_KEY_ID}"
