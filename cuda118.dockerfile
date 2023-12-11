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
&& rm -rf /var/lib/apt/lists/*


RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# build with some basic python packages
RUN --mount=type=cache,target=/root/.cache \
    pip install \
    numpy \
    pandas \
    jupyterlab

RUN --mount=type=cache,target=/root/.cache \
    pip install \
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
    qdrant-client

RUN --mount=type=cache,target=/root/.cache \
    pip install \
    protobuf \
    "transformers<4.35.0" \
    cpm_kernels \
    gradio mdtex2html sentencepiece accelerate \
    deepspeed


RUN git clone https://github.com/hiyouga/LLaMA-Factory.git && cd LLaMA-Factory && pip install -U -r requirements.txt

# Build with some basic utilities
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
&& rm -rf /var/lib/apt/lists/*


# Add other tools
ENV CODE_SERVER_VERSION=4.18.0
RUN mkdir -p code-server && curl -fL https://github.com/coder/code-server/releases/download/v$CODE_SERVER_VERSION/code-server-$CODE_SERVER_VERSION-linux-amd64.tar.gz | tar zxvf /dev/stdin -C code-server --strip-components=1

RUN --mount=type=cache,target=/root/.cache pip install bitsandbytes tqdm scipy scikit-learn
# start jupyter lab

RUN --mount=type=cache,target=/root/.cache pip install -U xformers --index-url https://download.pytorch.org/whl/cu118
RUN --mount=type=cache,target=/root/.cache pip install --use-deprecated=legacy-resolver "pydantic>2.5" https://github.com/vllm-project/vllm/releases/download/v0.2.3/vllm-0.2.3+cu118-cp311-cp311-manylinux1_x86_64.whl

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]

EXPOSE 8888
