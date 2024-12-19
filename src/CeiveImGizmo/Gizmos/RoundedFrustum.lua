--- @class RoundedFrustum
--- Draws a capsule with different end radii
local Rad180D = math.rad(180)

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

--- @within RoundedFrustum
--- @function Draw
--- @param Transform CFrame
--- @param Radius0 number
--- @param Radius1 number
--- @param Length number
--- @param Subdivisions number
function Gizmo:Draw(Transform: CFrame, Radius0: number, Radius1: number, Length: number, Subdivisions: number)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	-- Draw top and bottom of cylinder
	local TopOfCylinder = Transform.Position + (Transform.UpVector * (Length / 2))
	local BottomOfCylinder = Transform.Position - (Transform.UpVector * (Length / 2))

	TopOfCylinder = CFrame.lookAt(TopOfCylinder, TopOfCylinder + Transform.UpVector)
	BottomOfCylinder = CFrame.lookAt(BottomOfCylinder, BottomOfCylinder - Transform.UpVector)

	-- Draw Cylinder Lines

	local AnglePerChunk = math.floor(360 / Subdivisions)

	local LastTop
	local LastBottom

	local FirstTop
	local FirstBottom

	for i = 0, 360, AnglePerChunk do
		local XMagnitude0 = math.sin(math.rad(i)) * Radius0
		local YMagnitude0 = math.cos(math.rad(i)) * Radius0

		local XMagnitude1 = math.sin(math.rad(i)) * Radius1
		local YMagnitude1 = math.cos(math.rad(i)) * Radius1

		local TopVertexOffset = (Transform.LookVector * YMagnitude1) + (Transform.RightVector * XMagnitude1)
		local BottomVertexOffset = (Transform.LookVector * YMagnitude0) + (Transform.RightVector * XMagnitude0)
		local TopVertexPosition = TopOfCylinder.Position + TopVertexOffset
		local BottomVertexPosition = BottomOfCylinder.Position + BottomVertexOffset

		Ceive.Ray:Draw(TopVertexPosition, BottomVertexPosition)

		Ceive.Circle:Draw(
			CFrame.new(TopOfCylinder.Position) * Transform.Rotation * CFrame.Angles(0, math.rad(i), 0),
			Radius1,
			Subdivisions / 2,
			90,
			false
		)
		Ceive.Circle:Draw(
			CFrame.new(BottomOfCylinder.Position) * Transform.Rotation * CFrame.Angles(Rad180D, math.rad(i), 0),
			Radius0,
			Subdivisions / 2,
			90,
			false
		)

		if not LastTop then
			LastTop = TopVertexPosition
			LastBottom = BottomVertexPosition

			FirstTop = TopVertexPosition
			FirstBottom = BottomVertexPosition

			continue
		end

		Ceive.Ray:Draw(LastTop, TopVertexPosition)
		Ceive.Ray:Draw(LastBottom, BottomVertexPosition)

		LastTop = TopVertexPosition
		LastBottom = BottomVertexPosition
	end

	Ceive.Ray:Draw(LastTop, FirstTop)
	Ceive.Ray:Draw(LastBottom, FirstBottom)
end

--- @within RoundedFrustum
--- @function Draw
--- @param Transform CFrame
--- @param Radius0 number
--- @param Radius1 number
--- @param Length number
--- @param Subdivisions number
--- @return {Transform: CFrame, Radius0: number, Radius1: number, Length: number, Subdivisions: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number}
function Gizmo:Create(Transform: CFrame, Radius0: number, Radius1: number, Length: number, Subdivisions: number)
	local PropertyTable = {
		Transform = Transform,
		Radius0 = Radius0,
		Radius1 = Radius1,
		Length = Length,
		Subdivisions = Subdivisions,
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

	self:Draw(PropertyTable.Transform, PropertyTable.Radius, PropertyTable.Length, PropertyTable.Subdivisions)
end

return Gizmo
