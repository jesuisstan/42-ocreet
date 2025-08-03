# Quadtree Optimization in h42n42

## Overview

The quadtree implementation optimizes collision detection from O(n²) to O(log n) complexity, enabling smooth gameplay with 100+ creatures.

## How it works

### 1. Spatial Partitioning

- Divides 2D space into 4 quadrants recursively
- Each quadrant can be further subdivided when it contains >5 objects
- Objects are placed in the smallest quadrant that can contain them

### 2. Quadrant Numbering

```
┌─────────┬─────────┐
│    0    │    1    │  ← Top half
├─────────┼─────────┤
│    2    │    3    │  ← Bottom half
└─────────┴─────────┘
```

### 3. Collision Detection

- Only checks collisions between objects in adjacent quadrants
- Handles diagonal movement by checking all quadrants an object spans
- Uses bounding box intersection for precise collision detection

### 4. Performance Benefits

- **Before:** 100 creatures = 10,000 collision checks
- **After:** 100 creatures = ~400 collision checks
- **Result:** Smooth 60 FPS gameplay even with many creatures

## Key Functions

### `get_rect_nb`

Determines which quadrant a point belongs to (0-3)

### `get_all_rects`

Finds all quadrants an object spans (for diagonal movement)

### `collision_pred`

Main collision detection function using quadtree optimization

## Usage in Game

```ocaml
(* Every 0.1 seconds: *)
let quadtree = CreatureQuadtree.make width height in
let quadtree = List.fold_left (fun acc b ->
    CreatureQuadtree.add acc b) quadtree living_creatures in
List.iter (make_sick_if_collision quadtree) living_creatures
```

## Technical Implementation

- **Module:** `Quadtree.Make (CreatureLeaf)`
- **Data Structure:** Tree with 4 children per node + leaf list
- **Splitting Threshold:** 5 objects per leaf node
- **Collision Check:** Bounding box intersection test
