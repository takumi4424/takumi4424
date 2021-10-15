#!/bin/bash
set -eu

here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
tempdir="$(mktemp -d)"

if ! [[ -d /usr/share/fonts/HackGen ]]; then
    curl -Lo "$tempdir/HackGen.zip" https://github.com/yuru7/HackGen/releases/download/v2.5.1/HackGen_v2.5.1.zip
    unzip "$tempdir/HackGen.zip"
    sudo mv "$tempdir/HackGen_v2.5.1" /usr/share/fonts/HackGen
    fc-cache -fv
fi

if ! which fish >/dev/null; then
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt-get update
    sudo apt-get install -y fish
fi
if [[ $(cat /etc/passwd | grep -E "^$(id -un):" | cut -d : -f 7) != $(which fish) ]]; then
    sudo chsh -s "$(which fish)" "$(id -un)"
fi
if ! [[ -f ~/.config/fish/functions/fisher.fish ]]; then
    curl https://raw.githubusercontent.com/jorgebucaran/fisher/HEAD/functions/fisher.fish --create-dirs -Lo ~/.config/fish/functions/fisher.fish
fi
# fish -c 'fisher install oh-my-fish/theme-bobthefish'

uuid='9fd90481-da24-477a-955c-6797762f19d4'
profiles='/org/gnome/terminal/legacy/profiles:'
if ! dconf list "$profiles/" | grep "$uuid" >/dev/null; then
    dconf load "$profiles/:$uuid/" < "$here/../gterminal.preferences"
    dconf write "$profiles/list" "$(dconf read $profiles/list | tr "'" '"' | jq -c ". += [\"$uuid\"]" | tr '"' "'")"
    dconf write "$profiles/default" "'$uuid'"
fi
# echo $list
