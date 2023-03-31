#!/usr/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# いろんな設定用リソース置き場
bindir="$(cd -- "$here/../bin"; pwd)"
dotfiles="$(cd -- "$here/../dotfiles"; pwd)"
# vimプラグインインストール先
vim_bundles="$HOME/.local/share/vim/bundles"

# 設定ファイルをシンボリックリンクとして配置
[[ -d $HOME/.config/fish/conf.d ]] || mkdir -p "$HOME/.config/fish/conf.d"
ln -sf "$dotfiles/takumi4424.fish" "$HOME/.config/fish/conf.d/takumi4424.fish"
ln -sf "$dotfiles/vimrc"           "$HOME/.vimrc"

# dein.vimをインストール
if ! [[ -d $vim_bundles ]]; then
    # See: https://github.com/Shougo/dein-installer.vim/blob/main/installer.sh
    dein_path="$vim_bundles/repos/github.com/Shougo/dein.vim"
    dein_remote="https://github.com/Shougo/dein.vim.git"
    dein_branch="master"
    git init -q "$dein_path"
    (
        cd "$dein_path"
        git config fsck.zeroPaddedFilemode ignore
        git config fetch.fsck.zeroPaddedFilemode ignore
        git config receive.fsck.zeroPaddedFilemode ignore
        git config core.eol lf
        git config core.autocrlf false
        git remote add origin "$dein_remote"
        git fetch --depth=1 origin "$dein_branch"
        git checkout "$dein_branch" -q
    )
fi

# プラグインマネージャfisherのインストール
fisher_url='https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish'
fish -c "curl -sL '$fisher_url' | source && fisher install jorgebucaran/fisher"
# fisherを使ってプラグインのインストール
fish -c "fisher install oh-my-fish/theme-bobthefish"
fish -c "fisher install edc/bass"

# 指定されたfish補完スクリプトをインストールします
function install_fish_completion() {
    curl -fsSL "$1" --create-dirs -o "$HOME/.config/fish/completions/$(basename -- "$1")"
}
# 以下、いろんなfish補完スクリプトのインストール
install_fish_completion https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/fish/docker.fish
install_fish_completion https://raw.githubusercontent.com/docker/compose/master/contrib/completion/fish/docker-compose.fish

# gitの設定
git config --global user.email    '57510056+takumi4424@users.noreply.github.com'
git config --global user.name     'Takumi Kodama'
git config --global core.autocrlf 'false'
# 各プラットフォーム向け設定
is_ubuntu=false
grep 'NAME="Ubuntu"' /etc/os-release &>/dev/null && is_ubuntu=true
if [[ $(uname -s) = 'Darwin' ]]; then
    # macOS
    # .DS_Storeを無視するように設定する
    if ! [[ -d $HOME/.config/git ]]; then
        mkdir -p "$HOME/.config/git"
    fi
    if ! grep '.DS_Store' "$HOME/.config/git/ignore" >/dev/null 2>&1; then
        echo '.DS_Store' >> "$HOME/.config/git/ignore"
    fi
elif $is_ubuntu && grep -i microsoft /proc/version &>/dev/null; then
    # WSL Ubuntu
    # GCMをGitBash同梱のプログラムを使用してやるが、WSLから.exeの実行が遅すぎるのですこし改造
    git config --global credential.helper "$bindir/gcm-helper-for-wsl.sh"
elif $is_ubuntu; then
    # Ubuntu
    :
else
    echo 'Error: Unknown platform.' >&2
    exit 1
fi
