#!/bin/bash
set -eu
# 共通の設定
here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
source "$here/setup_common_pre.bash"


################################################################################
################################### ホスト名 ###################################
################################################################################

################################################################################
######################### apt package インストール準備 #########################
################################################################################
# 準備(fish)
if ! which fish >/dev/null; then
    sudo apt-add-repository ppa:fish-shell/release-3
fi
# 準備(docker)
if ! which docker >/dev/null; then
    # 依存パッケージインストール
    sudo apt update
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    # リポジトリと鍵のインストール
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
# 準備(VSCode)
if ! which code >/dev/null; then
    # 依存パッケージインストール
    sudo apt update
    sudo apt install -y \
        apt-transport-https \
        curl \
        gnupg
    # リポジトリと鍵のインストール
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
fi

################################################################################
start_installing 'apt packages' ################################################
################################################################################
# aptでインストールするソフトウェアのリスト
pkgs=(
    code
    containerd.io # docker
    dialog
    docker-ce     # docker
    docker-ce-cli # docker
    fish
    jq
    xdg-utils
    xsel
)

# インストール済みソフトウェアの確認
installed_pkgs=()
while read pkg; do
    installed_pkgs+=("$pkg")
done < <(apt list --installed 2>/dev/null | cut -d '/' -f 1)
# 未インストールソフトの抽出
uninstalled_pkgs=()
for pkg in "${pkgs[@]}"; do
    array_contains 'installed_pkgs' "$pkg" || uninstalled_pkgs+=("$pkg")
done

# 未インストールソフトのインストール
if (( ${#uninstalled_pkgs[@]} > 0 )); then
    start_installing_sub "installing apt packages..."
    sudo apt update
    sudo apt install -y "${uninstalled_pkgs[@]}"
    echo '----------------'
fi

# インストールの実施状態表示
for pkg in "${pkgs[@]}"; do
    if array_contains 'installed_pkgs' "$pkg"; then
        echo "not installed: $pkg: already installed"
    else
        echo "installed: $pkg"
    fi
done

################################################################################
start_installing 'Fonts' #######################################################
################################################################################
# 白源
if ! [[ -d /usr/share/fonts/HackGen ]]; then
    url='https://github.com/yuru7/HackGen/releases'
    pattern="<html><body>You are being <a href=\"$url/tag/(.+)\">redirected</a>\.</body></html>"
    if [[ $(curl -s $url/latest) =~ ^$pattern$ ]]; then
        # 最新のHackGenフォントをダウンロード
        version="${BASH_REMATCH[1]}"
        curl -Lo "$tempdir/HackGen.zip" "$url/download/$version/HackGen_$version.zip"
        unzip "$tempdir/HackGen.zip" -d "$tempdir"
        sudo mv "$tempdir/HackGen_$version" /usr/share/fonts/HackGen
        echo '---'
        echo 'successfully installed.'
    else
        abort 'Error: Failed to install HackGen font...'
    fi
    fc-cache -fv
else
    echo 'already installed.'
fi

################################################################################
start_installing 'Other Applications' ##########################################
################################################################################
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
echo 'installed: tereminal profile (9fd90481-da24-477a-955c-6797762f19d4)'

################################################################################
################################### Fish関連 ###################################
################################################################################
# if [[ $(cat /etc/passwd | grep -E "^$(id -un):" | cut -d : -f 7) != $(which fish) ]]; then
#     sudo chsh -s "$(which fish)" "$(id -un)"
# fi



# 終わりに
source "$here/setup_common_post.bash"
