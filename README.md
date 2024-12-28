# Platformer Game Overview

## Describe the overall game of the platformer. What are the possibilities for the player?

Players can perform **coyote jumps** and **jump buffering**. There’s also **damping** and **animations**. (I implemented acceleration and other damping mechanics, but they didn’t feel satisfying, so I removed them.)  

I set the default animation to the **sprite animation**, as it seemed more fitting (and because I couldn’t find a way to flip the skeleton so it faces the direction it moves). However, you can toggle the skeleton animation using the `"Is Skeleton Animation"` boolean on the Player node.  

The **rope mechanic** works as required: players can extend, retract, and swing on the rope, as well as jump from one rope to another. Only one rope can be used at a time. The rope is created by pointing the mouse at a solid spot and left-clicking.  

I put a lot of effort into making the movement feel smooth and satisfying, and I think it paid off. The player can swing around like **Spider-Man**, and it's genuinely fun! :D  

I also added:
- A smoother camera.
- An extended map (pro tip: swinging near the ceiling is quite fun).
- A **parallax background** from [Raventale](https://raventale.itch.io/parallax-background).  

Additionally, I utilized my **tween library** for moving the player along the rope.  

---

## What is the extra mechanic that you added?

I added **wall jumping** because it works well with the rope mechanic and because the player often got stuck on the sides of blocks. Instead of fixing this issue, I turned it into a feature! :D  

To implement wall jumping, I added two **raycasts** on the sides of the player. These check if the player is next to a wall, and if so, the player can jump off the wall in a specific direction.

---

## How did you tackle the difficult ninja-rope mechanic?

I ran into so many issues that I honestly can’t remember them all.  

### Key Challenges and Solutions:
- **Making rope jumps feel good:**  
  I achieved this by multiplying the player’s linear velocity when they jump off a rope.  

- **Rotating the player character with the rope:**  
  This introduced a lot of complications but was worth the effort.  

- **Switching from `CharacterBody` to `RigidBody`:**  
  This caused issues like the player getting stuck on the **tilemap surface**, which I partially fixed using [GodotTilemapBaker](https://github.com/popcar2/GodotTilemapBaker). However, the player still occasionally gets stuck on the sides of tiles, and I wasn’t able to fully solve this.  

- **Handling physics loops:**  
  The `_physics_process` loop updates at a different rate than the `_process` loop (`_process()` is called every frame, while `_physics_process()` is called every physics frame). This led to some tricky timing issues.  

- **Improving aiming:**  
  To make aiming more forgiving, I replaced the `RayCast` with a `ShapeCast`. This allows the rope to attach even if the player doesn’t click precisely on a rigid spot. I also doubled the casting distance for better usability.  

There’s always room for improvement, but overall, I’m really happy with how it turned out. The mechanics feel satisfying, and the rope system works quite well!

---

## Describe the controls of the game.

- **Movement:**  
  - **Left/Right Arrow or A/D:** Move left or right.  
  - **Space:** Jump (Hold space to adjust jump height).  

- **Wall Jump:**  
  If near a wall, press jump (and hold A/D to stay attached) to perform a wall jump.  

- **Rope Interaction:**  
  - **Mouse Wheel Up:** Extend the rope while in the air.  
  - **Mouse Wheel Down:** Shorten the rope.  
  - **Left Mouse Button:** Spawn rope at the mouse pointer position.  
  - **Right Mouse Button:** Remove the rope.  
