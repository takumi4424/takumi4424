################################################################################
start_installing "fish-shell configurations" ###################################
################################################################################
if ! [[ -d ~/.config/fish/conf.d ]]; then
    mkdir -p ~/.config/fish/conf.d
    echo 'created: ~/.config/fish/conf.d'
fi

# 設定ファイルをシンボリックリンクとして配置
ln -sf "$dotfiles/takumi4424.fish" ~/.config/fish/conf.d/takumi4424.fish
echo "creted: symbolic link: ~/.config/fish/conf.d/takumi4424.fish -> $dotfiles/takumi4424.fish"

# プラグインマネージャfisherのインストール
if ! [[ -f ~/.config/fish/functions/fisher.fish ]]; then
    # fisher_url='https://git.io/fisher'
    fisher_url='https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish'
    fish -c "curl -sL '$fisher_url' | source && fisher install jorgebucaran/fisher"
    echo 'installed: fisher'
else
    echo 'not installed: fisher: already installed'
fi

# 指定された名前のfisherプラグインをインストールします
function install_fisher_plugin() {
    if ! fish -c "fisher list '$1'" >/dev/null; then
        fish -c "fisher install '$1'"
        echo "installed: fisher plugin: $1"
    else
        echo "not installed: fisher plugin: $1: already installed"
    fi
}
# 以下、いろんなfisherプラグインのインストール
install_fisher_plugin oh-my-fish/theme-bobthefish

# 指定されたfish補完スクリプトをインストールします
function install_fish_completion() {
    curl -fsSL "$1" --create-dirs -o ~/.config/fish/completions/"$(basename $1)"
}
# 以下、いろんなfish補完スクリプトのインストール
install_fish_completion https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/fish/docker.fish
install_fish_completion https://raw.githubusercontent.com/docker/compose/master/contrib/completion/fish/docker-compose.fish

################################################################################
start_installing "bash-shell configurations" ###################################
################################################################################
function check_and_append() {
    local appendix="if [ -f '$1' ]; then . '$1'; fi"
    if ! grep -F "$appendix" "$2" >/dev/null 2>&1; then
        {
            echo ""
            echo "# source configuration from takumi4424"
            echo "$appendix"
        } >> "$2"
        echo "edited: $2"
    else
        echo "not edited: $2: already configured"
    fi
}
check_and_append "$dotfiles/bashrc"       ~/.bashrc
check_and_append "$dotfiles/bash_profile" ~/.bash_profile

# 指定されたbash補完スクリプトをインストールします
function install_bash_completion() {
    if   $is_macos;  then curl -fsSL "$1" --create-dirs -o "/usr/local/etc/bash_completion.d/$(basename $1)"
    elif $is_ubuntu; then curl -fsSL "$1" --create-dirs -o "/etc/bash_completion.d/$(basename $1)"
    else
        abort 'Error: Unknown platform.'
    fi
}
# 以下、いろんなbash補完スクリプトのインストール
install_bash_completion https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker
install_bash_completion https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose

################################################################################
start_installing 'Git Common Configurations' ###################################
################################################################################
email='57510056+takumi4424@users.noreply.github.com'
name='Takumi Kodama'
autocrlf='false'
if [[ $(git config --global user.email 2>/dev/null) != $email ]]; then
    git config --global user.email "$email"
    echo "configured: email: '$email'"
else
    echo "not configured: email: '$email' already configured"
fi
if [[ $(git config --global user.name 2>/dev/null) != $name ]]; then
    git config --global user.name "$name"
    echo "configured: name: '$name'"
else
    echo "not configured: name: '$name' already configured"
fi
if [[ $(git config --global core.autocrlf 2>/dev/null) != $autocrlf ]]; then
    git config --global core.autocrlf "$autocrlf"
    echo "configured: core.autocrlf: $autocrlf"
else
    echo "not configured: core.autocrlf: $autocrlf already configured"
fi

################################################################################
start_installing "vim" #########################################################
################################################################################
ln -sf "$dotfiles/vimrc" ~/.vimrc
echo "creted: symbolic link: ~/.vimrc -> '$dotfiles/vimrc'"


start_installing 'successfully finished!'
echo 'Please reboot the machine or relogin!'
