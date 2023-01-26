#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")../"
if ! [ -e ~/.local/share/helm/plugins/helm-unittest ];then
    # it might be broken symlint therefore we try to remove it anyways
    rm -f ~/.local/share/helm/plugins/helm-unittest
    helm plugin install https://github.com/quintush/helm-unittest
fi

helm unittest \
    -3 ./testing-charts/common-test \
    -f "tests/**/*_test.yaml"
