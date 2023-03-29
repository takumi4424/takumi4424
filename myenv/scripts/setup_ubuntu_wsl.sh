#!/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"

# いろいろインストール
sudo apt-add-repository ppa:fish-shell/release-3 # fish shellのためのリポジトリ追加
sudo apt update
sudo apt install -y \
    fish \
    git \
    jq \
    vim