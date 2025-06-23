# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

# Set the working directory
WORKDIR /app

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV OPAMYES=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libev-dev \
    pkg-config \
    libgmp-dev \
    libssl-dev \
    zlib1g-dev \
    rlwrap \
    bubblewrap \
    m4 \
    libsqlite3-dev \
    libgdbm-dev \
    curl \
    expect \
    unzip \
    git \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Install OPAM non-interactively
RUN printf "\n" | bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"

# Initialize OPAM
RUN opam init --yes --disable-sandboxing

# Create OCaml switch
RUN opam switch create ocreet-4.14.1 4.14.1

# Activate OPAM environment and install packages
RUN eval $(opam env) && \
    opam install -y \
    dune \
    eliom \
    ocsigenserver \
    ocsipersist-dbm \
    js_of_ocaml \
    js_of_ocaml-ppx \
    tyxml \
    lwt \
    ocamlfind \
    utop

# Copy project files
COPY --chown=root:root . .

# Make scripts executable
RUN chmod +x scripts/*.sh

# Expose port
EXPOSE 8080

# Set up environment and run dev script
CMD ["/bin/bash", "-c", "eval $(opam env) && ./scripts/dev.sh"] 