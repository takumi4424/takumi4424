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
    docker-ce docker-ce-cli containerd.io
    dialog
    jq
)
# 準備
if ! which fish >/dev/null; then sudo apt-add-repository ppa:fish-shell/release-3; fi
if ! which docker >/dev/null; then
    sudo apt update
    sudo apt install -y
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
sudo apt update


################################################################################
################################### Fish関連 ###################################
################################################################################
# if [[ $(cat /etc/passwd | grep -E "^$(id -un):" | cut -d : -f 7) != $(which fish) ]]; then
#     sudo chsh -s "$(which fish)" "$(id -un)"
# fi

################################################################################
################################# フォント関連 #################################
################################################################################
if ! [[ -d /usr/share/fonts/HackGen ]]; then
    url='https://github.com/yuru7/HackGen/releases'
    pattern="<html><body>You are being <a href=\"$url/tag/(.+)\">redirected</a>\.</body></html>"
    if [[ $(curl -s $url/latest) =~ ^$pattern$ ]]; then
        # 最新のHackGenフォントをダウンロード
        version="${BASH_REMATCH[1]}"
        curl -Lo "$tempdir/HackGen.zip" "$url/download/$version/HackGen_$version.zip"
        unzip "$tempdir/HackGen.zip" -d "$tempdir"
        mv "$tempdir/HackGen_$version" /usr/share/fonts/HackGen
    else
        abort "Error: Failed to install HackGen font..."
    fi
    fc-cache -fv
fi

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



# 終わりに
source "$here/setup_common_pre.bash"
