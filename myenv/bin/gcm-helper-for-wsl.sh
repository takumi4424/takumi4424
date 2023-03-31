#!/bin/bash
set -eu
cd /mnt/c/Program\ Files/Git/mingw64

if [[ -f ./bin/git-credential-manager.exe ]]; then
    # Git for Windows >= v2.39.0
    ./bin/git-credential-manager.exe "$@"
elif [[ -f ./bin/git-credential-manager-core.exe ]]; then
    # Git for Windows >= v2.36.1
    ./bin/git-credential-manager-core.exe "$@"
else
    # Git for Windows < v2.36.1
    ./libexec/git-core/git-credential-manager.exe "$@"
fi
