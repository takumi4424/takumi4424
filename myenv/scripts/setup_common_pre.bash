################################################################################
################################### 関数定義 ###################################
################################################################################
# 指定された引数をすべてエラー出力し、スクリプトを終了します。
# usage: abort [ERROR_MESSAGE]...
function abort() {
    if (( $# > 0 )); then for arg in "$@"; do printf '%s\n' "$arg" >&2; done; fi
    exit 1
}

# 指定された値が配列に含まれるかどうかをチェックします。
function array_contains() {
    local target="$1"
    shift
    local element
    # inが無いforは暗黙的に引数を繰り返す
    for element; do [[ $element == $target ]] && return 0; done
    return 1
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

# セットアップに使用する一時ディレクトリの作成
if ! tempdir="$(mktemp -d)"; then
    abort 'Error: Failed to create a temporary working directory.'
fi
# 終了時に一時ディレクトリを削除する
trap 'rm -rf "$tempdir"' 0 1 2 3 15

################################################################################
################################### Git関連 ####################################
################################################################################
if ! git config --list --global >/dev/null 2>&1; then
    git config --global user.email '57510056+takumi4424@users.noreply.github.com'
    git config --global user.name 'Takumi Kodama'
    git config --global core.autocrlf false
fi
