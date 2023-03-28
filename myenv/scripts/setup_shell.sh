#!/usr/bin/bash
set -eu

# このスクリプトがあるディレクトリ
here="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")"; pwd)"
# いろんな設定用リソース置き場
dotfiles="$(cd -- "$here/../dotfiles"; pwd)"

# 設定ファイルをシンボリックリンクとして配置
ln -sf "$dotfiles/takumi4424.fish" ~/.config/fish/conf.d/takumi4424.fish
ln -sf "$dotfiles/vimrc"           ~/.vimrc

# プラグインマネージャfisherのインストール
fisher_url='https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish'
fish -c "curl -sL '$fisher_url' | source && fisher install jorgebucaran/fisher"
# fisherを使ってプラグインのインストール
fish -c "fisher install oh-my-fish/theme-bobthefish"

# 指定されたfish補完スクリプトをインストールします
function install_fish_completion() {
    curl -fsSL "$1" --create-dirs -o ~/.config/fish/completions/"$(basename $1)"
}
# 以下、いろんなfish補完スクリプトのインストール
install_fish_completion https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/fish/docker.fish
install_fish_completion https://raw.githubusercontent.com/docker/compose/master/contrib/completion/fish/docker-compose.fish

# gitの設定
git config --global user.email    '57510056+takumi4424@users.noreply.github.com'
git config --global user.name     'Takumi Kodama'
git config --global core.autocrlf 'false'
# macOS用の無視するファイル追加
[[ -d ~/.config/git ]] || mkdir -p ~/.config/git
if ! grep '.DS_Store' ~/.config/git/ignore >/dev/null 2>&1; then
    echo '.DS_Store' >> ~/.config/git/ignore
fi
