#!/usr/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# セットアップスクリプト置き場
scripts="$(cd -- "$here/scripts"; pwd)"

# Ubuntuかどうかチェック
is_ubuntu=false
grep 'NAME="Ubuntu"' /etc/os-release &>/dev/null && is_ubuntu=true

# 各プラットフォーム向け設定
if [[ $(uname -s) = 'Darwin' ]]; then
    # macOS
    # not tested!!!!!!!
    "$scripts/setup_macos.sh"
    "$scripts/setup_shell.sh"
elif $is_ubuntu && grep -i microsoft /proc/version &>/dev/null; then
    # WSL Ubuntu
    "$scripts/setup_ubuntu_wsl.sh"
    "$scripts/setup_shell.sh"
elif $is_ubuntu; then
    # Ubuntu
    "$scripts/setup_ubuntu.sh"
    "$scripts/setup_shell.sh"
else
    echo 'Error: Unknown platform.' >&2
    exit 1
fi

echo "################################
Setup succeeded!
Recommend:
  - VSCode
  - Google IME
  - Google Chrome
  - HachGen Font"
