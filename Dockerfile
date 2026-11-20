# Ubuntu 24.04 base: the prebuilt SBCL binary needs glibc >= 2.38
FROM mcr.microsoft.com/dotnet/sdk:9.0-noble

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl bzip2 build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Modern SBCL from the official prebuilt binary
ARG SBCL_VERSION=2.6.10
RUN curl -sSL -o /tmp/sbcl.tar.bz2 \
      "https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2" \
 && tar -xjf /tmp/sbcl.tar.bz2 -C /tmp \
 && cd /tmp/sbcl-${SBCL_VERSION}-x86-64-linux \
 && INSTALL_ROOT=/usr/local sh install.sh >/dev/null \
 && rm -rf /tmp/sbcl*

ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH=/usr/local/cargo/bin:$PATH
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable

WORKDIR /bench
COPY csharp ./csharp
COPY csharp-parallel ./csharp-parallel
COPY csharp-opt ./csharp-opt
COPY csharp-simd ./csharp-simd
COPY csharp-fn ./csharp-fn
COPY rust ./rust
COPY sbcl ./sbcl
COPY run.sh jit-asm.sh ./

RUN cd csharp && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-parallel && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-opt && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-simd && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-fn && dotnet build -c Release -o out --nologo -v q
RUN cd rust && cargo build --release -q
RUN cd sbcl && sbcl --non-interactive --load build.lisp \
 && sbcl --non-interactive --load build-opt.lisp \
 && sbcl --non-interactive --load build-simd.lisp

CMD ["./run.sh"]
