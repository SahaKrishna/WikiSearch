#!/bin/bash
export AWS_PAGER=""

word() {
  # The dictionary file. It contains one word per line.
  dictionary=/usr/share/dict/words
  # The number of words in the dictionary file.
  num_words_in_dictionary=$(wc -l $dictionary | awk '{print $1}')
  # A random number corresponding to a line in the dictionary file.
  # This takes random data from /dev/random, converts it to an unsigned integer, and scales it by the number of words available.
  random_line_number=$(($(cat /dev/random | od -N3 -An -D) % $num_words_in_dictionary))

  # Prints the word corresponding to the random line calculated above.
  local word=`awk "NR == $random_line_number" $dictionary`
  echo "$word"
}

echo "Applying sample load"

ENDPOINT=`aws elbv2 describe-load-balancers --region eu-west-1 --names wiki-check-alb --query 'LoadBalancers[*].DNSName' --output text | awk '{print "http://" $1}'`
echo "$ENDPOINT"
docker run --network host --rm jordi/ab -c 2 -n 10000 -s 120 "${ENDPOINT}/pageview/search/$(word)"
