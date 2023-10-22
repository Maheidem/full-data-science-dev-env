# Use the latest Debian base image
# FROM debian:latest
# FROM nvidia/cuda:12.2.0-devel-ubuntu20.04
FROM tensorflow/tensorflow:latest-gpu

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    sudo \
    apt \
    openssh-server \
    wget \
    bzip2 \
    libgl1-mesa-glx \
    bzip2 \
    ca-certificates \
    git \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    mercurial \
    openssh-client \
    procps \
    subversion \
    wget \
    htop \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    nload \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Create user "maheidem" and grant it sudo privileges
RUN useradd -m maheidem && echo "maheidem:maheidem" | chpasswd && adduser maheidem sudo
RUN echo 'root:root' | chpasswd
RUN echo "maheidem ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/maheidem && \
    chmod 0440 /etc/sudoers.d/maheidem


# Create privilege separation directory
RUN mkdir -p /run/sshd

# Configure SSHD to accept external connections
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Set bash for maheidem and install bash-completion
RUN chsh -s /bin/bash maheidem && \
    apt-get update && apt-get install -y bash-completion && \
    cp /etc/skel/.bashrc /home/maheidem/ && \
    chown maheidem:maheidem /home/maheidem/.bashrc

# Install Anaconda
ENV PATH /opt/conda/bin:$PATH

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh -q && \
    mkdir -p /opt && \ 
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# Create the 'dev' conda environment with Python 3.10 and desired packages
RUN conda create --name dev python=3.10 pandas ipykernel fastparquet pyarrow scikit-learn numpy scipy matplotlib seaborn jupyter -y

# Create the 'dev' conda environment with Python 3.10 and desired packages
RUN conda create --name tensorflow python=3.11 -y
RUN conda run -n tensorflow pip install --no-input --upgrade pip
RUN conda run -n tensorflow pip install tensorflow[and-cuda]

# Modify bashrc to activate the 'dev' environment by default
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate dev" >> ~/.bashrc

# Install code-server
RUN wget -q https://github.com/cdr/code-server/releases/download/v4.17.1/code-server_4.17.1_amd64.deb && \
    dpkg -i code-server_4.17.1_amd64.deb && \
    rm code-server_4.17.1_amd64.deb

# Install extensions
# RUN code-server --install-extension ms-python.python
# RUN code-server --install-extension ms-toolsai.jupyter
# RUN code-server --install-extension ms-toolsai.vscode-jupyter-cell-tags
# RUN code-server --install-extension eamodio.gitlens
# RUN code-server --install-extension ms-vscode-remote.remote-containers
# RUN code-server --install-extension tonybaloney.vscode-pets
# RUN code-server --install-extension vscode.git
# RUN code-server --install-extension ms-vscode.remote-server
# RUN code-server --install-extension GrapeCity.gc-excelviewer
# RUN code-server --install-extension vscode.github-authentication
# RUN code-server --install-extension ms-vscode-remote.remote-wsl-recommender
# RUN code-server --install-extension ms-vscode-remote.remote-wsl
# RUN code-server --install-extension vscode.merge-conflict
# RUN code-server --install-extension vscode.github
# RUN code-server --install-extension ms-azuretools.azure-dev
# RUN code-server --install-extension ms-vscode.azure-account
# RUN code-server --install-extension ms-dotnettools.vscode-dotnet-runtime
# RUN code-server --install-extension ms-toolsai.vscode-ai
# RUN code-server --install-extension ms-azuretools.vscode-azurestorage
# RUN code-server --install-extension ms-azuretools.vscode-bicep
# RUN code-server --install-extension phplasma.csv-to-table
# RUN code-server --install-extension ms-azuretools.vscode-docker
# RUN code-server --install-extension Meezilla.json
# RUN code-server --install-extension ms-toolsai.vscode-jupyter-slideshow
# RUN code-server --install-extension ms-toolsai.jupyter-renderers
# RUN code-server --install-extension ms-vscode.powershell
# RUN code-server --install-extension mohsen1.prettify-json
# RUN code-server --install-extension ms-python.vscode-pylance
# RUN code-server --install-extension redhat.vscode-yaml
# RUN code-server --install-extension slevesque.vscode-zipexplorer

# Add a script to start both SSH and code-server
COPY start_services.sh /start_services.sh
RUN chmod +x /start_services.sh

# Expose the SSH port
EXPOSE 22
# Expose the code-server port
EXPOSE 8080

# Define default command.
CMD ["/start_services.sh"]

