# Infection Logic in h42n42

## Overview

The infection system implements the requirement: "A contaminated Creet that touches a healthy Creet has a 2% risk of contaminating it at each iteration."

## Implementation Details

### 1. Collision Detection

- **Location:** `mainUtils.eliom` - `make_sick_if_collision` function
- **Frequency:** Every 0.1 seconds via `collisions_and_chasing_thread`
- **Optimization:** Uses quadtree spatial partitioning for O(log n) performance

### 2. Infection Risk Calculation

```ocaml
match Random.int 50 with  (* 1/50 = 2% chance of contamination *)
| 0 -> Creature.make_creature_sick creature
| _ -> ()
```

### 3. Infection Conditions

- **Healthy creature** (not already sick)
- **Not being dragged** (user interaction)
- **Collision with sick creature** (detected via quadtree)
- **2% random chance** (1 in 50 iterations)

### 4. Special Infection States

When a creature gets infected, it has additional risks:

```ocaml
match Random.int 10 with
| 0 -> Berserk    (* 10% chance - grows 4x size over 7 seconds *)
| 1 -> Insane     (* 10% chance - 15% smaller, 15% faster *)
| _ -> StdSick    (* 80% chance - normal sick state *)
```

### 5. State Effects

#### Berserk (10% chance)

- **Size:** Grows from normal to 4x size over 7 seconds
- **Speed:** 15% slower
- **Behavior:** Cannot change direction

#### Insane (10% chance)

- **Size:** 15% smaller than normal
- **Speed:** 15% faster
- **Behavior:** Chases nearest healthy creature

#### StdSick (80% chance)

- **Size:** Normal size
- **Speed:** 15% slower
- **Behavior:** Normal movement

### 6. Cure Mechanism

- **Location:** Hospital zone (bottom of screen)
- **Method:** Drag sick creature to hospital
- **Effect:** Returns to healthy state (StdSick false)

### 7. Death Mechanism

- **Timer:** Configurable "life-time-after-infection" (default: 10 seconds)
- **Effect:** Creature dies and is removed from game
- **Game Over:** When all creatures are dead

## Code Flow

1. **Collision Thread** runs every 0.1 seconds
2. **Quadtree** finds potential collisions efficiently
3. **2% Risk Check** for each collision
4. **Infection State** determined by additional 10% rolls
5. **Visual Update** changes creature appearance
6. **Behavior Change** affects movement and speed

## Performance

- **Optimized:** O(log n) collision detection via quadtree
- **Scalable:** Handles 100+ creatures smoothly
- **Real-time:** 60 FPS gameplay maintained
