#!/usr/bin/bash

# 指定された引数をすべてエラー出力し、スクリプトを終了します。
# usage: abort [ERROR_MESSAGE]...
function abort() {
    local arg
    if (( $# > 0 )); then for arg in "$@"; do printf '%s\n' "$arg" >&2; done; fi
    exit 1
}

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# プログラム置き場
bindir="$(cd -- "$here/bin"; pwd)"
# いろんな設定用リソース置き場
resourcedir="$(cd -- "$here/resources"; pwd)"
dotfiles="$(cd -- "$here/dotfiles"; pwd)"

# セットアップに使用する一時ディレクトリの作成
if ! tempdir="$(mktemp -d)"; then
    abort 'Error: Failed to create a temporary working directory.'
fi
# 終了時に一時ディレクトリを削除する
trap 'rm -rf "$tempdir"' 0 1 2 3 15

is_macos=false
is_wsl=false
is_ubuntu=false
if   [[ $(uname -s) = 'Darwin' ]];                    then echo "is_macos=true"
elif grep -qi microsoft /proc/version 2>/dev/null;    then echo "is_wsl=true"
elif grep 'NAME="Ubuntu"' /etc/os-release >/dev/null; then echo "is_ubuntu=true"
else
    abort 'Error: Unknown platform.'
fi
