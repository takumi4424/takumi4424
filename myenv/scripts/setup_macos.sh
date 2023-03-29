#!/bin/bash
set -eu
# 共通の設定
here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
source "$here/setup_common_pre.bash"

# Homebrew自体のインストール
if ! which brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# いろいろインストール
brew install \
    fish \
    git \
    jq \
    vim

# ターミナルプロファイルの設定
if ! [[ $(defaults read com.apple.terminal "Default Window Settings" 2>/dev/null) == "Iceberg@takumi4424" ]]; then
    open "$resourcedir/Iceberg@takumi4424.terminal"
    defaults write com.apple.terminal "Default Window Settings" "Iceberg@takumi4424"
fi

# Finderサイドバーの設定？など
fname="com.apple.LSSharedFileList.FavoriteItems.sfl2"
targetdir="$HOME/Library/Application Support/com.apple.sharedfilelist"
if ! [[ -f $targetdir/$fname ]]; then
    # ファイルが見つからない(なぜ？)
    cp "$resourcedir/$fname" "$targetdir"
elif [[ $(shasum -a 512 "$targetdir/$fname" | cut -f 1 -d ' ') != $(shasum -a 512 "$resourcedir/$fname" | cut -f 1 -d ' ') ]]; then
    # ファイルの内容が違う
    cp "$resourcedir/$fname" "$targetdir"
fi

################################################################################
############################## その他システム設定 ##############################
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
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots/" # スクリーンキャプチャ保存先設定
[[ -d $HOME/Pictures/Screenshots ]] || mkdir "$HOME/Pictures/Screenshots"     # 保存先ディレクトリがなければ作成
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
