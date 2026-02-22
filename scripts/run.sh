#!/bin/bash

# H42N42 Run Script
# Start the Ocsigen server with the H42N42 game

set -e  # Exit on any error

cd "$(dirname "$0")/../src/app"

# Check if project is built
if [ ! -f "h42n42.cma" ] || [ ! -f "h42n42.conf" ] || [ ! -f "static/h42n42.js" ]; then
    echo "❌ Project not built yet!"
    echo "Please run: ./scripts/build.sh"
    exit 1
fi

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 8080 is already in use!"
    echo "Please stop the running service or change the port in h42n42.conf"
    exit 1
fi

echo "🚀 Starting H42N42 server..."
echo "📡 Server will be available at: http://localhost:8080"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Start the Ocsigen server
ocsigenserver -c h42n42.conf 