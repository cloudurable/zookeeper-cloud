#!/usr/bin/env bash

packer build \
    -var 'docker-tag=0.4' \
    base-java-packer.json

packer build \
        -var 'docker-tag=latest' \
        base-java-packer.json
