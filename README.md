# 🧬 42-ocreet

**42-ocreet** is an interactive web simulation written entirely in **OCaml** using the **Ocsigen** framework.  
In this browser game, you help a population of creatures (_Creets_) survive a deadly virus spreading from a toxic river.

Available on [www.four2-ocreet.onrender.com]([https://ocsigen.org](https://four2-ocreet.onrender.com/)).

**Note**: wait ~2 minutes before the game compiles and gets ready for playing

> A 42 School project exploring client-side web programming with static typing, monadic concurrency, and DOM interaction in OCaml.

---

## 🎮 Gameplay

- Creets move randomly in a rectangular space bordered by:
  - 🧪 A **toxic river** (top) that infects on contact
  - 🏥 A **hospital** (bottom) where players can drag sick Creets to heal them
- Infected Creets:
  - Change color and move slower (15% speed reduction)
  - Can infect others with 2% chance on contact
  - Die after configurable time if not healed
- Special infected states:
  - **Berserk** (10% chance): Grow 4x larger, more dangerous
  - **Insane** (10% chance): Shrink 15%, chase healthy Creets
- Player controls:
  - **Drag and drop** Creets with mouse to keep them safe
  - Grabbed Creets are temporarily **invulnerable**
  - Only player-delivered Creets get healed at hospital
- Game mechanics:
  - Creets reproduce as long as healthy ones exist
  - **Difficulty increases** over time (speed, spawn rate)
  - **Game Over** when all Creets are infected
  - **Configurable parameters** via sliders (creature size, speed, spawn rate, etc.)

---

## 🛠️ Built With

- **OCaml 4.14.1**
- [Ocsigen](https://ocsigen.org) – Full-stack framework for typed web applications
  - [`Eliom`](https://ocsigen.org/eliom/) – Library for client/server web applications with **TyXML** for type-safe HTML generation
  - [`Js_of_ocaml`](https://ocsigen.org/js_of_ocaml/) – OCaml to JavaScript compiler
  - [`Lwt`](https://ocsigen.org/lwt/) – Monadic concurrency library
- **Quadtree optimization** for collision detection (bonus feature)
- **Materialize CSS** – Modern UI framework

---

## 🐳 Docker Quick Start

For a sandboxed, dependency-free environment, you can run the entire project inside Docker.

### 1. Build the Docker Image

This command builds the container image with all necessary dependencies.

```bash
sudo docker build -t 42-ocreet .
```

### 2. Run the Docker Container

This command starts the application. It will be accessible in your browser at **http://localhost:8080**.

```bash
sudo docker run -it -p 8080:8080 --rm --name ocreet-dev 42-ocreet
```

---

## 📋 Manual Installation & Launch

Follow these steps for a manual setup from your terminal.

### 1. Install Dependencies

This script sets up your entire OCaml environment, including OPAM, the correct OCaml version (4.14.1), and all required packages. You only need to run this once.

```bash
chmod +x ./scripts/install_ocaml_4.14.sh
./scripts/install_ocaml_4.14.sh
```

_You may be prompted for your `sudo` password to install system packages._

### 2. Switch to Correct OCaml Version

After installation, switch to the project's OCaml environment:

```bash
opam switch ocreet-4.14.1
eval $(opam env)
```

### 3. Build and Run the Project

This command compiles the source code and starts the development server.

```bash
chmod +x ./scripts/dev.sh
./scripts/dev.sh
```

The server will then be available at **http://localhost:8080**.

---

## 📦 Docker Management Commands

Here are some useful commands to manage your Docker images and containers.

```bash
# List running containers
sudo docker ps

# List all containers (including stopped)
sudo docker ps -a

# Stop the running container
sudo docker stop ocreet-dev

# List all Docker images
sudo docker images

# Remove the project's Docker image
sudo docker rmi 42-ocreet

# Clean up all unused containers, networks, and images (use with caution)
sudo docker system prune -a
```

### Other Useful Commands:

```bash
# Clean build artifacts (keep source)
./scripts/clean.sh

# Rebuild after changes
./scripts/clean.sh && ./scripts/build.sh

# Only build (without running)
./scripts/build.sh

# Only run (if already built)
./scripts/run.sh
```

---

## 📁 Project Structure

```
42-ocreet/
├── src/
│   ├── app/                   # OCaml source files
│   │   ├── h42n42.eliom       # Main application entry & game logic
│   │   ├── creature.eliom     # Creet logic & behavior
│   │   ├── creatureType.eliom # Type definitions
│   │   ├── creatureUtils.eliom # Creature utility functions
│   │   ├── page.eliom         # UI and DOM generation (using TyXML)
│   │   ├── dragging.eliom     # Mouse interaction & drag/drop
│   │   ├── quadtree.eliom     # Collision detection optimization
│   │   ├── mainUtils.eliom    # Main utility functions
│   │   ├── config.eliom       # Configuration management
│   │   ├── utils.eliom        # General utilities
│   │   └── h42n42.conf.in     # Server configuration template
│   ├── css/                   # Stylesheets
│   │   ├── h42n42.css         # Main game styles
│   │   └── materialize.min.css # Materialize CSS framework
│   ├── js/                    # External JavaScript libraries
│   │   ├── jquery.min.js      # jQuery library
│   │   ├── materialize.min.js # Materialize JS
│   │   └── utils.js           # Custom JavaScript utilities
│   └── images/                # Game graphics
│       ├── creature_healthy.png
│       ├── creature_sick.png
│       ├── creature_berserk.png
│       ├── creature_insane.png
│       ├── hospital.png
│       ├── river.png
│       └── sun-moon.svg
├── scripts/                   # Build & run scripts
│   ├── install_ocaml_4.14.sh  # OCaml environment setup
│   ├── build.sh              # Compile project
│   ├── run.sh                # Start server
│   ├── dev.sh                # Build and run in one command
│   ├── clean.sh              # Clean build files
│   ├── uninstall_ocaml.sh    # Remove OCaml environment
│   └── README.md             # Scripts documentation
├── docs/                     # Project documentation
│   └── subject.txt           # Original project requirements
├── Dockerfile                # Docker configuration
├── .dockerignore            # Docker ignore rules
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

---

## 🧪 Educational Goals

This project demonstrates:

1. **Client-side OCaml**: Run OCaml code in the browser via Js_of_ocaml
2. **Type-safe web development**: Shared types between client & server using Eliom
3. **Monadic concurrency**: Lwt for asynchronous programming with cooperative threads
4. **DOM manipulation**: Direct browser interaction from OCaml
5. **Event handling**: Mouse events with Lwt_js_events
6. **Game development**: Real-time simulation with collision detection
7. **Static HTML validation**: Type-safe HTML generation with TyXML (included in Eliom)
8. **Performance optimization**: Quadtree for efficient collision detection

---

## 🎯 Key Features

### Mandatory Requirements ✅

- [x] Random creature movement with realistic bouncing
- [x] Toxic river that infects creatures on contact
- [x] Hospital for healing sick creatures
- [x] Drag and drop mechanics with mouse
- [x] Invulnerability while being dragged
- [x] 15% speed reduction for infected creatures
- [x] 2% infection chance on contact
- [x] Berserk state (10% chance, 4x size increase)
- [x] Insane state (10% chance, 15% size reduction, chases healthy creatures)
- [x] Difficulty progression over time
- [x] Game over when all creatures are infected
- [x] Lwt threads for each creature
- [x] DOM elements for creatures
- [x] Mouse event handling

### Bonus Features ✅

- [x] **Quadtree optimization** for collision detection
- [x] **Configurable parameters** via sliders
- [x] **Modern UI** with Materialize CSS
- [x] **Theme toggle** (light/dark mode)
- [x] **Responsive design** for different screen sizes

---

## 🐛 Troubleshooting

**Build errors?**

- Make sure you're using OCaml 4.14.1: `ocaml --version`
- Switch to correct environment: `opam switch ocreet-4.14.1 && eval $(opam env)`
- Check installed packages: `opam list | grep -E "(eliom|js_of_ocaml|lwt)"`
- Try cleaning first: `./scripts/clean.sh`

**Server won't start?**

- Check port 8080 is free: `lsof -i :8080`
- Verify build completed: look for `src/app/h42n42.cma` and `src/app/static/h42n42.js`
- Check server logs for errors

**Game not loading?**

- Check browser console for JavaScript errors
- Ensure ocsigenserver is running: should see "Starting H42N42 server" message
- Verify all static files are copied: check `src/app/static/` directory

**Wrong OCaml version?**

```bash
# Check current version
ocaml --version

# Switch to correct version
opam switch ocreet-4.14.1
eval $(opam env)
```

---

## 📚 Additional Resources

- [Ocsigen Documentation](https://ocsigen.org)
- [Eliom Tutorial](https://ocsigen.org/eliom/1.12.0/manual/intro)
- [Js_of_ocaml Documentation](https://ocsigen.org/js_of_ocaml/)
- [Lwt Documentation](https://ocsigen.org/lwt/)

---

_Made with ❤️ for 42 School_
