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

local RenderOnTop = true

local SetupCleaner = false

local DefaultPropertys = {
	Color3 = Color3.new(1, 0, 0),
	Transparency = 0,
}

for PropertyName, Value in DefaultPropertys do
	AOTWireframeHandle[PropertyName] = Value
	WireframeHandle[PropertyName] = Value
end

local PropertyTable = {}

local function ApplyProperty(Object, PropertyName, Default)
	local Value = PropertyTable[PropertyName] or Default
	if Value == nil then
		return
	end

	Object[PropertyName] = Value
end

local Pool = {}

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

local function Map(n, start, stop, newStart, newStop)
	return ((n - start) / (stop - start)) * (newStop - newStart) + newStart
end

-- Constants
local Rad90D = math.rad(90)
local Rad180D = math.rad(180)

local ActiveObjects = {}
local Gizmo = {
	Enabled = true,
	ActiveRays = 0,
	ActiveInstances = 0,
}

function Gizmo.GetPoolSize()
	local n = 0

	for _, t in Pool do
		n += #t
	end

	return n
end

function Gizmo.PushProperty(PropertyName, PropertyValue)
	if PropertyName == "AlwaysOnTop" then
		RenderOnTop = PropertyValue
		return
	end

	PropertyTable[PropertyName] = PropertyValue

	pcall(function()
		AOTWireframeHandle[PropertyName] = PropertyValue
		WireframeHandle[PropertyName] = PropertyValue
	end)
end

function Gizmo.PopProperty(PropertyName)
	if PropertyName == "AlwaysOnTop" then
		return RenderOnTop
	end

	return PropertyTable[PropertyName] or AOTWireframeHandle[PropertyName]
end

function Gizmo.Clear()
	if SetupCleaner then
		return
	end

	SetupCleaner = true
	task.delay(0, function()
		AOTWireframeHandle:Clear()
		WireframeHandle:Clear()

		for _, Object in ActiveObjects do
			Release(Object)
		end

		ActiveObjects = {}

		Gizmo.ActiveInstances = 0
		Gizmo.ActiveRays = 0
		SetupCleaner = false
	end)
end

function Gizmo.DrawRay(Origin: Vector3, End: Vector3)
	if not Gizmo.Enabled then
		return
	end

	if RenderOnTop then
		AOTWireframeHandle:AddLine(Origin, End)
	else
		WireframeHandle:AddLine(Origin, End)
	end

	Gizmo.ActiveRays += 1

	Gizmo.Clear()
end

function Gizmo.DrawBox(Location: CFrame, Size: Vector3, DrawTriangles: boolean?)
	if not Gizmo.Enabled then
		return
	end
	-- Verticies
	local Position = Location.Position
	local Uv = Location.UpVector
	local Rv = Location.RightVector
	local Lv = Location.LookVector
	local sUv = Uv * (Size / 2)
	local sRv = Rv * (Size / 2)
	local sLv = Lv * (Size / 2)

	local function CalculateYFace(lUv, lRv, lLv)
		local TopLeft = Position + (lUv - lRv + lLv)
		local TopRight = Position + (lUv + lRv + lLv)
		local BottomLeft = Position + (lUv - lRv - lLv)
		local BottomRight = Position + (lUv + lRv - lLv)

		Gizmo.DrawRay(TopLeft, TopRight)
		Gizmo.DrawRay(TopLeft, BottomLeft)

		Gizmo.DrawRay(TopRight, BottomRight)
		if DrawTriangles ~= false then
			Gizmo.DrawRay(TopRight, BottomLeft)
		end

		Gizmo.DrawRay(BottomLeft, BottomRight)
	end

	local function CalculateZFace(lUv, lRv, lLv)
		local TopLeft = Position + (lUv - lRv + lLv)
		local TopRight = Position + (lUv + lRv + lLv)
		local BottomLeft = Position + (-lUv - lRv + lLv)
		local BottomRight = Position + (-lUv + lRv + lLv)

		Gizmo.DrawRay(TopLeft, TopRight)
		Gizmo.DrawRay(TopLeft, BottomLeft)

		Gizmo.DrawRay(TopRight, BottomRight)
		if DrawTriangles ~= false then
			Gizmo.DrawRay(TopRight, BottomLeft)
		end

		Gizmo.DrawRay(BottomLeft, BottomRight)
	end

	local function CalculateXFace(lUv, lRv, lLv)
		local TopLeft = Position + (lUv - lRv - lLv)
		local TopRight = Position + (lUv - lRv + lLv)
		local BottomLeft = Position + (-lUv - lRv - lLv)
		local BottomRight = Position + (-lUv - lRv + lLv)

		Gizmo.DrawRay(TopLeft, TopRight)
		Gizmo.DrawRay(TopLeft, BottomLeft)

		Gizmo.DrawRay(TopRight, BottomRight)
		if DrawTriangles ~= false then
			Gizmo.DrawRay(TopRight, BottomLeft)
		end

		Gizmo.DrawRay(BottomLeft, BottomRight)
	end

	CalculateXFace(sUv, sRv, sLv)
	CalculateXFace(sUv, -sRv, sLv)

	CalculateYFace(sUv, sRv, sLv)
	CalculateYFace(-sUv, sRv, sLv)

	CalculateZFace(sUv, sRv, sLv)
	CalculateZFace(sUv, sRv, -sLv)
end

function Gizmo.DrawWedge(Location: CFrame, Size: Vector3, DrawTriangles: boolean?)
	if not Gizmo.Enabled then
		return
	end

	local Position = Location.Position
	local Uv = Location.UpVector
	local Rv = Location.RightVector
	local Lv = Location.LookVector
	local sUv = Uv * (Size / 2)
	local sRv = Rv * (Size / 2)
	local sLv = Lv * (Size / 2)

	local YTopLeft
	local YTopRight

	local ZBottomLeft
	local ZBottomRight

	local function CalculateYFace(lUv, lRv, lLv)
		local TopLeft = Position + (lUv - lRv + lLv)
		local TopRight = Position + (lUv + lRv + lLv)
		local BottomLeft = Position + (lUv - lRv - lLv)
		local BottomRight = Position + (lUv + lRv - lLv)

		YTopLeft = TopLeft
		YTopRight = TopRight

		Gizmo.DrawRay(TopLeft, TopRight)
		Gizmo.DrawRay(TopLeft, BottomLeft)

		Gizmo.DrawRay(TopRight, BottomRight)
		if DrawTriangles ~= false then
			Gizmo.DrawRay(TopRight, BottomLeft)
		end

		Gizmo.DrawRay(BottomLeft, BottomRight)
	end

	local function CalculateZFace(lUv, lRv, lLv)
		local TopLeft = Position + (lUv - lRv + lLv)
		local TopRight = Position + (lUv + lRv + lLv)
		local BottomLeft = Position + (-lUv - lRv + lLv)
		local BottomRight = Position + (-lUv + lRv + lLv)

		ZBottomLeft = TopLeft
		ZBottomRight = TopRight

		Gizmo.DrawRay(TopLeft, TopRight)
		Gizmo.DrawRay(TopLeft, BottomLeft)

		Gizmo.DrawRay(TopRight, BottomRight)
		if DrawTriangles ~= false then
			Gizmo.DrawRay(TopRight, BottomLeft)
		end

		Gizmo.DrawRay(BottomLeft, BottomRight)
	end

	CalculateYFace(-sUv, sRv, sLv)

	CalculateZFace(sUv, sRv, -sLv)

	Gizmo.DrawRay(YTopLeft, ZBottomLeft)
	Gizmo.DrawRay(YTopRight, ZBottomRight)
	if DrawTriangles ~= false then
		Gizmo.DrawRay(YTopRight, ZBottomLeft)
	end
end

function Gizmo.DrawCircle(
	Location: CFrame,
	Radius: number,
	Subdivisions: number,
	Angle: number,
	ConnectToFirst: boolean?
)
	if not Gizmo.Enabled then
		return
	end

	local AnglePerChunk = math.floor(Angle / Subdivisions)

	local FirstVertex = nil
	local PreviousVertex = nil

	for i = 0, Angle, AnglePerChunk do
		local XMagnitude = math.sin(math.rad(i)) * Radius
		local YMagnitude = math.cos(math.rad(i)) * Radius

		local VertexPosition = Location.Position
			+ ((Location.UpVector * YMagnitude) + (Location.RightVector * XMagnitude))

		if PreviousVertex == nil then
			FirstVertex = VertexPosition
			PreviousVertex = VertexPosition
			continue
		end

		Gizmo.DrawRay(PreviousVertex, VertexPosition)
		PreviousVertex = VertexPosition
	end

	if ConnectToFirst ~= false then
		Gizmo.DrawRay(PreviousVertex, FirstVertex)
	end
end

function Gizmo.DrawSphere(Location: CFrame, Radius: number, Subdivisions: number, Angle: number)
	if not Gizmo.Enabled then
		return
	end

	Gizmo.DrawCircle(Location, Radius, Subdivisions, Angle)
	Gizmo.DrawCircle(Location * CFrame.Angles(0, Rad90D, 0), Radius, Subdivisions, Angle)
	Gizmo.DrawCircle(Location * CFrame.Angles(Rad90D, 0, 0), Radius, Subdivisions, Angle)
end

function Gizmo.DrawCylinder(Location: CFrame, Radius: number, Length: number, Subdivisions: number)
	if not Gizmo.Enabled then
		return
	end

	-- Draw top and bottom of cylinder
	local TopOfCylinder = Location.Position + (Location.UpVector * (Length / 2))
	local BottomOfCylinder = Location.Position - (Location.UpVector * (Length / 2))

	TopOfCylinder = CFrame.lookAt(TopOfCylinder, TopOfCylinder + Location.UpVector)
	BottomOfCylinder = CFrame.lookAt(BottomOfCylinder, BottomOfCylinder - Location.UpVector)

	-- Draw Cylinder Lines

	local AnglePerChunk = math.floor(360 / Subdivisions)

	local LastTop
	local LastBottom

	local FirstTop
	local FirstBottom

	for i = 0, 360, AnglePerChunk do
		local XMagnitude = math.sin(math.rad(i)) * Radius
		local YMagnitude = math.cos(math.rad(i)) * Radius

		local VertexOffset = (Location.LookVector * YMagnitude) + (Location.RightVector * XMagnitude)
		local TopVertexPosition = TopOfCylinder.Position + VertexOffset
		local BottomVertexPosition = BottomOfCylinder.Position + VertexOffset

		Gizmo.DrawRay(TopVertexPosition, BottomVertexPosition)

		if not LastTop then
			LastTop = TopVertexPosition
			LastBottom = BottomVertexPosition

			FirstTop = TopVertexPosition
			FirstBottom = BottomVertexPosition

			continue
		end

		Gizmo.DrawRay(LastTop, TopVertexPosition)
		Gizmo.DrawRay(LastBottom, BottomVertexPosition)

		LastTop = TopVertexPosition
		LastBottom = BottomVertexPosition
	end

	Gizmo.DrawRay(LastTop, FirstTop)
	Gizmo.DrawRay(LastBottom, FirstBottom)
end

function Gizmo.DrawCapsule(Location: CFrame, Radius: number, Length: number, Subdivisions: number)
	if not Gizmo.Enabled then
		return
	end

	-- Draw top and bottom of cylinder
	local TopOfCylinder = Location.Position + (Location.UpVector * (Length / 2))
	local BottomOfCylinder = Location.Position - (Location.UpVector * (Length / 2))

	TopOfCylinder = CFrame.lookAt(TopOfCylinder, TopOfCylinder + Location.UpVector)
	BottomOfCylinder = CFrame.lookAt(BottomOfCylinder, BottomOfCylinder - Location.UpVector)

	-- Draw Cylinder Lines

	local AnglePerChunk = math.floor(360 / Subdivisions)

	local LastTop
	local LastBottom

	local FirstTop
	local FirstBottom

	for i = 0, 360, AnglePerChunk do
		local XMagnitude = math.sin(math.rad(i)) * Radius
		local YMagnitude = math.cos(math.rad(i)) * Radius

		local VertexOffset = (Location.LookVector * YMagnitude) + (Location.RightVector * XMagnitude)
		local TopVertexPosition = TopOfCylinder.Position + VertexOffset
		local BottomVertexPosition = BottomOfCylinder.Position + VertexOffset

		Gizmo.DrawRay(TopVertexPosition, BottomVertexPosition)

		Gizmo.DrawCircle(TopOfCylinder * CFrame.Angles(-Rad90D, math.rad(i), 0), Radius, Subdivisions / 2, 90, false)
		Gizmo.DrawCircle(BottomOfCylinder * CFrame.Angles(-Rad90D, math.rad(i), 0), Radius, Subdivisions / 2, 90, false)

		if not LastTop then
			LastTop = TopVertexPosition
			LastBottom = BottomVertexPosition

			FirstTop = TopVertexPosition
			FirstBottom = BottomVertexPosition

			continue
		end

		Gizmo.DrawRay(LastTop, TopVertexPosition)
		Gizmo.DrawRay(LastBottom, BottomVertexPosition)

		LastTop = TopVertexPosition
		LastBottom = BottomVertexPosition
	end

	Gizmo.DrawRay(LastTop, FirstTop)
	Gizmo.DrawRay(LastBottom, FirstBottom)
end

function Gizmo.DrawCone(Location: CFrame, Radius: number, Length: number, Subdivisions: number)
	if not Gizmo.Enabled then
		return
	end

	Location *= CFrame.Angles(math.rad(-90), 0, 0) --* CFrame.new(Location.LookVector * (Length / 2))

	local TopOfCone = Location.Position + Location.UpVector * (Length / 2)
	local BottomOfCone = Location.Position + -Location.UpVector * (Length / 2)

	TopOfCone = CFrame.lookAt(TopOfCone, TopOfCone + Location.UpVector)
	BottomOfCone = CFrame.lookAt(BottomOfCone, BottomOfCone - Location.UpVector)

	local AnglePerChunk = math.floor(360 / Subdivisions)

	local Last
	local First

	for i = 0, 360, AnglePerChunk do
		local XMagnitude = math.sin(math.rad(i)) * Radius
		local YMagnitude = math.cos(math.rad(i)) * Radius

		local VertexOffset = (Location.LookVector * YMagnitude) + (Location.RightVector * XMagnitude)
		local VertexPosition = BottomOfCone.Position + VertexOffset

		if not Last then
			Last = VertexPosition
			First = VertexPosition

			Gizmo.DrawRay(VertexPosition, TopOfCone.Position)

			continue
		end

		Gizmo.DrawRay(VertexPosition, TopOfCone.Position)
		Gizmo.DrawRay(Last, VertexPosition)

		Last = VertexPosition
	end

	Gizmo.DrawRay(Last, First)
end

function Gizmo.DrawArrow(Origin: Vector3, End: Vector3, Radius: number, Length: number, Subdivisions: number)
	if not Gizmo.Enabled then
		return
	end

	Gizmo.DrawRay(Origin, End)

	local ArrowCFrame = CFrame.lookAt(End + ((Origin - End).Unit * (Length / 2)), End)
	Gizmo.DrawCone(ArrowCFrame, Radius, Length, Subdivisions)
end

function Gizmo.DrawObj(
	Location: CFrame,
	Size: Vector3,
	Vertices: { [number]: { x: number, y: number, z: number } },
	Faces: { [number]: { [number]: { [number]: { v: number } } } }
)
	if not Gizmo.Enabled then
		return
	end

	local maxX = -math.huge
	local maxY = -math.huge
	local maxZ = -math.huge

	local minX = math.huge
	local minY = math.huge
	local minZ = math.huge

	for _, vertex in Vertices do
		maxX = math.max(maxX, vertex.x)
		maxY = math.max(maxY, vertex.y)
		maxZ = math.max(maxZ, vertex.z)

		minX = math.min(minX, vertex.x)
		minY = math.min(minY, vertex.y)
		minZ = math.min(minZ, vertex.z)
	end

	for i, vertex in Vertices do
		local vX = Map(vertex.x, minX, maxX, -0.5, 0.5)
		local vY = Map(vertex.y, minY, maxY, -0.5, 0.5)
		local vZ = Map(vertex.z, minZ, maxZ, -0.5, 0.5)

		local vertexCFrame = Location * CFrame.new(Vector3.new(vX, vY, vZ) * Size)
		Vertices[i] = vertexCFrame
	end

	for _, face in Faces do
		if #face == 3 then
			local vCF1 = Vertices[face[1].v]
			local vCF2 = Vertices[face[2].v]
			local vCF3 = Vertices[face[3].v]

			Gizmo.DrawRay(vCF1.Position, vCF2.Position)
			Gizmo.DrawRay(vCF2.Position, vCF3.Position)
			Gizmo.DrawRay(vCF3.Position, vCF1.Position)
		else
			local vCF1 = Vertices[face[1].v]
			local vCF2 = Vertices[face[2].v]
			local vCF3 = Vertices[face[3].v]
			local vCF4 = Vertices[face[4].v]

			Gizmo.DrawRay(vCF1.Position, vCF2.Position)
			Gizmo.DrawRay(vCF1.Position, vCF4.Position)
			Gizmo.DrawRay(vCF4.Position, vCF2.Position)

			Gizmo.DrawRay(vCF3.Position, vCF4.Position)
			Gizmo.DrawRay(vCF2.Position, vCF3.Position)
		end
	end
end

function Gizmo.DrawVolumeCone(Location: CFrame, Radius: number, Length: number)
	if not Gizmo.Enabled then
		return
	end

	local Cone = Request("ConeHandleAdornment")
	ApplyProperty(Cone, "Color3")
	ApplyProperty(Cone, "Transparency")

	Cone.CFrame = Location
	Cone.AlwaysOnTop = RenderOnTop
	Cone.ZIndex = 1
	Cone.Height = Length
	Cone.Radius = Radius
	Cone.Adornee = Terrain
	Cone.Parent = Terrain

	Gizmo.ActiveInstances += 1

	table.insert(ActiveObjects, Cone)
end

function Gizmo.DrawVolumeBox(Location: CFrame, Size: Vector3)
	if not Gizmo.Enabled then
		return
	end

	local Box = Request("BoxHandleAdornment")
	ApplyProperty(Box, "Color3")
	ApplyProperty(Box, "Transparency")

	Box.CFrame = Location
	Box.Size = Size
	Box.AlwaysOnTop = RenderOnTop
	Box.ZIndex = 1
	Box.Adornee = Terrain
	Box.Parent = Terrain

	Gizmo.ActiveInstances += 1

	table.insert(ActiveObjects, Box)
end

function Gizmo.DrawVolumeSphere(Location: CFrame, Radius: number)
	if not Gizmo.Enabled then
		return
	end

	local Sphere = Request("SphereHandleAdornment")
	ApplyProperty(Sphere, "Color3")
	ApplyProperty(Sphere, "Transparency")

	Sphere.CFrame = Location
	Sphere.Radius = Radius
	Sphere.AlwaysOnTop = RenderOnTop
	Sphere.ZIndex = 1
	Sphere.Adornee = Terrain
	Sphere.Parent = Terrain

	Gizmo.ActiveInstances += 1

	table.insert(ActiveObjects, Sphere)
end

function Gizmo.DrawVolumeCylinder(
	Location: CFrame,
	Radius: number,
	Length: number,
	InnerRadius: number?,
	Angle: number?
)
	if not Gizmo.Enabled then
		return
	end

	local Cylinder = Request("CylinderHandleAdornment")
	ApplyProperty(Cylinder, "Color3")
	ApplyProperty(Cylinder, "Transparency")

	Cylinder.CFrame = Location
	Cylinder.Height = Length
	Cylinder.Radius = Radius
	Cylinder.InnerRadius = InnerRadius or 0
	Cylinder.Angle = Angle or 360
	Cylinder.AlwaysOnTop = RenderOnTop
	Cylinder.ZIndex = 1
	Cylinder.Adornee = Terrain
	Cylinder.Parent = Terrain

	Gizmo.ActiveInstances += 1

	table.insert(ActiveObjects, Cylinder)
end

function Gizmo.DrawVolumeArrow(Origin: Vector3, End: Vector3, Radius: number, Length: number)
	if not Gizmo.Enabled then
		return
	end

	Gizmo.DrawRay(Origin, End)

	local ArrowCFrame = CFrame.lookAt(End - (End - Origin).Unit * (Length / 2), End)
	Gizmo.DrawVolumeCone(ArrowCFrame, Radius, Length)
end

function Gizmo.SetEnabled(value)
	Gizmo.Enabled = value
	
	if value == false then
		Gizmo.Clear()
	end
end

return Gizmo
