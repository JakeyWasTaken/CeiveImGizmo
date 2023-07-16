--- @class Circle
--- Renders a wireframe Circle.
local Gizmo = {}
Gizmo.__index = Gizmo

function Gizmo.Init(Ceive, Propertys, Request, Release, Retain)
	local self = setmetatable({}, Gizmo)

	self.Ceive = Ceive
	self.Propertys = Propertys
	self.Request = Request
	self.Release = Release
	self.Retain = Retain

	return self
end

--- @within Circle
--- @function Draw
--- @param Transform CFrame
--- @param Radius number
--- @param Subdivisions number
--- @param Angle number
--- @param ConnectToFirst number
function Gizmo:Draw(Transform: CFrame, Radius: number, Subdivisions: number, Angle: number, ConnectToFirst: boolean?)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	local AnglePerChunk = math.floor(Angle / Subdivisions)

	local FirstVertex = nil
	local PreviousVertex = nil

	for i = 0, Angle, AnglePerChunk do
		local XMagnitude = math.sin(math.rad(i)) * Radius
		local YMagnitude = math.cos(math.rad(i)) * Radius

		local VertexPosition = Transform.Position + ((Transform.UpVector * YMagnitude) + (Transform.RightVector * XMagnitude))

		if PreviousVertex == nil then
			FirstVertex = VertexPosition
			PreviousVertex = VertexPosition
			continue
		end

		Ceive.Ray:Draw(PreviousVertex, VertexPosition)
		PreviousVertex = VertexPosition
	end

	if ConnectToFirst ~= false then
		Ceive.Ray:Draw(PreviousVertex, FirstVertex)
	end
end

--- @within Circle
--- @function Create
--- @param Transform CFrame
--- @param Radius number
--- @param Subdivisions number
--- @param Angle number
--- @param ConnectToFirst number
--- @return {Transform: CFrame, Radius: number, Subdivisions: number, ConnectToFirst: boolean?, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
function Gizmo:Create(Transform: CFrame, Radius: number, Subdivisions: number, Angle: number, ConnectToFirst: boolean?)
	local PropertyTable = {
		Transform = Transform,
		Radius = Radius,
		Subdivisions = Subdivisions,
		Angle = Angle,
		ConnectToFirst = ConnectToFirst or false,
		AlwaysOnTop = self.Propertys.AlwaysOnTop,
		Transparency = self.Propertys.Transparency,
		Color3 = self.Propertys.Color3,
		Enabled = true,
		Destroy = false,
	}

	self.Retain(self, PropertyTable)

	return PropertyTable
end

function Gizmo:Update(PropertyTable)
	local Ceive = self.Ceive

	Ceive.PushProperty("AlwaysOnTop", PropertyTable.AlwaysOnTop)
	Ceive.PushProperty("Transparency", PropertyTable.Transparency)
	Ceive.PushProperty("Color3", PropertyTable.Color3)

	self:Draw(PropertyTable.Transform, PropertyTable.Radius, PropertyTable.Subdivisions, PropertyTable.Angle, PropertyTable.ConnectToFirst)
end

return Gizmo