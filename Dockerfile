FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Set environment variables
ENV PYTHONWARNINGS="ignore" \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive 

# Set the working directory
WORKDIR /workspace

# Set up noninteractive mode for debconf
RUN apt-get update && \
    echo "msmtp/msmtp_app_armor_support boolean false" | debconf-set-selections && \
    apt-get install -y \
      htop \
      wget \
      curl \
      bzip2 \
      ca-certificates \
      libglib2.0-0 \
      libxext6 \
      libsm6 \
      libxrender1 \
      git \
      openssh-server \
      msmtp \
      msmtp-mta \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh

# Create conda environment
RUN conda create -n myenv python=3.12 -y && \
    echo "source $CONDA_DIR/etc/profile.d/conda.sh && conda activate myenv" >> ~/.bashrc

# Set up SSH server
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install Application
RUN curl -fsSL https://tailscale.com/install.sh | sh && \
    /opt/conda/bin/conda install -n myenv jupyterlab -y

# Expose SSH and JupyterLab ports
EXPOSE 22
EXPOSE 8888

# Copy startup script into the image
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Default command to run services
CMD ["/start.sh"]
