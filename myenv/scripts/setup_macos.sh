#!/bin/bash
set -eu
# 共通の設定
here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
source "$here/setup_common_pre.bash"

################################################################################
####################### デスクトップアプリケーション関連 #######################
################################################################################
# function is_app_installed() {
#     local appdir=/Applications
#     local app
#     while read app; do
#         if [[ $app =~ ^$appdir/$1 ]]; then return 0; fi
#     done < <(find "$appdir" -type d -maxdepth 1)
#     return 1
# }

# if is_app_installed "GoogleJapaneseInput"; then echo "nihogn installed!"; else echo "not installed"; fi

# exit

################################################################################
################################### ホスト名 ###################################
################################################################################
# hostname=
# sudo scutil --set LocalHostName "$hostname"
# sudo scutil --set ComputerName  "$hostname"
# # flush the DNS cache
# dscacheutil -flushcache

################################################################################
start_installing 'Homebrew packages' ###########################################
################################################################################
# Homebrewでインストールするソフトウェアのリスト
pkgs=(
    fish
    dialog
    jq
    lima
)

# Homebrew自体のインストール
if ! which brew >/dev/null; then
    start_installing_sub "installing homebrew itself..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo '----------------'
fi

# インストール済みソフトウェアの確認
installed_pkgs=( $(brew list) )
# 未インストールソフトの抽出
uninstalled_pkgs=()
for pkg in "${pkgs[@]}"; do
    array_contains 'installed_pkgs' "$pkg" || uninstalled_pkgs+=("$pkg")
done

# 未インストールソフトのインストール
if (( ${#uninstalled_pkgs[@]} > 0 )); then
    start_installing_sub "installing brew packages..."
    brew install "${uninstalled_pkgs[@]}"
    echo '----------------'
fi

# インストールの実施状態表示
for pkg in "${pkgs[@]}"; do
    if array_contains 'installed_pkgs' "$pkg"; then
        echo "not installed: $pkg: already installed"
    else
        echo "installed: $pkg"
    fi
done

################################################################################
start_installing 'Fonts' #######################################################
################################################################################
# 白源
if ! [[ -d /Library/Fonts/HackGen ]]; then
    url='https://github.com/yuru7/HackGen/releases'
    pattern="<html><body>You are being <a href=\"$url/tag/(.+)\">redirected</a>\.</body></html>"
    if [[ $(curl -s $url/latest) =~ ^$pattern$ ]]; then
        # 最新のHackGenフォントをダウンロード
        version="${BASH_REMATCH[1]}"
        curl -Lo "$tempdir/HackGen.zip" "$url/download/$version/HackGen_$version.zip"
        unzip "$tempdir/HackGen.zip" -d "$tempdir"
        mv "$tempdir/HackGen_$version" /Library/Fonts/HackGen
        echo '---'
        echo 'successfully installed.'
    else
        abort 'Error: Failed to install HackGen font...'
    fi
else
    echo 'already installed.'
fi

################################################################################
start_installing 'LIMA' ########################################################
################################################################################
if ! grep 'Host lima-docker' ~/.ssh/config >/dev/null 2>&1; then
    {
        echo 'Host lima-docker'
        echo '    NoHostAuthenticationForLocalhost yes'
        echo '    HostName 127.0.0.1'
        echo '    Port 60022'
        echo '    IdentityFile ~/.lima/_config/user'
    } >> ~/.ssh/config
    echo 'edited: ~/.ssh/config: Host lima-docker appended'
else
    echo 'not edited: ~/.ssh/config: Host lima-docker already exists'
fi

################################################################################
start_installing 'Git Configurations for MacOS' ################################
################################################################################
if ! [[ -d ~/.config/git ]]; then
    mkdir -p ~/.config/git
    echo 'created: ~/.config/git'
fi
if ! grep '.DS_Store' ~/.config/git/ignore >/dev/null 2>&1; then
    echo '.DS_Store' >> ~/.config/git/ignore
    echo 'edited: ~/.config/git/ignore: ".DS_Store" appended'
else
    echo 'edited: ~/.config/git/ignore: ".DS_Store" already exists'
fi

################################################################################
start_installing 'System Preferences' ##########################################
################################################################################
# Dock関連
echo '- Dock'
defaults write com.apple.dock autohide -bool true               # Dockを自動的に表示/非表示
defaults write com.apple.dock show-recents -bool false          # 最近使ったアプリケーションをDockに表示しない
# トラックパッドの右下隅をクリックで副ボタンのクリック
echo '- Trackpad'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
# Finder
echo '- Finder'
defaults write NSGlobalDomain AppleShowAllExtensions -bool true               # すべての拡張子を表示
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false    # 拡張子変更時の警告を無効化する
defaults write com.apple.finder FinderSpawnTab -bool false                    # フォルダを新規ウインドウではなくタブで開く
defaults write com.apple.finder NewWindowTarget -string "PfHm"                # 新規Finderウィンドウで次を表示:ホームフォルダ
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true  # ネットワークデバイスには.DSStoreを書き込まない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true      # USBデバイスには.DSStoreを書き込まない
# メニューバーにTimeMachineを表示
echo '- Menubar'
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
# ScreenCapture
echo '- Screen Capture'
defaults write com.apple.screencapture “disable-shadow”-bool yes            # スクリーンキャプチャ時にウィンドウに影をつけない
defaults write com.apple.screencapture name Screenshot                        # 名前は"Screenshot*.png"
defaults write com.apple.screencapture location ~/Pictures/Screenshots/       # スクリーンキャプチャ保存先設定
[[ -d ~/Pictures/Screenshots ]] || mkdir ~/Pictures/Screenshots               # 保存先ディレクトリがなければ作成
# キーボード関連
echo '- Keyboard'
defaults write -g KeyRepeat -int 2                                            # キーリピート速度(早め)
defaults write -g InitialKeyRepeat -int 15                                    # リピート入力認識までの時間(早め)
# キーボードショートカットの設定用関数
function edit_hotkey() {
    # 参考:
    #   https://qiita.com/ry0f/items/f2c75f0a77b1012182d6
    #   https://apple.stackexchange.com/questions/91679/is-there-a-way-to-set-an-application-shortcut-in-the-keyboard-preference-pane-vi
    xml="<dict><key>enabled</key><$2/><key>value</key><dict><key>parameters</key><array><integer>$3</integer><integer>$4</integer><integer>$5</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $1 "$xml"
}
# キーボードショートカットの設定
echo '- Keyboard Shortcut'
edit_hotkey 160 true  97    0  524288  # [Alt-A]     Launchpad
edit_hotkey 60  true  32    49 1048576 # [Cmd-Space] 前の入力ソースを選択
edit_hotkey 64  false 65535 49 1048576 #             Spotlightのショートカットが重複するので無効化(Command+Space)

################################################################################
start_installing 'Other Applications' ##########################################
################################################################################
# ターミナルプロファイルの設定
if ! [[ $(defaults read com.apple.terminal "Default Window Settings" 2>/dev/null) == "Iceberg@takumi4424" ]]; then
    open "$resourcedir/Iceberg@takumi4424.terminal"
    defaults write com.apple.terminal "Default Window Settings" "Iceberg@takumi4424"
    echo '- Terminal profile installed'
else
    echo '- Terminal profile already installed'
fi
# Finderサイドバーの設定？など
fname="com.apple.LSSharedFileList.FavoriteItems.sfl2"
targetdir="$HOME/Library/Application Support/com.apple.sharedfilelist"
if ! [[ -f $targetdir/$fname ]]; then
    # ファイルが見つからない(なぜ？)
    cp "$resourcedir/$fname" "$targetdir"
    echo '- Finder sidebar settings installed'
elif [[ $(shasum -a 512 "$targetdir/$fname" | cut -f 1 -d ' ') != $(shasum -a 512 "$resourcedir/$fname" | cut -f 1 -d ' ') ]]; then
    # ファイルの内容が違う
    cp "$resourcedir/$fname" "$targetdir"
    echo '- Finder sidebar settings installed'
else
    echo '- Finder sidebar settings already installed'
fi

################################################################################
################################### Fish関連 ###################################
################################################################################
# pattern="UserShell: $(which fish)"
# if ! [[ $(dscl . -read /Users/$USER UserShell) =~ ^$pattern$ ]]; then
#     # デフォルトシェルがfishじゃない場合はセットアップ
#     if ! cat /etc/shells | grep -E "^$(which fish)$" >/dev/null; then
#         echo "$(which fish)" | sudo tee -a /etc/shells >/dev/null
#     fi
#     chsh -s "$(which fish)"
# fi



# 終わりに
source "$here/setup_common_post.bash"
