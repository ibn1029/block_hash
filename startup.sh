#!/bin/bash
MOJO_MODE=production carton exec -- start_server --port 5000 -- plackup -s Starman -a script/block_hash
