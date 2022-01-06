#!/usr/bin/env zsh

are_you_sure()
{
  read -q "REPLY?$1(y/n)? "
  printf "\n"

  if [ "$REPLY" = "n" ]; then
    exit
  fi
}

are_you_sure "Are you sure"

kubens minio-tenant-1
kubectl minio tenant delete minio-tenant-1 --namespace minio-tenant-1
