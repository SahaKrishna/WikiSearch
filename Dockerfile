# STEP 1 build executable binary
FROM golang:alpine as builder
# Set ENVs
ENV GO111MODULE=auto
# Install git + SSL ca certificates
RUN apk update && apk add git && apk add ca-certificates
# Create appuser
RUN adduser -D -g '' server
COPY . $GOPATH/src/github.com/scalefactory-hiring/technical-test/
WORKDIR $GOPATH/src/github.com/scalefactory-hiring/technical-test/cmd/server
#get dependancies
RUN go get -d -v
#build the binarys
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/server
WORKDIR $GOPATH/src/github.com/scalefactory-hiring/technical-test/tools/import
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/import
# STEP 2 build a small image
# start from scratch
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
# Copy our static executable
COPY --from=builder /go/bin/server /go/bin/server
COPY --from=builder /go/bin/import /go/bin/import
USER server
COPY web /go/web/
WORKDIR /go/
EXPOSE 8080
ENTRYPOINT ["/go/bin/server"]
