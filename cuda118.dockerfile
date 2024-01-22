FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Set bash as the default shell
ENV SHELL=/bin/bash

# Create a working directory
WORKDIR /app/

# Build with some basic utilities
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    vim \
    git \
    build-essential \
    wget \
    curl \
    libsqlite3-dev \
    automake \
    nginx \
    gdb \
    silversearcher-ag \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://pyenv.run | bash
ENV HOME  /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install 3.11
RUN pyenv global 3.11
RUN pyenv rehash

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip

RUN --mount=type=cache,target=/root/.cache \
    pip3 install torch xformers --index-url https://download.pytorch.org/whl/cu118

RUN git clone https://github.com/hiyouga/LLaMA-Factory.git

# build with some basic python packages
RUN --mount=type=cache,target=/root/.cache \
    pip install --use-deprecated=legacy-resolver \
    numpy \
    pandas \
    jupyterlab \
    FlagEmbedding \
    langchain \
    qianfan \
    PyYAML \
    FastAPI \
    uvicorn \
    huggingface-hub[cli] \
    datasets \
    jinja2 \
    langeval-cli \
    qdrant-client \
    protobuf \
    transformers \
    cpm_kernels \
    gradio mdtex2html sentencepiece accelerate \
    bitsandbytes tqdm scipy scikit-learn \
    deepspeed \
    "pydantic>2.5" \
    "https://github.com/vllm-project/vllm/releases/download/v0.2.7/vllm-0.2.7+cu118-cp311-cp311-manylinux1_x86_64.whl" \
    openllm \
    && cd LLaMA-Factory && pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache \
    pip install https://github.com/casper-hansen/AutoAWQ/releases/download/v0.1.8/autoawq-0.1.8+cu118-cp311-cp311-linux_x86_64.whl && \
    pip install --upgrade auto-gptq --extra-index-url https://huggingface.github.io/autogptq-index/whl/cu118/ &&\ 
    pip install onnxruntime onnxruntime-gpu

# Add other tools
ENV CODE_SERVER_VERSION=4.18.0
RUN mkdir -p code-server && curl -fL https://github.com/coder/code-server/releases/download/v$CODE_SERVER_VERSION/code-server-$CODE_SERVER_VERSION-linux-amd64.tar.gz | tar zxvf /dev/stdin -C code-server --strip-components=1

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]

EXPOSE 8888
