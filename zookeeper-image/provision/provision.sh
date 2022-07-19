#!/bin/bash
set -e

dnf -y --disablerepo '*' --enablerepo=extras swap centos-linux-repos centos-stream-repos
dnf -y distro-sync
dnf upgrade 
dnf list installed

dnf install -y java
dnf install -y nc
dnf install -y net-tools	
dnf -y autoremove
