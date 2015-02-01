#!/bin/bash
env MOJO_MODE=production carton exec -- start_server --port 5000 -- starman script/block_hash --max-wokers 3
#env MOJO_MODE=production \
#carton exec plackup -s starman --max-wokers 3 --port 5000 -D -a script/block_hash
