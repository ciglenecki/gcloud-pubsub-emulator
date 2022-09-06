#!/usr/bin/env bash
set -e

docker build -t matejciglenecki/gcloud-pubsub-emulator:latest .
docker push matejciglenecki/gcloud-pubsub-emulator:latest