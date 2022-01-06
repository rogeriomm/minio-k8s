#!/usr/bin/env zsh

are_you_sure()
{
  read -q "REPLY?$1(y/n)? "
  printf "\n"

  if [ "$REPLY" = "n" ]; then
    exit
  fi
}

set -x
set -e

minikube --node=cluster2     ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2-m02 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2-m03 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2     ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
minikube --node=cluster2-m02 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
minikube --node=cluster2-m03 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
