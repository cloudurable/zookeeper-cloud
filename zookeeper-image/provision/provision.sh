#!/bin/bash
set -e
yum update -y
yum install -y java
yum clean all
rm -rf /var/cache/yum
