# ai-env

### 📘 Introduction
This repository provides a ready-to-use setup for building your own AI development environment inside a Docker container. It includes essential tools for machine learning workflows, remote access, and secure communication. Whether you're prototyping deep learning models, running a flexible workspace, this environment is designed to get you started quickly and efficiently.

#### Notice dev only!!!
Because the password is unsafe.  
Username: root  
Password: root

### 🐳 Image Base
This environment is built on top of:  
**nvidia/cuda:12.2.0-runtime-ubuntu22.04**

You are free to change the Docker image tag to suit your needs (e.g., different CUDA versions or base OS), **as long as the image includes CUDA support**.

To verify that your container is correctly using CUDA, you can run:

```bash
nvidia-smi
```
If CUDA is properly installed and the GPU is accessible, this command will display your GPU status and driver version.

### 🧩 Components

#### **1. Jupyter Notebook**
An interactive web-based environment ideal for data analysis, machine learning development, and experimentation.
* Accessible via a configurable port (default: `8889`)
* Runs inside the container with access to shared volumes and GPU acceleration
* Python environment managed by Conda for flexibility

#### **2. Miniconda**
A lightweight Conda installer that allows you to:
* Create and manage Python environments easily
* Install machine learning packages like PyTorch, TensorFlow, scikit-learn, etc.
* Maintain reproducibility via environment files

#### **3. Tailscale**
A secure VPN based on WireGuard that:
Create your key first:
https://login.tailscale.com/admin/settings/keys

* Enables remote access to your container from any device, anywhere
* Authenticates using a Tailscale auth key
* Ideal for private, encrypted networking between machines, especially for remote AI development or federated learning setups

#### **4. SMTP Server Configuration**
Allows the container to send email notifications or status reports through a configured SMTP server.
* Useful for long-running jobs or alerts
* Supports custom SMTP password and email address via environment variables
* Now only support yahoo mail

### 🛠️ Configuration
You should change config in makefile before running your container.

### ⚙️ Parameters
#### Basic
| Variable Name    | Default Value                      |
| ---------------- | ---------------------------------- |
| `SSH_PORT`       | `2222`                             |
| `JUPYTER_PORT`   | `8889`                             |
| `SHM_SIZE`       | `16g`                              |
| `IMAGE_NAME`     | `my-ai-env`                        |
| `TAG`            | `latest`                           |
| `CONTAINER_NAME` | `my-ai-container`                  |
| `VOLUME_PATH`    | `/tmp/docker-container-tmp-volume` |
| `WORKDIR`        | `/workspace`                       |
| `GPUS`           | `all`                              |
| `CUDA_VERSION`   | `11.8.0`                           |
| `PYTHON_VERSION` | `3.12`                             |
| `ENABLE_SSH` | `false`                             |



#### Personal (**must change**)
| Variable Name       | Default Value                                                     |
| ------------------- | ----------------------------------------------------------------- |
| `SSH_PASSWORD` | `"root"`                                     |
| `TAILSCALE_AUTHKEY` | `""`                                     |
| `SMTP_PASSWORD`     | `""`                                                         |
| `EMAIL_ADDRESS`     | `""`                                             |

### 🧾 Command
* Build Image
```
make build
```
* Run image into container
```
make run
```
* Stop container
```
make stop
```
* Remove container
```
make remove
```
* Enter container
```
make enter-container
```