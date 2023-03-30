#!/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# いろんな設定用リソース置き場
resourcedir="$(cd -- "$here/../resources"; pwd)"

# いろいろインストール
sudo -E apt-add-repository ppa:fish-shell/release-3 # fish shellのためのリポジトリ追加
sudo -E apt update
sudo -E apt install -y \
    fish \
    git \
    jq \
    vim \
    xdg-utils \
    xsel

# ターミナルプロファイルの設定
# このUUIDはてきとう
uuid='9fd90481-da24-477a-955c-6797762f19d4'
profiles='/org/gnome/terminal/legacy/profiles:'
list="$(dconf read $profiles/list)"
if [[ -z $list ]]; then list="[]"; fi
# gterminal.preferencesをシステムに追加(uuid: $uuid)
dconf load "$profiles/:$uuid/" < "$resourcedir/gterminal.preferences"
# $uuidをリストに追加した上で重複を削除
dconf write "$profiles/list" "$(echo "$list" | tr "'" '"' | jq ". += [\"$uuid\"]" | jq ". | unique" | tr '"' "'")"
# デフォルトを{uuid: $uuid}に設定
dconf write "$profiles/default" "'$uuid'"
