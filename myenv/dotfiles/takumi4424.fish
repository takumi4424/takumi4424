set -x TAKUMI4424_BIN ~/.takumi4424/myenv/bin

if ! echo "$PATH" | grep "$TAKUMI4424_BIN" >/dev/null
    set -x PATH "$TAKUMI4424_BIN" $PATH
end

if test (uname -s) = 'Darwin'
    alias lima_start_docker='limactl start ~/.takumi4424/myenv/lima/docker.yaml'
    set -x DOCKER_HOST 'ssh://lima-docker'
else if grep 'NAME="Ubuntu"' /etc/os-release >/dev/null
    alias open='xdg-open'
    alias pbcopy='xsel --clipboard --input'
end
