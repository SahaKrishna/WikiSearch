# STEP 1 build executable binary
FROM alpine:latest
RUN apk update && apk add mariadb-client wget gzip
ARG data_url="https://dumps.wikimedia.org/other/pageviews/2019/2019-08/pageviews-20190808-170000.gz"
RUN mkdir /app
RUN wget --quiet $data_url -O /app/page_views.data.gz
RUN gunzip /app/page_views.data.gz
COPY ./run.sh /app/run.sh
RUN chmod +x /app/run.sh
CMD /app/run.sh
