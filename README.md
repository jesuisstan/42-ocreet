# 🧬 Ocreet

**Ocreet** is an interactive web simulation written entirely in **OCaml** using the **Ocsigen** framework.  
In this browser game, you help a population of creatures (*Creets*) survive a deadly virus spreading from a toxic river.

> A 42 Paris project exploring client-side web programming with static typing, monadic concurrency, and DOM interaction in OCaml.

---

## 🎮 Gameplay

- Creets move randomly in a rectangular space bordered by:
  - 🧪 A **toxic river** (top) that infects on contact
  - 🏥 A **hospital** (bottom) where players can drag sick Creets to heal them
- Infected Creets:
  - Change color
  - Move slower
  - Can infect others with a 2% chance on contact
- Special states:
  - **Berserk**: 10% chance to grow and become more dangerous
  - **Mean**: 10% chance to shrink and chase healthy Creets
- Player controls:
  - Drag and drop Creets to safety
  - Grabbed Creets are temporarily invulnerable
- The game gets harder over time — survive as long as you can!

---

## 🛠️ Built With

- **OCaml**
- [Ocsigen](https://ocsigen.org) – Full-stack framework for typed web applications
  - [`Eliom`](https://ocsigen.org/eliom/)
  - [`Js_of_ocaml`](https://ocsigen.org/js_of_ocaml/)
  - [`Lwt`](https://ocsigen.org/lwt/)
- HTML5 + CSS3 (via TyXML)

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed on a Linux-based system:

```bash
sudo apt install ocaml opam git m4 bubblewrap pkg-config \\
    libev-dev libssl-dev libsqlite3-dev
```

Then install OCaml tools and libraries:

```bash
opam init --bare --disable-sandboxing
eval $(opam env)
```
```bash
opam switch create ocreet 4.14.1
eval $(opam env)
```
opam install dune eliom js_of_ocaml js_of_ocaml-ppx lwt \\
             ocsigenserver ocamlfind tyxml

Running the App
bash
Copy
Edit
make           # or dune build
make launch    # or custom run command with ocsigenserver
Then open your browser at:
http://localhost:8080/

## 📁 Project Structure
```bash
/src
  ├── main.ml            # Entry point
  ├── creet.ml           # Game logic per Creet
  ├── ui.ml              # DOM interactions
  ├── simulation.ml      # Game loop and world logic
  └── ...
/static                 # Assets (images, CSS)
dune-project
Makefile
README.md
```

## 🧪 Educational Goals
This project is designed to help students:

Run OCaml code in the browser with Js_of_ocaml

Write fully-typed, interactive web apps using one language across client & server

Learn monadic concurrency with Lwt

Work directly with the browser DOM and events via OCaml

## 🧠 Credits
Project subject: “H42N42” — 42 Paris

Framework: Ocsigen by CNRS, Inria, Paris Diderot

Developed by: Your Name