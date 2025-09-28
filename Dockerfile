ARG DOCKER_FROM=nvidia/cuda:12.8.0-runtime-ubuntu22.04

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM AS base

# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs wget vim zip unzip curl && \
    python3 -m pip install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx

# Install custom_node dependency libGL.so
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 -y

# Copy the 'default' configuration file to the appropriate location
COPY default /etc/nginx/sites-available/default

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install pytorch
RUN pip3 install --no-cache-dir -U torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

COPY --chmod=755 start.sh /start.sh

# Clone the git repo and install requirements in the same RUN command to ensure they are in the same layer
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip3 install -r requirements.txt && \
    cd custom_nodes && \
    git clone https://github.com/ltdrdata/was-node-suite-comfyui.git && \
    git clone https://github.com/chflame163/ComfyUI_LayerStyle.git && \
    git clone https://github.com/calcuis/gguf && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd /ComfyUI

COPY --chmod=644 i2lineart_qwen_image_edit.json /ComfyUI/user/default/workflows/

WORKDIR /workspace
EXPOSE 8188

# Add Jupyter Notebook
RUN pip3 install jupyterlab
EXPOSE 8888

# Install filebrowser
RUN curl -LsSf https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
EXPOSE 4040

# Add download scripts for additional models
COPY --chmod=755 download_files.sh /download_files.sh
COPY --chmod=755 comfyui-on-workspace.sh /comfyui-on-workspace.sh

# ComfyUI-Manager
RUN cd /ComfyUI/custom_nodes && \
    cd ComfyUI-Manager && \
    pip3 install -r requirements.txt

# was-node-suite-comfyui
RUN cd /ComfyUI/custom_nodes && \
    cd was-node-suite-comfyui && \
    pip3 install -r requirements.txt

# ComfyUI-Easy-Use
RUN cd /ComfyUI/custom_nodes && \
    cd ComfyUI-Easy-Use && \
    pip3 install -r requirements.txt

# ComfyUI_LayerStyle
RUN cd /ComfyUI/custom_nodes && \
    cd ComfyUI_LayerStyle && \
    pip3 install -r requirements.txt

# rgthree-comfy
RUN cd /ComfyUI/custom_nodes && \
    cd rgthree-comfy && \
    pip3 install -r requirements.txt

# ComfyUI-KJNodes
RUN cd /ComfyUI/custom_nodes && \
    cd ComfyUI-KJNodes && \
    pip3 install -r requirements.txt


CMD [ "/start.sh" ]
