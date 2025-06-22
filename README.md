# 🧬 42-ocreet

**42-ocreet** is an interactive web simulation written entirely in **OCaml** using the **Ocsigen** framework.  
In this browser game, you help a population of creatures (_Creets_) survive a deadly virus spreading from a toxic river.

> A 42 School project exploring client-side web programming with static typing, monadic concurrency, and DOM interaction in OCaml.

---

## 🎮 Gameplay

- Creets move randomly in a rectangular space bordered by:
  - 🧪 A **toxic river** (top) that infects on contact
  - 🏥 A **hospital** (bottom) where players can drag sick Creets to heal them
- Infected Creets:
  - Change color and move slower (15% speed reduction)
  - Can infect others with 2% chance on contact
  - Die after 7 seconds if not healed
- Special infected states:
  - **Berserk** (10% chance): Grow 4x larger, more dangerous
  - **Mean** (10% chance): Shrink 15%, chase healthy Creets
- Player controls:
  - **Drag and drop** Creets with mouse to keep them safe
  - Grabbed Creets are temporarily **invulnerable**
  - Only player-delivered Creets get healed at hospital
- Game mechanics:
  - Creets reproduce as long as healthy ones exist
  - **Difficulty increases** over time (speed, spawn rate)
  - **Game Over** when all Creets are infected

---

## 🛠️ Built With

- **OCaml 4.14.1**
- [Ocsigen](https://ocsigen.org) – Full-stack framework for typed web applications
  - [`Eliom`](https://ocsigen.org/eliom/) – Client/server web framework
  - [`Js_of_ocaml`](https://ocsigen.org/js_of_ocaml/) – OCaml to JavaScript compiler
  - [`Lwt`](https://ocsigen.org/lwt/) – Monadic concurrency library
- **TyXML** – Type-safe HTML generation
- **Quadtree optimization** for collision detection (bonus feature)

---

## 🚀 Getting Started

This guide will walk you through setting up the development environment and running the project locally.

### 1. Prerequisites

Before you begin, ensure you have the following installed on your system. The setup script will handle the rest.

- `git`
- `curl`
- `sudo` access
- A Debian-based OS (like Ubuntu) is recommended for the scripts to work seamlessly.

### 2. Environment Setup

The project includes a convenient script to set up the entire OCaml development environment. Run it from the project root:

```bash
./scripts/install_ocaml_4.14.sh
```

This script automates the full installation process:

- Installs **OPAM**, the OCaml package manager.
- Configures a local **OCaml 4.14.1** environment (`switch`).
- Installs necessary system libraries (`libev`, `pkg-config`, etc.).
- Installs all required OCaml packages, including:
  - The **Ocsigen** framework (`Eliom`, `Ocsigen-server`)
  - The **Js_of_ocaml** compiler and its preprocessor (`-ppx`)
  - The **Lwt** monadic concurrency library

> **Note**: After the script finishes, you may need to restart your terminal or source your shell's configuration file (e.g., `source ~/.zshrc` or `source ~/.bashrc`) to ensure the `opam` environment is active.

### 3. Build & Run

Once the environment is set up, a single command builds the project and starts the server:

```bash
./scripts/setup.sh
```

This script is a wrapper that cleans old artifacts, builds the source, and runs the application.

You can then view the game in your browser at: **http://localhost:8080**

---

## 🛠️ Individual Commands

If you prefer to run the steps manually:

```bash
# Clean all build artifacts
./scripts/clean.sh

# Build the project from source (after setup)
./scripts/build.sh

# Run the server (after building)
./scripts/run.sh

# A typical development cycle: clean and rebuild
./scripts/clean.sh && ./scripts/build.sh
```

---

## 📁 Project Structure

```
42-ocreet/
├── src/
│   ├── app/                   # OCaml source files
│   │   ├── h42n42.eliom       # Main application entry
│   │   ├── creature.eliom     # Creet logic & behavior
│   │   ├── page.eliom         # UI and DOM generation
│   │   ├── dragging.eliom     # Mouse interaction
│   │   ├── quadtree.eliom     # Collision optimization
│   │   └── ...
│   ├── css/                   # Stylesheets
│   ├── js/                    # External JavaScript libs
│   ├── images/                # Game graphics
│   └── static/                # Static assets
├── scripts/                   # Build & run scripts
│   ├── setup.sh              # One-command setup
│   ├── build.sh              # Compile project
│   ├── run.sh                # Start server
│   └── clean.sh              # Clean build files
└── README.md
```

---

## 🧪 Educational Goals

This project demonstrates:

1. **Client-side OCaml**: Run OCaml code in the browser via Js_of_ocaml
2. **Type-safe web development**: Shared types between client & server
3. **Monadic concurrency**: Lwt for asynchronous programming
4. **DOM manipulation**: Direct browser interaction from OCaml
5. **Event handling**: Mouse events with Lwt_js_events
6. **Game development**: Real-time simulation with collision detection

---

## 🎯 42 School Requirements Met

✅ **OCaml + Ocsigen framework**  
✅ **Client-side execution** (Js_of_ocaml)  
✅ **DOM manipulation** and **mouse events**  
✅ **Lwt monadic concurrency**  
✅ **Game mechanics**: infection, healing, movement, reproduction  
✅ **Difficulty progression** and proper game loop  
✅ **Bonus**: Quadtree optimization for collision detection

---

## 🐛 Troubleshooting

**Build errors?**

- Make sure all OCaml packages are installed: `opam list | grep -E "(eliom|js_of_ocaml|lwt)"`
- Try cleaning first: `./scripts/clean.sh`

**Server won't start?**

- Check port 8080 is free: `lsof -i :8080`
- Verify build completed: look for `src/app/local/var/www/ocreet/eliom/ocreet.js`

**Game not loading?**

- Check browser console for JavaScript errors
- Ensure ocsigenserver is running: should see "Starting Ocsigen server" message

---

_Made with ❤️ for 42 School_
