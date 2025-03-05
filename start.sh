#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Start RVC-v2-UI
echo "rvcv2-runpod: Starting RVC-v2-UI"
python3 /RVC-v2-UI/src/webui.py &

# Start Runpod Handler
echo "rvcv2-runpod: Starting Runpod Handler"
python3 -u /rp_handler.py &

# Keep the script running until all background processes are done
wait