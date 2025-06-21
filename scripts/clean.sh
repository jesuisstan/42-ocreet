#!/bin/bash

# H42N42 Clean Script
# Remove all build artifacts and temporary files

cd "$(dirname "$0")/../src/app"

echo "🧹 Cleaning H42N42 project..."

# Remove build directories
echo "📁 Removing build directories..."
rm -rf _server _client _deps local

# Remove static files
echo "📁 Removing static files..."
rm -rf static

# Remove compiled files
echo "🗑️  Removing compiled files..."
rm -f *.cmo *.cmx *.cmi *.cma *.cmxs *.js
rm -f .depend
rm -f h42n42.conf

# Remove temporary files
echo "🗑️  Removing temporary files..."
rm -f *.annot *.type_mli
rm -f *~

# Clean temporary runtime directories
echo "🗑️  Cleaning runtime directories..."
rm -rf /tmp/h42n42-log /tmp/h42n42-data

echo "✅ Clean completed!"
echo "💡 To rebuild the project, run: ./scripts/build.sh" 