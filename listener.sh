#!/bin/bash

# ignore all errors in the script
set -e

# trap interrupt_catcher SIGINT. CTRL+C won't interrupt the docker container otherwise because of the gcloud command
trap exit INT

# Execute pubsub-emulator-docker to create topics and subscriptions after the emulator opened its ports.

(/wait-for-it.sh $HOSTPORT -- env PUBSUB_EMULATOR_HOST=$HOSTPORT /usr/bin/pubsub-emulator-docker -debug) &
# WAIT_FOR_PID="$!"

gcloud beta emulators pubsub start --host-port $HOSTPORT &
# EMULATOR_PID="$!"
wait
