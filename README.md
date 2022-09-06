# gcloud-pubsub-emulator

fixes compared to original repo:
- CTRL+C is supported
- creating push subscriptions is supported

Dockerized PubSub emulator which supports Push and Pull subscriptions.

This repository contains the Docker configuration for Google's PubSub emulator. It's mainly the dockerization and documentation of:


- https://github.com/floatschedule/pubsubc

## Installation

1.A) A pre-built Docker container is available for Docker Hub:

```
docker run --rm -ti -p 8681:8681 matejciglenecki/gcloud-pubsub-emulator:latest
```

1.B) Build this repository yourself:

```
docker build -t gcloud-pubsub-emulator:latest .
docker run --rm -ti -p 8681:8681 gcloud-pubsub-emulator:latest
```

Usage
-----
After you've ran the above-mentioned `docker run` command, you should be able to use any app that has PubSub implemented and point it to your Docker container by specifying the `PUBSUB_EMULATOR_HOST` environment variable.

```bash
export PUBSUB_EMULATOR_HOST=localhost:8681
./myapp
```
or
```bash
env PUBSUB_EMULATOR_HOST=localhost:8681 ./myapp
```


## Automatic topic and subscription creation

To automatically create topics and subscriptions in projects on startup you can specify the `PUBSUB_PROJECT<INT>` environment variable with a sequentual number appended to it, starting with _1_. The format of the environment variable is relatively simple:

For example, If you have:
- _project ID_ `company-dev`
- topic `invoices`
	- with a push subscription `invoice-calculator` with an endpoint `localhost`
- topic `chats`
	- with a pull subscription `slack-out`
	- with a pull subscription `irc-out`
- topic `notifications` without any subscriptions

you'd define `PUBSUB_PROJECT1` this way:

```bash
PUBSUB_PROJECT1=company-dev,invoices:invoice-calculator+localhost,chats:slack-out:irc-out,notifications
```

So the full command would look like:

```bash
docker run --rm -ti -p 8681:8681 -e PUBSUB_PROJECT1=company-dev,invoices:invoice-calculator+localhost,chats:slack-out:irc-out,notifications matejciglenecki/gcloud-pubsub-emulator:latest
```


`PUBSUB_PROJECT<INT>` is a comma-separated list where the first item is the _project ID_ and the rest are topics. The topics themselves are colon-separated where the first item is the _topic ID_ and the rest are _subscription IDs_. A topic doesn't necessarily need to specify subscriptions. Endpoint can be attached to the subscription, turning it into a push subscription. If you want to define more projects, you'd simply add a `PUBSUB_PROJECT2`, `PUBSUB_PROJECT3`, etc.

## wait-for, wait-for-it
If you're using this Docker image in a docker-compose setup or something similar, you might have leveraged scripts like [wait-for](https://github.com/eficode/wait-for) or [wait-for-it](https://github.com/vishnubob/wait-for-it) to detect when the PubSub service comes up before starting a container that depends on it being up. If you're _not_ using the above-mentioned _PUBSUB_PROJECT_ environment variable, you can simply check if port `8681` is available. If you _do_ depend on one or more _PUBSUB_PROJECT_ environment variables, you should check for the availability of port `8682` as that one will become available once all the topics and subscriptions have been created.
