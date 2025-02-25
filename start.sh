#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Serve the API and don't shutdown the container
if [ "$SERVE_API_LOCALLY" == "true" ]; then
    echo "rvcv2-runpod: Starting RVC-v2-UI"
    python3 /RVC-v2-UI/src/webui.py

    echo "rvcv2-runpod: Starting Runpod Handler"
    python3 -u /rp_handler.py
else
    echo "rvcv2-runpod: Starting RVC-v2-UI"
    python3 /RVC-v2-UI/src/webui.py

   echo "rvcv2-runpod: Starting Runpod Handler"
    python3 -u /rp_handler.py
fi