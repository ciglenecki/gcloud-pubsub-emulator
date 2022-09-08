FROM golang:alpine as builder
RUN apk update && apk upgrade && apk add --no-cache git
WORKDIR /app

# copy go source code, make go module and install it
COPY main.go .
RUN go mod init pubsub-emulator-docker
RUN go mod tidy
RUN go install .

###############################################################################

FROM google/cloud-sdk:alpine

EXPOSE 8085

# Install dependencies
RUN apk --update add openjdk8-jre
RUN gcloud components install beta pubsub-emulator

# If you're using this Docker image in a docker-compose setup or something similar, you might have leveraged scripts like wait-for or wait-for-it to detect when the PubSub service comes up before starting a container that depends on it being up. If you're not using the above-mentioned PUBSUB_PROJECT environment variable, you can simply check if port 8085 is available. If you do depend on one or more PUBSUB_PROJECT environment variables, you should check for the availability of port 8086 as that one will become available once all the topics and subscriptions have been created.
COPY wait-for-it.sh /wait-for-it.sh
# Copy listener and run it
COPY --from=builder /go/bin/pubsub-emulator-docker /usr/bin
COPY listener.sh /listener.sh

RUN chmod +x /wait-for-it.sh
RUN chmod +x /listener.sh

ENV HOSTPORT=0.0.0.0:8085

# Issue 1: gcloud beta emulators pubsub start can't be run in .sh script becase the interrupt signal won't kill it
# Issue 2: wait-for-it has to be called as a command, it can't be runned with RUN
# CMD /listener.sh && gcloud beta emulators pubsub start --host-port=0.0.0.0:$PORT

ENTRYPOINT ["/listener.sh"]