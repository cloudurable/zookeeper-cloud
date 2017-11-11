#!/usr/bin/env bash

./download.sh
./configure.sh
packer build packer.json
