# プログラム置き場
fish_add_path "$HOME/.takumi4424/myenv/bin"

if test (uname -s) = 'Darwin'
    # MacOS用設定
else if grep -qi microsoft /proc/version 2>/dev/null
    # WSLの場合
    # .exeの実行が大変遅い（10秒くらい）なので、小細工
    alias pbcopy='bash -c "cd /mnt/c/; clip.exe"'
else if grep 'NAME="Ubuntu"' /etc/os-release >/dev/null
    # Ubuntu用設定
    alias sudo='sudo -E'
    alias open='xdg-open'
    alias pbcopy='xsel --clipboard --input'
end

# コマンド補完設定(code-container)
if which code >/dev/null && which docker >/dev/null
    complete -c code-container -d '✔ Container' -x -a '(docker ps --format "{{.Names}}")'
    complete -c code-container -d '⚠ Container' -x -a '(docker ps --format "{{.Names}}" -a --filter "status=exited")'
end
