#!/bin/bash

echo "Applying sample load"

ENDPOINT=`aws elbv2 describe-load-balancers --region eu-west-1 --names wiki-check-alb --query 'LoadBalancers[*].DNSName' --output text | awk '{print "http://" $1}'`
echo $ENDPOINT
docker run --network host --rm jordi/ab -c 5 -n 100 -s 120 ${ENDPOINT}/pageview/search/phili
docker run --network host --rm jordi/ab -c 40 -n 1000 -s 120 ${ENDPOINT}/
docker run --network host --rm jordi/ab -c 100 -n 1000 -s 120 ${ENDPOINT}/pageview/show/328514
