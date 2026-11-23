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

# Quicklisp + lparallel, loaded into every SBCL via /root/.sbclrc
RUN curl -sSL -o /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp \
 && sbcl --non-interactive --load /tmp/quicklisp.lisp \
         --eval '(quicklisp-quickstart:install :path "/opt/quicklisp/")' \
         --eval '(ql:quickload :lparallel :silent t)' \
 && echo '(load "/opt/quicklisp/setup.lisp")' > /root/.sbclrc \
 && rm /tmp/quicklisp.lisp

ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH=/usr/local/cargo/bin:$PATH
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable

# Java (OpenJDK 25) and hsdis, so the JIT can print its machine code (java-asm.sh)
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-25-jdk-headless libhsdis0-fcml \
 && rm -rf /var/lib/apt/lists/*

# GraalVM Community (for native-image; it needs zlib headers to link)
ARG GRAALVM_VERSION=25.0.2
RUN apt-get update \
 && apt-get install -y --no-install-recommends zlib1g-dev \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sSL "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAALVM_VERSION}/graalvm-community-jdk-${GRAALVM_VERSION}_linux-x64_bin.tar.gz" \
    | tar -xz -C /opt \
 && mv /opt/graalvm-community-* /opt/graalvm

WORKDIR /bench
COPY csharp ./csharp
COPY csharp-parallel ./csharp-parallel
COPY csharp-opt ./csharp-opt
COPY csharp-simd ./csharp-simd
COPY csharp-fn ./csharp-fn
COPY rust ./rust
COPY sbcl ./sbcl
COPY java ./java
COPY jit-variants ./jit-variants
COPY run.sh jit-asm.sh jit-variants.sh java-experiments.sh java-asm.sh ./

RUN cd csharp && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-parallel && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-opt && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-simd && dotnet build -c Release -o out --nologo -v q
RUN cd csharp-fn && dotnet build -c Release -o out --nologo -v q
RUN for d in jit-variants/*/; do (cd $d && dotnet build -c Release -o out --nologo -v q) || exit 1; done
RUN cd rust && cargo build --release -q
# Java: classes + jar; AOT caches from a training run of the same program
# (JDK 25: classes pre-loaded and linked, plus method profiles); native-image
# binaries (local symbols kept so java-asm.sh can disassemble them)
# (training uses the exact classpath run.sh uses, or the JVM ignores the cache)
RUN cd java && javac -d out *.java && jar cf sum.jar -C out . && cd .. \
 && java -XX:AOTCacheOutput=java/sumint.aot -cp java/sum.jar SumInt \
 && java -XX:AOTCacheOutput=java/sumint-reduce.aot -cp java/sum.jar SumIntReduce \
 && cd java && /opt/graalvm/bin/native-image -H:-DeleteLocalSymbols -cp out -o sumint-native SumInt \
 && /opt/graalvm/bin/native-image -H:-DeleteLocalSymbols -cp out -o sumint-reduce-native SumIntReduce
RUN cd sbcl && sbcl --non-interactive --load build.lisp \
 && sbcl --non-interactive --load build-opt.lisp \
 && sbcl --non-interactive --load build-simd.lisp \
 && sbcl --non-interactive --load build-lparallel.lisp

CMD ["./run.sh"]
