FROM ubuntu:22.04 AS base

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc-riscv64-linux-gnu \
    iverilog \
    libboost-filesystem1.74.0 \
    libboost-iostreams1.74.0 \
    libboost-program-options1.74.0 \
    libboost-thread1.74.0 \
    libftdi1 \
    libpython3.10 \
    libssl-dev \
    make \
    python3-pip \
    python3.10 \
    wget \
    && rm -rf /var/lib/apt/lists/*

FROM base AS build-deps

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bison \
    build-essential \
    clang \
    cmake \
    flex \
    git \
    libboost-filesystem1.74-dev \
    libboost-iostreams1.74-dev \
    libboost-program-options1.74-dev \
    libboost-thread1.74-dev \
    libeigen3-dev \
    libftdi-dev \
    patch \
    pkg-config \
    python3.10-dev \
    unzip

FROM build-deps AS build-yosys

RUN git clone -b yosys-0.29 https://github.com/YosysHQ/yosys.git \
    && cd yosys \
    && echo >>Makefile.conf "ENABLE_TCL := 0" \
    && echo >>Makefile.conf "ENABLE_ABC := 0" \
    && echo >>Makefile.conf "ENABLE_GLOB := 0" \
    && echo >>Makefile.conf "ENABLE_PLUGINS := 0" \
    && echo >>Makefile.conf "ENABLE_READLINE := 0" \
    && echo >>Makefile.conf "ENABLE_COVER := 0" \
    && echo >>Makefile.conf "ENABLE_ZLIB := 0" \
    && make -j$(nproc) \
    && make install

FROM build-deps AS get-sv2v

RUN cd /root \
    && wget -q "https://github.com/zachjs/sv2v/releases/download/v0.0.10/sv2v-Linux.zip" \
    && unzip sv2v-Linux.zip

FROM build-deps AS build-otbn-toolchain

RUN cd /root/ \
    && git clone -n https://github.com/lowRISC/opentitan.git \
    && cd opentitan \
    && git checkout e1d873a8f9fb349de8f312c9d7aae7b140c6615c

COPY .docker/otbn_as.py.patch .docker/otbn_ld.py.patch /root/opentitan/hw/ip/otbn/util/

RUN cd /root/opentitan/hw/ip/otbn/util/ \
    && patch otbn_as.py otbn_as.py.patch \
    && patch otbn_ld.py otbn_ld.py.patch

RUN rm -rf /root/opentitan/.git

FROM base

RUN wget https://download.racket-lang.org/installers/8.9/racket-8.9-x86_64-linux-cs.sh \
    && sh racket-8.9-x86_64-linux-cs.sh --create-dir --unix-style --dest /usr/ \
    && rm racket-8.9-x86_64-linux-cs.sh

RUN pip3 install 'bin2coe==1.1.1'

RUN pip3 install pyyaml mako hjson

RUN raco pkg install --no-docs --batch --auto --checksum v1.1.0 https://github.com/anishathalye/knox.git

COPY chroniton /chroniton/chroniton

RUN cd /chroniton/chroniton && raco pkg install --no-docs --batch

COPY --from=build-yosys /usr/local/bin/* /usr/local/bin/
COPY --from=build-yosys /usr/local/share/yosys/ /usr/local/share/yosys/
COPY --from=build-otbn-toolchain /root/opentitan /root/opentitan
COPY --from=get-sv2v /root/sv2v-Linux/sv2v /usr/local/bin/sv2v

ENV RV32_TOOL_AS="/usr/bin/riscv64-linux-gnu-as"
ENV RV32_TOOL_LD="/usr/bin/riscv64-linux-gnu-ld"
ENV RV32_TOOL_OBJDUMP="/usr/bin/riscv64-linux-gnu-objdump"
ENV PATH="$PATH:/root/opentitan/hw/ip/otbn/util"

WORKDIR /
