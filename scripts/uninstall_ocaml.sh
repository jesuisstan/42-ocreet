#!/bin/bash

set -e

echo "🧼 OCaml & OPAM Full Uninstallation Script"
echo "⚠️ This will remove OCaml, OPAM, utop, merlin, dune, LSP, aliases, and related configuration from your system."
read -p "❓ Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "❌ Aborted."
  exit 1
fi

echo "🗑️ Removing APT packages (except system-critical ones)..."
sudo apt remove --purge -y opam m4 build-essential
sudo apt autoremove --purge -y

echo "📂 Deleting OPAM and OCaml directories..."
rm -rf ~/.opam
rm -rf ~/.cache/opam

echo "🧹 Cleaning shell configuration files..."
for file in ~/.bashrc ~/.zshrc ~/.profile; do
  if [[ -f "$file" ]]; then
    echo "🧽 Cleaning $file"
    # Remove opam environment hooks
    sed -i '/opam env/d' "$file"
    sed -i '/# OPAM configuration/,+5d' "$file"
    # Remove utop alias
    sed -i '/alias utop=.*rlwrap/d' "$file"
  fi
done

echo "🧼 Removing residual global config files (if any)..."
rm -rf ~/.merlin
rm -rf ~/.ocamlformat
rm -rf ~/.dune

echo "🔍 Verifying cleanup..."
echo "which ocaml: $(which ocaml || echo 'Not found')"
echo "which opam: $(which opam || echo 'Not found')"
echo "which utop: $(which utop || echo 'Not found')"

echo "✅ Uninstallation complete. OCaml and all dev tools have been removed."
