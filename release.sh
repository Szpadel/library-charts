#!/usr/bin/env bash
set -euo pipefail

if [ $# != 1 ];then
  echo "Usage: $0 <chart name>"
  exit 1
fi

helm3 package charts/$1 -d releases/

helm3 repo index --merge index.yaml --url https://szpadel.github.io/liblary-charts/ .
