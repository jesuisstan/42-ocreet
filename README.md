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

## 🚀 Quick Start

### One-command Setup & Run:

```bash
./scripts/setup.sh
```

This will automatically:

1. Clean up old build files
2. Rename project from h42n42 to 42-ocreet
3. Build from source
4. Start the server

Then open your browser at: **http://localhost:8080**

---

## 📋 Manual Commands

### Prerequisites

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt install ocaml opam git m4 bubblewrap pkg-config \
    libev-dev libssl-dev libsqlite3-dev libgdbm-dev

# Setup OCaml environment
opam init --bare --disable-sandboxing
opam switch create ocreet-4.14.1 4.14.1
eval $(opam env)

# Install OCaml packages
opam install eliom js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt \
             lwt lwt_ppx ocsigenserver ocsipersist-dbm dbm
```

### Build & Run Manually:

```bash
# 1. Clean up and prepare project
./scripts/cleanup.sh
./scripts/update_content.sh

# 2. Build from source
./scripts/build.sh

# 3. Start server
./scripts/run.sh
```

### Other Useful Commands:

```bash
# Clean build artifacts (keep source)
./scripts/clean.sh

# Rebuild after changes
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
