#!/bin/bash
env MOJO_MODE=production carton exec -- start_server --port 5000 -- starman script/block_hash --wokers 10
