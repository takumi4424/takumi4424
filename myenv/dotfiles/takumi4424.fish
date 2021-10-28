# プログラム置き場
set -x TAKUMI4424_BIN ~/.takumi4424/myenv/bin
# パス通す(重複を防ぎつつ)
if ! echo "$PATH" | grep -F "$TAKUMI4424_BIN" >/dev/null
    set -x PATH "$TAKUMI4424_BIN" $PATH
end

if test (uname -s) = 'Darwin'
    # MacOS用設定
    # alias lima_start_docker='limactl start ~/.takumi4424/myenv/lima/docker.yaml'
    # set -x DOCKER_HOST 'ssh://lima-docker'
else if grep 'NAME="Ubuntu"' /etc/os-release >/dev/null
    # Ubuntu用設定
    alias open='xdg-open'
    alias pbcopy='xsel --clipboard --input'
end

# コマンド補完設定(code-container)
if which code >/dev/null && which docker >/dev/null
    complete -c code-container -d '✔ Container' -x -a '(docker ps --format "{{.Names}}")'
    complete -c code-container -d '⚠ Container' -x -a '(docker ps --format "{{.Names}}" -a --filter "status=exited")'
end
