#!/usr/bin/env zsh

set -e
set -x

openssl x509 -in public.crt -noout -text
