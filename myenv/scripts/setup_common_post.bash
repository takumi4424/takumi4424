################################################################################
################################### Fish関連 ###################################
################################################################################
if ! [[ -d ~/.config/fish/conf.d ]]; then
    mkdir -p ~/.config/fish/conf.d
fi
# 設定ファイルをシンボリックリンクとして配置
if ! [[ -L ~/.config/fish/conf.d/takumi4424.fish ]]; then
    ln -s "$(cd "${here}/.."; pwd)/takumi4424.fish" ~/.config/fish/conf.d/takumi4424.fish
fi
# プラグインマネージャfisherのインストール
if ! [[ -f ~/.config/fish/functions/fisher.fish ]]; then
    # fisher_url='https://git.io/fisher'
    fisher_url='https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish'
    curl "$fisher_url" --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fi
# 以下、いろんなプラグインのインストール
function install_fisher_plugin() { fish -c "fisher list '$1'" >/dev/null || fish -c "fisher install '$1'"; }
install_fisher_plugin oh-my-fish/theme-bobthefish
