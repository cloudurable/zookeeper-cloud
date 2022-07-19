#!/usr/bin/env bash

./download.sh
./configure.sh
packer build -var 'docker-tag=latest' -var 'docker-tag=0.4' docker-packer.json

