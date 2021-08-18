#!/bin/bash
export AWS_PAGER=""

aws cloudformation delete-stack \
--region eu-west-1 \
--stack-name tech-test-cf
