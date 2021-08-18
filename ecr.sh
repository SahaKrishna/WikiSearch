#!/bin/bash
export AWS_PAGER=""
AWS_ACCOUND_ID="133002017424"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin "${AWS_ACCOUND_ID}.dkr.ecr.eu-west-1.amazonaws.com"
