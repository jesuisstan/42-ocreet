# H42N42 Build Scripts

Scripts for building and running the H42N42 game (OCaml + Eliom + Js_of_ocaml).

## Requirements

Make sure you have installed:

- OCaml 4.14.1
- Eliom
- Js_of_ocaml
- Ocsigen server

```bash
# Check installed packages
ocamlfind list | grep -E "(lwt|js_of_ocaml|eliom)"
```

## Scripts

### 🐳 `install_ocaml_4.14.sh` - Install OCaml 4.14.1 Environment

Installs the complete OCaml environment with the correct version for the project.

```bash
chmod +x ./scripts/install_ocaml_4.14.sh
./scripts/install_ocaml_4.14.sh
```

**What it does:**

- Updates package lists and installs system dependencies
- Installs OPAM (OCaml Package Manager)
- Creates OCaml 4.14.1 switch for the project
- Installs all required OCaml packages (eliom, ocsigenserver, js_of_ocaml, etc.)

### 🔨 `build.sh` - Build Project

Compiles the project and creates all necessary files.

```bash
./scripts/build.sh
```

**What it does:**

- Cleans previous build
- Copies static files (CSS, JS, images)
- Generates dependencies
- Compiles server-side (OCaml → .cma)
- Compiles client-side (OCaml → JavaScript)
- Creates configuration file

### 🚀 `run.sh` - Start Server

Starts the Ocsigen server with the game.

```bash
./scripts/run.sh
```

**Open in browser:** http://localhost:8080

### 🧹 `clean.sh` - Clean Build

Removes all build files and temporary files.

```bash
./scripts/clean.sh
```

### 🔄 `dev.sh` - Development Mode

Build + run in one command (convenient for development).

```bash
./scripts/dev.sh
```

### 🗑️ `uninstall_ocaml.sh` - Uninstall OCaml

Removes the OCaml environment and all installed packages.

```bash
./scripts/uninstall_ocaml.sh
```

**Use with caution:** This will completely remove the OCaml installation.

## Project Structure After Build

```
42-ocreet/src/app/
├── *.eliom              # OCaml source code
├── h42n42.conf.in       # Configuration template
├── h42n42.conf          # Generated configuration
├── h42n42.cma           # Compiled server library
├── static/              # Static files
│   ├── css/            # CSS styles
│   ├── js/             # JavaScript libraries
│   ├── images/         # Game images
│   └── h42n42.js       # Generated JavaScript
├── _server/            # Server intermediate files
├── _client/            # Client intermediate files
└── _deps/              # Dependency files
```

## Quick Start

### First Time Setup

```bash
# Install OCaml 4.14.1 environment
./scripts/install_ocaml_4.14.sh

# Switch to the correct OCaml version
opam switch ocreet-4.14.1
eval $(opam env)
```

### Development Workflow

```bash
# Build and run in one command
./scripts/dev.sh
```

### Manual Build and Run

```bash
# Build the project
./scripts/build.sh

# Start the server
./scripts/run.sh
```

## Troubleshooting

### Error "Port 8080 is already in use"

```bash
# Find process using the port
lsof -i :8080
# Kill the process
kill -9 <PID>
```

### Error "No such package"

Check installed OCaml packages:

```bash
ocamlfind list | grep -E "(lwt|js_of_ocaml|eliom)"
```

### Permission Issues

```bash
chmod +x scripts/*.sh
```

### Wrong OCaml Version

```bash
# Check current version
ocaml --version

# Switch to correct version
opam switch ocreet-4.14.1
eval $(opam env)
```

## Game Features

- **Random creature movement** with realistic bouncing
- **Toxic river** that infects creatures on contact
- **Hospital** where players can heal sick creatures
- **Drag and drop** mechanics with mouse
- **Infection mechanics** with different states (Berserk, Insane)
- **Difficulty progression** over time
- **Configurable parameters** via sliders
- **Quadtree optimization** for collision detection

## Access the Game

After running the server, open your browser and go to: **http://localhost:8080**
