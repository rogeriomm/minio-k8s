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

set -x
set -e

rm -f ../cert/{private.key,public.crt}

kubectl get -n minio-tenant-1 secret/minio-tenant-1-tls --output="jsonpath={.data.private\.key}" \
  | base64 --decode > ../cert/private.key
echo $?

kubectl get -n minio-tenant-1 secret/minio-tenant-1-tls --output="jsonpath={.data.public\.crt}" \
   | base64 --decode > ../cert/public.crt
echo $?

cat ../cert/private.key
cat ../cert/public.crt
