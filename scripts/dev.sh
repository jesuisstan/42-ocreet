#!/bin/bash

# H42N42 Development Script
# Quick build and run for development

set -e  # Exit on any error

SCRIPT_DIR="$(dirname "$0")"

echo "🔄 Development mode: Building and running H42N42..."

# Build the project
echo "🔨 Building project..."
"$SCRIPT_DIR/build.sh"

echo ""
echo "⏱️  Waiting 2 seconds before starting server..."
sleep 2

# Run the project
echo "🚀 Starting development server..."
"$SCRIPT_DIR/run.sh" 