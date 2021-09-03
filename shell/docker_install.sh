#!/bin/bash

yum remove docker docker-client  docker-client-latest docker-common docker-latest \
docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux  docker-engine

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install docker-ce -y

systemctl start docker
systemctl enable docker

cat <<EOD >> /etc/docker/daemon.json
{
  "bip": "172.17.0.1/16",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://9jwx2023.mirror.aliyuncs.com"],
  "data-root": "/opt/docker",
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },
  "dns-search": ["default.svc.cluster.local", "svc.cluster.local", "localdomain"],
  "dns-opts": ["ndots:2", "timeout:2", "attempts:2"]
}
EOD
systemctl daemon-reload
systemctl restart docker
