#!/bin/bash

# H42N42 Build Script
# OCaml Eliom + Js_of_ocaml project build

set -e  # Exit on any error

cd "$(dirname "$0")/../src/app"

echo "🔨 Building H42N42 project..."

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf _server _client _deps local
rm -f *.cmo *.cmx *.cmi *.cma *.cmxs *.js .depend
rm -f h42n42.conf
rm -f static/h42n42.js

# Create directories
echo "📁 Creating build directories..."
mkdir -p _server _client _deps static

# Copy static files
echo "📦 Copying static files..."
cp -r ../css static/
cp -r ../js static/
cp -r ../images static/

# Generate dependencies
echo "🔗 Generating dependencies..."
# Process in dependency order
for file in creatureType.eliom utils.eliom config.eliom dragging.eliom page.eliom quadtree.eliom creatureUtils.eliom creature.eliom mainUtils.eliom h42n42.eliom; do
    if [ -f "$file" ]; then
        echo "  Processing $file..."
        eliomdep -server -ppx "$file" > "_deps/${file}.server"
        eliomdep -client -ppx -package eliom.client -package js_of_ocaml-lwt "$file" > "_deps/${file}.client"
    fi
done

# Combine dependencies
cat _deps/*.server _deps/*.client > .depend

# Compile server side with type generation
echo "🖥️  Compiling server side..."
# Compile in dependency order - generate types and compile each file sequentially
for file in creatureType.eliom utils.eliom config.eliom dragging.eliom page.eliom quadtree.eliom creatureUtils.eliom creature.eliom mainUtils.eliom h42n42.eliom; do
    if [ -f "$file" ]; then
        echo "  Generating types for $file..."
        eliomc -infer -ppx "$file"
        if [ -f "${file%.eliom}.type_mli" ]; then
            mv "${file%.eliom}.type_mli" "_server/"
        fi
        
        echo "  Compiling $file (server)..."
        eliomc -c -ppx "$file"
        if [ -f "${file%.eliom}.cmo" ]; then
            mv "${file%.eliom}.cmo" "_server/"
        fi
        if [ -f "${file%.eliom}.cmi" ]; then
            mv "${file%.eliom}.cmi" "_server/"
        fi
    fi
done

# Create server library
echo "📚 Creating server library..."
# Link .cmo files in dependency order
SERVER_CMOS=""
for file in creatureType.eliom utils.eliom config.eliom dragging.eliom page.eliom quadtree.eliom creatureUtils.eliom creature.eliom mainUtils.eliom h42n42.eliom; do
    cmo_file="_server/${file%.eliom}.cmo"
    if [ -f "$cmo_file" ]; then
        SERVER_CMOS="$SERVER_CMOS $cmo_file"
    fi
done
eliomc -a -o h42n42.cma $SERVER_CMOS

# Compile client side
echo "🌐 Compiling client side..."
# Compile in dependency order
for file in creatureType.eliom utils.eliom config.eliom dragging.eliom page.eliom quadtree.eliom creatureUtils.eliom creature.eliom mainUtils.eliom h42n42.eliom; do
    if [ -f "$file" ]; then
        echo "  Compiling $file (client)..."
        js_of_eliom -c -ppx -package eliom.client -package js_of_ocaml-lwt -package str "$file"
        if [ -f "${file%.eliom}.cmo" ]; then
            mv "${file%.eliom}.cmo" "_client/"
        fi
    fi
done

# Create JavaScript file
echo "🎯 Creating JavaScript bundle..."
# Link .cmo files in dependency order
CLIENT_CMOS=""
for file in creatureType.eliom utils.eliom config.eliom dragging.eliom page.eliom quadtree.eliom creatureUtils.eliom creature.eliom mainUtils.eliom h42n42.eliom; do
    cmo_file="_client/${file%.eliom}.cmo"
    if [ -f "$cmo_file" ]; then
        CLIENT_CMOS="$CLIENT_CMOS $cmo_file"
    fi
done
BIGSTRING_RUNTIME=$(find $(ocamlfind query bigstringaf) -name "runtime.js")
js_of_eliom -o static/h42n42.js -ppx -package eliom.client -package js_of_ocaml-lwt -package str -jsopt "$BIGSTRING_RUNTIME" $CLIENT_CMOS

# Generate configuration file
echo "⚙️  Generating configuration file..."
# Use template-based configuration generation
sed -e 's/%%PORT%%/8080/g' \
    -e 's/%%USERGROUP%%//g' \
    -e 's/%%LOGDIR%%/\/tmp\/h42n42-log/g' \
    -e 's/%%DATADIR%%/\/tmp\/h42n42-data/g' \
    -e 's/%%DEBUGMODE%%//g' \
    -e 's/%%CMDPIPE%%/\/tmp\/h42n42-cmd/g' \
    -e 's/%%PACKAGES%%//g' \
    -e 's/%%STATICDIR%%/static/g' \
    -e 's/%%LIBDIR%%/./g' \
    -e 's/%%PROJECT_NAME%%/h42n42/g' \
    -e 's/%%WARNING%%/DO NOT EDIT THIS FILE! It is generated by build.sh/g' \
    -e '/^[[:space:]]*$/d' \
    h42n42.conf.in > h42n42.conf

# Create required directories
echo "📁 Creating runtime directories..."
mkdir -p /tmp/h42n42-log /tmp/h42n42-data

echo "✅ Build completed successfully!"
echo "📄 Files generated:"
echo "   - h42n42.cma (server library)"
echo "   - static/h42n42.js (client JavaScript)"
echo "   - h42n42.conf (server configuration)"
echo "   - static/ (CSS, JS, images)"
echo ""
echo "🚀 To run the project, use: ./scripts/run.sh" 