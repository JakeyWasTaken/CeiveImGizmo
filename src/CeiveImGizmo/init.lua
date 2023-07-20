local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain

local AOTWireframeHandle: WireframeHandleAdornment = Terrain:FindFirstChild("AOTGizmoAdornment")
local WireframeHandle: WireframeHandleAdornment = Terrain:FindFirstChild("GizmoAdornment")

if not AOTWireframeHandle then
	AOTWireframeHandle = Instance.new("WireframeHandleAdornment")
	AOTWireframeHandle.Adornee = Terrain
	AOTWireframeHandle.ZIndex = 1
	AOTWireframeHandle.AlwaysOnTop = true
	AOTWireframeHandle.Name = "AOTGizmoAdornment"
	AOTWireframeHandle.Parent = Terrain
end

if not WireframeHandle then
	WireframeHandle = Instance.new("WireframeHandleAdornment")
	WireframeHandle.Adornee = Terrain
	WireframeHandle.ZIndex = 1
	WireframeHandle.AlwaysOnTop = false
	WireframeHandle.Name = "GizmoAdornment"
	WireframeHandle.Parent = Terrain
end

local Gizmos = script:WaitForChild("Gizmos")

local ActiveObjects = {}
local RetainObjects = {}
local Debris = {}
local Tweens = {}
local PropertyTable = {AlwaysOnTop = true}
local Pool = {}

local CleanerScheduled = false

local function Retain(Gizmo, GizmoProperties)
	table.insert(RetainObjects, {Gizmo, GizmoProperties})
end

local function Register(object)
	table.insert(ActiveObjects, object)
end

local function Release(object)
	local ClassName = object.ClassName

	if not Pool[ClassName] then
		Pool[ClassName] = {}
	end

	object:Remove()
	table.insert(Pool[ClassName], object)
end

local function Request(ClassName)
	if not Pool[ClassName] then
		return Instance.new(ClassName)
	elseif not Pool[ClassName][1] then
		return Instance.new(ClassName)
	end

	local Object = Pool[ClassName][1]
	table.remove(Pool[ClassName], 1)

	return Object
end

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

-- Types

type IRay = {
	Draw: (self, Origin: Vector3, End: Vector3) -> nil,
	Create: (self, Origin: Vector3, End: Vector3) -> {Origin: Vector3, End: Vector3, Color3: Color3, AlwaysOnTop: boolean, Transparency: number}
}

type IBox = {
	Draw: (self, Transform: CFrame, Size: Vector3, DrawTriangles: boolean) -> nil,
	Create: (self, Transform: CFrame, Size: Vector3, DrawTriangles: boolean) -> {Transform: CFrame, Size: Vector3, DrawTriangles: boolean, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IWedge = {
	Draw: (self, Transform: CFrame, Size: Vector3, DrawTriangles: boolean) -> nil,
	Create: (self, Transform: CFrame, Size: Vector3, DrawTriangles: boolean) -> {Transform: CFrame, Size: Vector3, DrawTriangles: boolean, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ICircle = {
	Draw: (self, Transform: CFrame, Radius: number, Subdivisions: number, ConnectToFirst: boolean?) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Subdivisions: number, ConnectToFirst: boolean?) -> {Transform: CFrame, Radius: number, Subdivisions: number, ConnectToFirst: boolean?, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ISphere = {
	Draw: (self, Transform: CFrame, Radius: number, Subdivisions: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Subdivisions: number) -> {Transform: CFrame, Radius: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ICylinder = {
	Draw: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> {Transform: CFrame, Radius: number, Length: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ICapsule = {
	Draw: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> {Transform: CFrame, Radius: number, Length: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ICone = {
	Draw: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Length: number, Subdivisions: number) -> {Transform: CFrame, Radius: number, Length: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IArrow = {
	Draw: (self, Origin: Vector3, End: Vector3, Radius: number, Length: number, Subdivisions: number) -> nil,
	Create: (self, Origin: Vector3, End: Vector3, Radius: number, Length: number, Subdivisions: number) -> {Origin: Vector3, End: Vector3, Radius: number, Length: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IMesh = {
	Draw: (self, Transform: CFrame, Size: Vector3, Vertices: {}, Faces: {}) -> nil,
	Create: (self, Transform: CFrame, Size: Vector3, Vertices: {}, Faces: {}) -> {Transform: CFrame, Size: Vector3, Vertices: {}, Faces: {}, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IVolumeCone = {
	Draw: (self, Transform: CFrame, Radius: number, Length: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Length: number) -> {Transform: CFrame, Radius: number, Length: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IVolumeBox = {
	Draw: (self, Transform: CFrame, Size: Vector3) -> nil,
	Create: (self, Transform: CFrame, Size: Vector3) -> {Transform: CFrame, Size: Vector3, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IVolumeSphere = {
	Draw: (self, Transform: CFrame, Radius: number) -> nil,
	Create: (self, Transform: CFrame, Radius: number) -> {Transform: CFrame, Radius: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IVolumeCylinder = {
	Draw: (self, Transform: CFrame, Radius: number, Length: number, InnerRadius: number?, Angle: number?) -> nil,
	Create: (self, Transform: CFrame, Radius: number, Length: number, InnerRadius: number?, Angle: number?) -> {Transform: CFrame, Radius: number, Length: number, InnerRadius: number?, Angle: number?, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type IVolumeArrow = {
	Draw: (self, Origin: Vector3, End: Vector3, Radius: number, Length: number) -> nil,
	Create: (self, Origin: Vector3, End: Vector3, Radius: number, Length: number) -> {Origin: Vector3, End: Vector3, Radius: number, Length: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
}

type ICeive = {
	ActiveRays: number,
	ActiveInstances: number,
	
	PushProperty: (Property: string, Value: any?) -> nil,
	PopProperty: (Property: string) -> any?,
	AddDebrisInSeconds: (Seconds: number, Callback: () -> ()) -> (),
	AddDebrisInFrames: (Frames: number, Callback: () -> ()) -> (),
	SetEnabled: (Value: boolean) -> (),
	DoCleaning: () -> nil,
	ScheduleCleaning: () -> nil,
	TweenProperies: (Properties: {}, Goal: {}, TweenInfo: TweenInfo) -> () -> (),
	
	Ray: IRay,
	Box: IBox,
	Wedge: IWedge,
	Circle: ICircle,
	Sphere: ISphere,
	Cylinder: ICylinder,
	Capsule: ICapsule,
	Cone: ICone,
	Arrow: IArrow,
	Mesh: IMesh,
	VolumeCone: IVolumeCone,
	VolumeBox: IVolumeBox,
	VolumeSphere: IVolumeSphere,
	VolumeCylinder: IVolumeCylinder,
	VolumeArrow: IVolumeArrow
}

-- Ceive

--- @class CEIVE
--- Root class for all the gizmos.

local Ceive: ICeive = {
	Enabled = true,
	ActiveRays = 0,
	ActiveInstances = 0,
	
	AOTWireframeHandle = AOTWireframeHandle,
	WireframeHandle = WireframeHandle,
}

--- @within CEIVE
--- @function GetPoolSize
--- @return number
function Ceive.GetPoolSize(): number
	local n = 0

	for _, t in Pool do
		n += #t
	end

	return n
end

--- @within CEIVE
--- @function PushProperty
--- Push Property sets the value of a property.
--- @param Property string
--- @param Value any
function Ceive.PushProperty(Property, Value)
	PropertyTable[Property] = Value
	
	if Property == "AlwaysOnTop" then
		return
	end

	pcall(function()
		AOTWireframeHandle[Property] = Value
		WireframeHandle[Property] = Value
	end)
end

--- @within CEIVE
--- @function PopProperty
--- Pop Property returns the property value.
--- @param Property string
--- @return any
function Ceive.PopProperty(Property): any
	if PropertyTable[Property] then
		return PropertyTable[Property]
	end
	
	return AOTWireframeHandle[Property]
end

--- @within CEIVE
--- @function DoCleaning
function Ceive.DoCleaning()
	AOTWireframeHandle:Clear()
	WireframeHandle:Clear()

	for _, Object in ActiveObjects do
		Release(Object)
	end

	ActiveObjects = {}
	
	Ceive.ActiveRays = 0
	Ceive.ActiveInstances = 0
end

--- @within CEIVE
--- @function ScheduleCleaning
function Ceive.ScheduleCleaning()
	if CleanerScheduled then
		return
	end
	
	CleanerScheduled = true
	
	task.delay(0, function()
		Ceive.DoCleaning()
		
		CleanerScheduled = false
	end)
end

--- @within CEIVE
--- @function AddDebrisInSeconds
--- Acts as a wrapper for your code that runs for a provided amount of seconds.
--- @param Seconds number
--- @param Callback function
function Ceive.AddDebrisInSeconds(Seconds: number, Callback)
	table.insert(Debris, {"Seconds", Seconds, os.clock(), Callback})
end

--- @within CEIVE
--- @function AddDebrisInFrames
--- Acts as a wrapper for your code that runs for a provided amount of frames.
--- @param Frames number
--- @param Callback function
function Ceive.AddDebrisInFrames(Frames: number, Callback)
	table.insert(Debris, {"Frames", Frames, 0, Callback})
end

--- @within CEIVE
--- @function TweenProperties
--- Tweens the property table to the goal with the provided TweenInfo, returns a function which can be used to cancel.
--- @param Properties table
--- @param Goal table
--- @param TweenInfo TweenInfo
--- @return function
function Ceive.TweenProperties(Properties: {}, Goal: {}, TweenInfo: TweenInfo): () -> ()
	local p_Properties = Properties
	local c_Properties = deepCopy(Properties)

	table.insert(Tweens, {
		p_Properties = p_Properties,
		Properties = c_Properties,
		Goal = Goal,
		TweenInfo = TweenInfo,
		Time = 0
	})

	local TweenIndex = #Tweens

	return function()
		table.remove(Tweens, TweenIndex)
	end
end

--- @within CEIVE
--- @function Init
function Ceive.Init()
	RunService.RenderStepped:Connect(function(dt)
		for i, Tween in Tweens do
			Tween.Time += dt
			local Alpha = Tween.Time / Tween.TweenInfo.Time

			if Alpha > 1 then
				Alpha = 1
			end
			
			local function LerpProperty(Start, End, Time)
				if type(Start) == "number" then
					return Lerp(Start, End, Time)
				end

				return Start:Lerp(End, Time)
			end

			for k, v in Tween.Properties do
				if not Tween.Goal[k] then
					continue
				end
				
				local TweenAlpha = TweenService:GetValue(Alpha, Tween.TweenInfo.EasingStyle, Tween.TweenInfo.EasingDirection)
				local PropertyValue = LerpProperty(v, Tween.Goal[k], TweenAlpha)

				Tween.p_Properties[k] = PropertyValue
			end

			if Alpha == 1 then
				print(Tween)
				table.remove(Tweens, i)
			end
		end

		for i, DebrisObject in Debris do
			local DebrisType = DebrisObject[1]
			local DebrisLifetime = DebrisObject[2]
			local DebrisBirth = DebrisObject[3]
			local DebrisCallback = DebrisObject[4]

			if DebrisType == "Seconds" then
				if os.clock() - DebrisBirth > DebrisLifetime then
					table.remove(Debris, i)
					continue
				end
				
				DebrisCallback()

				continue
			end

			if DebrisBirth > DebrisLifetime then
				table.remove(Debris, i)
				continue
			end

			DebrisObject[2] += 1 -- Add 1 frame to the counter

			DebrisCallback()
		end

		for i, Gizmo in RetainObjects do
			local GizmoPropertys = Gizmo[2]
			
			if not GizmoPropertys.Enabled then
				continue
			end
			
			if GizmoPropertys.Destroy then
				table.remove(RetainObjects, i)
			end
			
			Gizmo[1]:Update(GizmoPropertys)
		end
	end)
end

--- @within CEIVE
--- @function SetEnabled
--- @param Value boolean
function Ceive.SetEnabled(Value)
	Ceive.Enabled = Value
	
	if Value == false then
		Ceive.DoCleaning()
	end
end

-- Load Gizmos

for _, Gizmo in Gizmos:GetChildren() do
	Ceive[ Gizmo.Name ] = require(Gizmo).Init(Ceive, PropertyTable, Request, Release, Retain, Register)
end

return Ceive