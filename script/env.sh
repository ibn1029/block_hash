#!/bin/bash

user=viage
app=block_hash

export HOME=/home/$user
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"
cd ~/work/$app

exec "$@"
