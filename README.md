# Ceive ImGizmo
 A performant immediate mode gizmo library.<br>

Ceive was made in mind for both performance and immediate mode usage, after I looked at the lack of good gizmo librarys on roblox I set out to create one that was not only more performant than other librarys. But was also easier to work with and had more capabilities.<br><br>

(The name Cieve ImGizmo is derived from Perceive and Immediate Mode Gizmo)

# Demo

The demo place can be found here: https://www.roblox.com/games/13812842210/Gizmos-Demo<br>
And the rbxm + rbxl files can be found in the releases.

# Shapes

Boxes with or without triangles<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/9818ce7c-dce4-4910-bf35-2031261aa737)<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/59d70ab7-db98-4bdd-8574-cbe78c9115bf)

Wedges with or without triangles<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/429481cb-5712-4138-8002-d8fbc6d36b81)<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/827e6be3-8c12-4a44-9b2f-059d568caf66)

Spheres<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/93048358-7d32-4517-8010-a2de86913a3a)

Cylinders<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/962a4107-db2a-4f28-abd8-0e17d00b8f20)

Capsules<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/c84cc956-208e-4b05-998e-f21b63019f00)

Custom Import OBJ Meshes<br>
![image](https://github.com/JakeyWasTaken/Ceive-ImGizmo/assets/75340712/1a082b8f-667b-4c66-9609-38af3de48271)

# Usage

The demo place provides an example for every single shape including the custom mesh.<br>
But heres a basic example on how you could create a cylinder
```lua
Gizmo.PushProperty("Color3", Color3.new(0.184314, 0.184314, 1))
Gizmo.DrawCylinder(CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(25), 0), 2, 4, 20) -- Location: CFrame, Radius: number, Length: number, Subdivisions: number
```

Subdivisions just define how many segments should make up a shape it's the same as blender when you define how many vertices should make up a cylinder for example.<br>

# How it works

Ceive ImGizmo is an immediate mode gizmo library, this means that instead of creating objects and them persisting over multiple frames, they are instead deleted after each render cycle and ready to be used next frame. This means you dont have to keep track of objects and destroy them. All of it is handled at the end of each frame (On heartbeat)<br><br>

This means setup is so easy you can have gizmos visualising look directions, nav meshes, attack regions and hitboxes in just **minutes**.

# Performance

Cieve uses a WireframeHandleAdornment, (I believe this is used by roblox internally when you turn on wireframe view) This means it is incredibly fast, being able to show 100k lines at 20fps you never have to worry about performance. All of the lines are under 2 Adornments, one thats  AlwaysOnTop and one that isn't. You can be rest assured that there will be negligable performance impact when your gizmos are enabled.<br><br>

If you'd wish to enable / disable all gizmos then you can call `Gizmo.SetEnabled(value: boolean)` this will disable all rendering and clear any Rays / Adornments.
