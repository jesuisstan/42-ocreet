#!/bin/bash

set -e

echo "📦 Updating package lists and installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    libev-dev \
    pkg-config \
    libgmp-dev \
    libssl-dev \
    zlib1g-dev \
    rlwrap \
    bubblewrap \
    m4 \
    libsqlite3-dev

echo "🚀 Installing OPAM (official installer)..."
bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"

echo "📥 Initializing OPAM..."
opam init -y --disable-sandboxing
eval $(opam env)

# Определяем файл конфигурации shell для автоподгрузки opam env
SHELL_CONFIG=""

if [[ "$SHELL" == */zsh ]]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
  SHELL_CONFIG="$HOME/.bashrc"
else
  SHELL_CONFIG="$HOME/.profile"
fi

if ! grep -q 'eval $(opam env)' "$SHELL_CONFIG" 2>/dev/null; then
  echo -e "\n# Load OPAM environment\nif command -v opam >/dev/null 2>&1; then\n  eval \$(opam env)\nfi" >> "$SHELL_CONFIG"
  echo "🔄 Added 'eval \$(opam env)' to $SHELL_CONFIG for automatic environment setup"
else
  echo "ℹ️ OPAM environment already configured in $SHELL_CONFIG"
fi

echo ""
echo "🐫 Creating OCaml 4.14.1 switch for the Ocreet project..."
opam switch create ocreet-4.14.1 4.14.1
eval $(opam env --switch=ocreet-4.14.1)

echo "📦 Installing system dependencies for Ocsigen/Js_of_ocaml..."
sudo apt install -y rlwrap bubblewrap m4 pkg-config libev-dev libssl-dev libsqlite3-dev

echo "🔧 Installing OCaml packages for the Ocreet project..."
opam install -y dune eliom ocsigenserver js_of_ocaml js_of_ocaml-ppx tyxml lwt ocamlfind utop

echo "✅ Ocreet environment is fully installed!"
echo "💡 You can activate it anytime with:"
echo "    opam switch ocreet-4.14.1 && eval \$(opam env)"
echo ""
echo "🔍 Verify versions:"
ocaml -version
utop --version
eliomc --version || echo "ℹ️ eliomc installed via eliom package"
