set -x PATH ~/.takumi4424/myenv/bin $PATH

if test (uname -s) = 'Darwin'
    alias lima_start_docker='limactl start ~/.takumi4424/myenv/lima/docker.yaml'
    set -x DOCKER_HOST 'ssh://lima-docker'
else if grep 'NAME="Ubuntu"' /etc/os-release >/dev/null
    alias open='xdg-open'
    alias pbcopy='xsel --clipboard --input'
end
