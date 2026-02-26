ObjForge is a lightweight 3D block modeling tool built specifically for the PS Vita. It is written in Lua for the wonderful Lua Player Plus interperter (https://github.com/Rinnegatamante/lpp-vita) 

from Rinnegatamante. There is a vpk in the release section. The touch screen coupled with analog sticks makes this fun to play with. 

It runs entirely on-device and lets you construct grid-based models using a fixed set of primitives, then export them as standard .obj and .mtl files for use in Blender or any other 3D pipeline.

It produces clean geometry with proper face definitions and material groups, organized by color on export.

Core Features

• 11 Primitives

cube

slab

prism

wedge

corner_wedge

pyramid

roof_ridge

cylinder (12 sides)

cone (12 sides)

sphere (8×6 segments)

stairs (4-step)

All primitives are centered, grid-aligned, and rotate in 90° increments on X and Y.

• 12 Material Colors
Each color exports as a named material in scene.mtl.
Ambient/diffuse values are written per material. Faces are grouped by color using usemtl.

• Grid-Based Editing

X/Z movement is camera-relative.

Y movement is vertical within bounds.

11×11 build area (–5 to +5).

Height limit: 5 units.

• On-Device OBJ Export
Press START to export:

ux0:data/ObjForge/scene.obj
ux0:data/ObjForge/scene.mtl

Geometry is written with proper vertex offsets and grouped per material.
Export is clean and ready for Blender import.

• Save Slots
Three project slots stored in:

ux0:data/ObjForge/slot1.lua
slot2.lua
slot3.lua

Save, load, and delete directly from the in-app menu.







Movement

Left Analog – Move cursor (camera-relative X/Z)

D-Pad Up/Down – Move cursor Y

Editing

L / R – Change primitive

Triangle – Rotate Y (90°)

Circle – Rotate X (90°)

Left / Right (D-Pad) – Change color

Cross – Place block

Square – Delete block

System

START – Export OBJ

SELECT – Open save/load menu

Touch – Orbit camera
