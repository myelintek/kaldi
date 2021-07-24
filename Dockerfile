FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV SHELL /bin/bash
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
ENV DEBIAN_FRONTEND=noninteractive
ARG VERSION
ENV VERSION ${VERSION:-dev}

WORKDIR /mlsteam/lab

ADD clean-layer.sh requirements.txt requirements.system install-sshd.sh set_terminal_dark.sh /tmp/

RUN sed -i 's/archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list && \
    mkdir -p /mlsteam/data && \
    mkdir -p /mlsteam/lab && \
    mkdir -p /mlsteam/lab/kaldi && \
    apt-get update && \
    xargs apt-get install -y < /tmp/requirements.system && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    bash /tmp/install-sshd.sh && \
    bash /tmp/set_terminal_dark.sh && \
    bash /tmp/clean-layer.sh

RUN pip3 install --upgrade https://github.com/myelintek/lib-mlsteam/releases/download/v0.3/mlsteam-0.3.0-py3-none-any.whl

ADD src /mlsteam/lab
ADD bash.bashrc /etc/bash.bashrc

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /opt/kaldi && \
    cd /opt/kaldi/tools && \
    ./extras/install_mkl.sh && \
    make -j $(nproc) && \
    cd /opt/kaldi/src && \
    ./configure --shared --use-cuda && \
    make depend -j $(nproc) && \
    make -j $(nproc) && \
    find /opt/kaldi  -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
    find /opt/intel -type f -name "*.a" -exec rm {} \; && \
    find /opt/intel -type f -regex '.*\(_mc.?\|_mic\|_thread\|_ilp64\)\.so' -exec rm {} \; && \
    rm -rf /opt/kaldi/.git

ADD /opt/kaldi /mlsteam/lab/kaldi
ADD kaldi-for-dummies /mlsteam/data/

RUN cd /mlsteam/lab && \
    jupyter nbconvert --to notebook --inplace --allow-errors --execute entry.ipynb && \
	rm -rf /mlsteam/data/*

RUN rm -rf /usr/lib/x86_64-linux-gnu/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1 /tmp/*

