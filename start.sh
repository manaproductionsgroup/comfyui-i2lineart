#!/bin/bash

# You can make modifications to this file if you want to customize the startup process.
# Things like installing additional custom nodes, or downloading models can be done here.

/comfyui-on-workspace.sh

service nginx start

bash /download_files.sh

# Start JupyterLab
echo "Starting JupyterLab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.allow_origin='*' &
echo "JupyterLab started."
echo "REMEMBER TO ACCESS YOU HAVE TO COPY/PASTE THE TOKEN ACCESS -> ?lab&token="

echo "Starting FileBrowser..."
filebrowser --address=0.0.0.0 --port=4040 --root=/ --noauth &
echo "FileBrowser started."

# Launch the UI
echo "Starting ComfyUI..."
python3 /workspace/ComfyUI/main.py --listen

# Keep the container running indefinitely
sleep infinity
