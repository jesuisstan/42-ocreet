#!/bin/bash

echo "🧹 Cleaning up compiled files and renaming project to 42-ocreet..."

# Remove compiled files
echo "Removing compiled JavaScript files..."
rm -f app/graffiti.js
rm -f app/index.html app/index2.html

# Remove any build directories that might exist
echo "Removing build directories..."
rm -rf app/srcs/_deps app/srcs/_client app/srcs/_server app/srcs/local

echo "🎉 Cleanup completed!"
echo ""
echo "Next steps:"
echo "1. Run './scripts/build.sh' to compile the project"
echo "2. Run './scripts/run.sh' to start the server" 