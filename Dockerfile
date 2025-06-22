# Use an official OCaml runtime as a parent image
FROM ocaml/opam:ubuntu-22.04-ocaml-4.14

# Set the working directory in the container
WORKDIR /home/opam/app

# Install system dependencies needed for ocaml packages
# libev-dev is required by lwt
RUN sudo apt-get update && sudo apt-get install -y libev-dev && sudo rm -rf /var/lib/apt/lists/*

# Install OCaml dependencies
# Using one command for all dependencies for better layer caching
RUN opam install --yes \
    eliom \
    lwt_ppx \
    js_of_ocaml-ppx \
    ppx_deriving \
    ppx_deriving_yojson \
    yojson \
    calendar \
    bigstringaf

# Copy the local repository files to the container
COPY . .

# Build the application
# This command is from scripts/build.sh
RUN opam exec -- ocamlbuild -use-ocamlfind \
      -pkg eliom \
      -pkg lwt_ppx \
      -pkg js_of_ocaml-ppx \
      -pkg ppx_deriving.std \
      -pkg yojson \
      -pkg calendar \
      -pkg ppx_deriving_yojson \
      -pkg bigstringaf \
      src/app/h42n42.byte

# Vercel will automatically map the container's exposed port.
# The port is 8080 as seen in src/app/h42n42.conf.in
EXPOSE 8080

# Command to run the application
# This is from scripts/run.sh
CMD sh -c 'STATIC_DIR=$(ocamlfind query eliom)/static && \
           LIB_DIR=$(ocamlfind query eliom)/lib && \
           sed -e "s|@ELIOM_STATIC_DIR@|$STATIC_DIR|g" \
               -e "s|@ELIOM_LIB_DIR@|$LIB_DIR|g" \
               src/app/h42n42.conf.in > h42n42.conf && \
           _build/src/app/h42n42.byte -c h42n42.conf' 