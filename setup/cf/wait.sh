#!/bin/bash
export AWS_PAGER=""

aws cloudformation wait stack-create-complete \
--region eu-west-1 \
--stack-name tech-test-cf
