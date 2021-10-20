################################################################################
start_installing "fish-shell configurations" ###################################
################################################################################
if ! [[ -d ~/.config/fish/conf.d ]]; then
    mkdir -p ~/.config/fish/conf.d
    echo 'created: ~/.config/fish/conf.d'
fi
# 設定ファイルをシンボリックリンクとして配置
ln -sf "$fish_conf_d/takumi4424.fish" ~/.config/fish/conf.d/takumi4424.fish
echo "creted: symbolic link: ~/.config/fish/conf.d/takumi4424.fish -> $dotfiledir/takumi4424.fish"
# プラグインマネージャfisherのインストール
if ! [[ -f ~/.config/fish/functions/fisher.fish ]]; then
    # fisher_url='https://git.io/fisher'
    fisher_url='https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish'
    curl "$fisher_url" --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    echo 'installed: fisher'
else
    echo 'not installed: fisher: already installed'
fi
# 以下、いろんなプラグインのインストール
function install_fisher_plugin() {
    if ! fish -c "fisher list '$1'" >/dev/null; then
        fish -c "fisher install '$1'"
        echo "installed: fisher plugin: $1"
    else
        echo "not installed: fisher plugin: $1: already installed"
    fi
}
install_fisher_plugin oh-my-fish/theme-bobthefish

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
ln -sf "$dotfiledir/vimrc" ~/.vimrc
echo "creted: symbolic link: ~/.vimrc -> '$dotfiledir/vimrc'"


start_installing 'successfully finished!'
echo 'Please reboot the machine or relogin!'
