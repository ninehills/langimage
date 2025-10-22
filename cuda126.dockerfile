FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04

# Build with some basic utilities
RUN apt-get update -q && DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    apt-utils \
    aria2 \
    automake \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    dnsutils \
    fzf \
    gcc \
    gdb \
    gh \
    git \
    git-lfs \
    gnupg2 \
    iproute2 \
    ipset \
    iptables \
    jq \
    less \
    libbz2-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libgl1 \
    libglib2.0-0 \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsm6 \
    libsqlite3-dev \
    libssl-dev \
    libxext6 \
    libxrender1 \
    llvm \
    man-db \
    nginx \
    procps \
    python3-dev \
    silversearcher-ag \
    sudo \
    tk-dev \
    unzip \
    vim \
    wget \
    xz-utils \
    zlib1g-dev \
    zsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R root:root /commandhistory

RUN mkdir -p /workspace
WORKDIR /workspace

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh
# Set the default editor and visual
ENV EDITOR=vim
ENV VISUAL=vim
# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install https://github.com/conda-forge/miniforge
ENV PATH /opt/conda/bin:$PATH
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh && \
    /opt/conda/bin/conda init zsh && \
    /opt/conda/bin/conda install -y -n base -c conda-forge mamba && \
    /opt/conda/bin/mamba install -y -n base -c conda-forge python=3.12 && \
    /opt/conda/bin/mamba clean -afy

# Add other tools
ENV CODE_SERVER_VERSION=4.105.1
RUN mkdir -p code-server && curl -fL https://github.com/coder/code-server/releases/download/v$CODE_SERVER_VERSION/code-server-$CODE_SERVER_VERSION-linux-amd64.tar.gz | tar zxvf /dev/stdin -C code-server --strip-components=1
RUN ./code-server/bin/code-server --install-extension ms-python.python
CMD ["./code-server/bin/code-server", "--auth=password", "--port=8888"]

EXPOSE 8888

