#!/bin/bash
set -eu

here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
tempdir="$(mktemp -d)"

################################################################################
################################### ホスト名 ###################################
################################################################################

################################################################################
############################## aptパッケージ関連 ###############################
################################################################################
# Homebrewでインストールするソフトウェアのリスト
apt_apps=(
    fish
    docker
    dialog
    lima
    jq
)
# 準備
if ! which fish >/dev/null; then sudo apt-add-repository ppa:fish-shell/release-3; fi


################################################################################
################################# フォント関連 #################################
################################################################################
if ! [[ -d /usr/share/fonts/HackGen ]]; then
    curl -Lo "$tempdir/HackGen.zip" https://github.com/yuru7/HackGen/releases/download/v2.5.1/HackGen_v2.5.1.zip
    unzip "$tempdir/HackGen.zip"
    sudo mv "$tempdir/HackGen_v2.5.1" /usr/share/fonts/HackGen
    fc-cache -fv
fi

################################################################################
################################### Fish関連 ###################################
################################################################################
# if [[ $(cat /etc/passwd | grep -E "^$(id -un):" | cut -d : -f 7) != $(which fish) ]]; then
#     sudo chsh -s "$(which fish)" "$(id -un)"
# fi

################################################################################
########################## その他アプリケーション設定 ##########################
################################################################################
# ターミナルプロファイルの設定
# このUUIDはてきとう
uuid='9fd90481-da24-477a-955c-6797762f19d4'
profiles='/org/gnome/terminal/legacy/profiles:'
if ! dconf list "$profiles/" | grep "$uuid" >/dev/null; then
    # gterminal.preferencesがない場合
    # gterminal.preferencesをシステムに追加(uuid: $uuid)
    dconf load "$profiles/:$uuid/" < "$resourcedir/gterminal.preferences"
    # プロファイルリストに追加
    dconf write "$profiles/list" "$(dconf read $profiles/list | tr "'" '"' | jq -c ". += [\"$uuid\"]" | tr '"' "'")"
    # デフォルトを{uuid: $uuid}に設定
    dconf write "$profiles/default" "'$uuid'"
fi
