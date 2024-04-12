# Ceive ImGizmo
 A performant immediate and retained mode gizmo library.<br />

Ceive was made in mind for both performance, immedate mode and retained mode, after I looked at the lack of good gizmo librarys on roblox I set out to create one that was not only more performant than other librarys. But was also easier to work with and had more capabilities.<br /><br />

(The name Cieve ImGizmo is derived from Perceive and Immediate Mode Gizmo)

# Demo

The demo place can be found here: https://www.roblox.com/games/13812842210/Gizmos-Demo<br />
And the rbxm + rbxl files can be found in the releases.

You can also install from [wally](https://wally.run/package/jakeywastaken/imgizmo) via `imgizmo = "jakeywastaken/imgizmo@^3.5.0"`

# Shapes

Boxes with or without triangles<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/c48baf47-3c73-45df-9a63-eb6ce0128073)<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/a0f0aaa7-a555-426e-a3ce-8e9e57f73dd9)


Wedges with or without triangles<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/fb185cf2-e1c1-4a5e-a941-da81ab9b3510)<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/eafc796e-d069-4680-ae93-50b41461edfb)


Spheres<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/039562e2-06e3-462b-bb8d-291903212683)


Cylinders<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/bd941fe6-ef66-4ed8-b929-d950bc1d77d3)


Capsules<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/f0787cb5-17e6-4d47-8ed7-ca829d7fddb0)


Custom Import OBJ Meshes<br />
![image](https://github.com/JakeyWasTaken/CeiveImGizmo/assets/75340712/1d5b0445-6d91-48c0-a749-e889ae755057)


# Usage

The demo place provides an example for every single shape including the custom mesh.<br />
But heres a basic example on how you could create a cylinder
```lua
Gizmo.PushProperty("Color3", Color3.new(0.184314, 0.184314, 1))
Gizmo.Cylinder:Draw(CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(25), 0), 2, 4, 20) -- Location: CFrame, Radius: number, Length: number, Subdivisions: number
```

Subdivisions just define how many segments should make up a shape it's the same as blender when you define how many vertices should make up a cylinder for example.<br />

# How it works

Ceive ImGizmo is both an immediate and retained gizmo library, immediate mode means that instead of creating objects and them persisting over multiple frames, they are instead deleted after each render cycle and ready to be used next frame. This means you dont have to keep track of objects and destroy them. All of it is handled at the end of each frame (On heartbeat)<br /><br />

This means setup is so easy you can have gizmos visualising look directions, nav meshes, attack regions and hitboxes in just **minutes**.

# Performance

Ceive uses a WireframeHandleAdornment, This means it is incredibly fast, being able to show 100k lines at 20fps you never have to worry about performance. All of the lines are rendered using 2 Adornments, one thats AlwaysOnTop and one that isn't. You can be rest assured that there will be negligable performance impact when your gizmos are enabled.<br /><br />

Internally the retained mode just calls back to the immediate mode functions, so there is no performance difference between them.<br />
If you'd wish to enable / disable all gizmos then you can call `Gizmo.SetEnabled(value: boolean)` this will disable all rendering and clear any Rays / Adornments.
