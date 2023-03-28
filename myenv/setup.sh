#!/usr/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# プログラム置き場
bindir="$(cd -- "$here/bin"; pwd)"
# いろんな設定用リソース置き場
resourcedir="$(cd -- "$here/resources"; pwd)"
dotfiles="$(cd -- "$here/dotfiles"; pwd)"

# 指定された引数をすべてエラー出力し、スクリプトを終了します。
# usage: abort [ERROR_MESSAGE]...
function abort() {
    local arg
    if (( $# > 0 )); then for arg in "$@"; do printf '%s\n' "$arg" >&2; done; fi
    exit 1
}

if   [[ $(uname -s) = 'Darwin' ]];                    then echo "is_macos=true"
elif grep -qi microsoft /proc/version 2>/dev/null;    then echo "is_wsl=true"
elif grep 'NAME="Ubuntu"' /etc/os-release >/dev/null; then echo "is_ubuntu=true"
else
    abort 'Error: Unknown platform.'
fi
