#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")../"
if ! [ -e ~/.local/share/helm/plugins/helm-unittest ];then
    # it might be broken symlint therefore we try to remove it anyways
    rm -f ~/.local/share/helm/plugins/helm-unittest
    # v0.3.6 is broken
    helm plugin install https://github.com/helm-unittest/helm-unittest --version v0.3.5
fi

helm unittest \
    ./testing-charts/common-test \
    -f "tests/**/*_test.yaml"
