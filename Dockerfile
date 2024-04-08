FROM ubuntu:22.04

WORKDIR /root

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
  ca-certificates \
  wget \
  curl \
  gnupg \
  ripgrep \
  ltrace \
  file\
  python3-minimal \
  build-essential \
  git \
  cmake \
  ninja-build \
  jq
ENV PATH="${PATH}:/usr/local/cuda/bin"

ARG CUDA_VERSION=12-3
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
  dpkg -i cuda-keyring_1.0-1_all.deb && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  nvidia-headless-no-dkms-515 \
  nvidia-utils-515 \
  cuda-cudart-${CUDA_VERSION} \
  cuda-compiler-${CUDA_VERSION} \
  libcufft-dev-${CUDA_VERSION} \
  libcusparse-dev-${CUDA_VERSION} \
  libcublas-dev-${CUDA_VERSION} \
  cuda-nvml-dev-${CUDA_VERSION} \
  libcudnn8-dev

ARG RUST_VERSION=1.77.1
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=${RUST_VERSION}
RUN . $HOME/.cargo/env && cargo install bindgen-cli --locked

ARG QLI_VERSION="1.9.0"
ENV QLI_VERSION=$QLI_VERSION
COPY run.sh .
RUN wget https://dl.qubic.li/downloads/qli-Client-${QLI_VERSION}-Linux-x64.tar.gz && \
    tar xf qli-Client-${QLI_VERSION}-Linux-x64.tar.gz && \
    chmod +x qli-Client

CMD ["./run.sh"]
