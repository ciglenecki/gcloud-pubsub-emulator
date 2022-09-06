#!/bin/bash

# Execute pubsub-emulator-docker GO program to create topics and subscriptions after the emulator opened its ports.

(/wait-for-it.sh localhost:$PORT -- env PUBSUB_EMULATOR_HOST=localhost:$PORT  /usr/bin/pubsub-emulator-docker -debug) &