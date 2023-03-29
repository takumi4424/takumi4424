#!/usr/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# いろんな設定用リソース置き場
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
# macOS用の無視するファイル追加
[[ -d $HOME/.config/git ]] || mkdir -p "$HOME/.config/git"
if ! grep '.DS_Store' "$HOME/.config/git/ignore" >/dev/null 2>&1; then
    echo '.DS_Store' >> "$HOME/.config/git/ignore"
fi
