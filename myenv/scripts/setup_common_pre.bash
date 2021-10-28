################################################################################
################################### 関数定義 ###################################
################################################################################
# 指定された引数をすべてエラー出力し、スクリプトを終了します。
# usage: abort [ERROR_MESSAGE]...
function abort() {
    local arg
    if (( $# > 0 )); then for arg in "$@"; do printf '%s\n' "$arg" >&2; done; fi
    exit 1
}

# 指定された値が配列に含まれるかどうかをチェックします。
function array_contains() {
    local __arr__ elem
    eval __arr__=("\"\${$1[@]+\"\${$1[@]}\"}\"")
    for elem in "${__arr__[@]+"${__arr__[@]}"}"; do [[ $elem == $2 ]] && return 0; done
    return 1
}

function start_installing() {
    local cols linelen_l linelen_r
    # cols="$(tput cols)"
    cols="80"
    linelen_l="$(( (cols - ${#1} - 2) / 2 ))"
    linelen_r="$(( cols - ${#1} -2 - linelen_l ))"
    printf -- "${2:-#}%.s" $(seq ${linelen_l})
    printf -- ' %s ' "$1"
    printf -- "${2:-#}%.s" $(seq ${linelen_r})
    echo
}

function start_installing_sub() {
    start_installing "$1" '-'
}

# # 指定されたバージョン文字列の、メジャーバージョン部分を整数として主力します。
# # もし見つからない場合、第2引数もしくは0を出力します。
# # usage: get_major VERSION_STRING [DEFAULT]
# function get_major() { [[ $1 =~ ^([0-9]+) ]]                 && echo $(( 10#${BASH_REMATCH[1]} )) || echo "${2:-0}"; }
# # 指定されたバージョン文字列の、マイナーバージョン部分を整数として主力します。
# # もし見つからない場合、第2引数もしくは0を出力します。
# # usage: get_major VERSION_STRING [DEFAULT]
# function get_minor() { [[ $1 =~ ^[0-9]+\.([0-9]+) ]]         && echo $(( 10#${BASH_REMATCH[1]} )) || echo "${2:-0}"; }
# # 指定されたバージョン文字列の、パッチバージョン部分を整数として主力します。
# # もし見つからない場合、第2引数もしくは0を出力します。
# # usage: get_major VERSION_STRING [DEFAULT]
# function get_patch() { [[ $1 =~ ^[0-9]+\.[0-9]+\.([0-9]+) ]] && echo $(( 10#${BASH_REMATCH[1]} )) || echo "${2:-0}"; }

################################################################################
############################### ディレクトリ関連 ###############################
################################################################################
# このスクリプトがあるディレクトリ
here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
# プログラム置き場
bindir="$(cd "$here"/../bin; pwd)"
# いろんな設定用リソース置き場
resourcedir="$(cd "$here"/../resources; pwd)"
dotfiles="$(cd "$here"/../dotfiles; pwd)"

################################################################################
#################################### OS識別 ####################################
################################################################################
is_macos=false
is_ubuntu=false
if   [[ $(uname -s) = 'Darwin' ]];                    then is_macos=true
elif grep 'NAME="Ubuntu"' /etc/os-release >/dev/null; then is_ubuntu=true
else
    abort 'Error: Unknown platform.'
fi

# セットアップに使用する一時ディレクトリの作成
if ! tempdir="$(mktemp -d)"; then
    abort 'Error: Failed to create a temporary working directory.'
fi
# 終了時に一時ディレクトリを削除する
trap 'rm -rf "$tempdir"' 0 1 2 3 15
