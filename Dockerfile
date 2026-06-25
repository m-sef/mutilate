FROM ubuntu:22.04

WORKDIR /mutilate

COPY . .

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    scons \
    libevent-dev \
    gengetopt \
    libzmq3-dev \
    python2.7 \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -P ~/.local/lib --no-check-certificate https://bootstrap.pypa.io/pip/2.7/get-pip.py \
    && python2.7 ~/.local/lib/get-pip.py --user

RUN python2.7 -m pip install --user scons

RUN python2.7 ~/.local/bin/scons