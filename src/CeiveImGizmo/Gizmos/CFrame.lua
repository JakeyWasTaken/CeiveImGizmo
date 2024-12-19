--- @class CFrame
--- Draws a cframe axis' with a provided cframe and scale
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

--- @within CFrame
--- @function Draw
--- @param Transform CFrame
--- @param Scale number
function Gizmo:Draw(Transform: CFrame, Scale: number)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	local FORWARD_COLOR = Color3.new(0, 0, 1)
	local UP_COLOR = Color3.new(0, 1, 0)
	local RIGHT_COLOR = Color3.new(1, 0, 0)

	local Origin = Transform.Position
	local Up = Transform.UpVector
	local Right = Transform.RightVector
	local Forward = Transform.LookVector

	local PreviousColor = self.Ceive.PopProperty("Color3")

	self.Ceive.PushProperty("Color3", UP_COLOR)
	self.Ceive.Arrow:Draw(Origin, Origin + Up * Scale, 0.05, 0.15, 3)
	self.Ceive.PushProperty("Color3", RIGHT_COLOR)
	self.Ceive.Arrow:Draw(Origin, Origin + Right * Scale, 0.05, 0.15, 3)
	self.Ceive.PushProperty("Color3", FORWARD_COLOR)
	self.Ceive.Arrow:Draw(Origin, Origin + Forward * Scale, 0.05, 0.15, 3)

	self.Ceive.PushProperty("Color3", PreviousColor)
end

--- @within CFrame
--- @function Create
--- @param Transform CFrame
--- @param Scale number
--- @return {Transform: CFrame, Scale: number, AlwaysOnTop: boolean, Transparency: number}
function Gizmo:Create(Transform: CFrame, Scale: number)
	local PropertyTable = {
		Transform = Transform,
		Scale = Scale,
		AlwaysOnTop = self.Propertys.AlwaysOnTop,
		Transparency = self.Propertys.Transparency,
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

	self:Draw(PropertyTable.Origin, PropertyTable.End)
end

return Gizmo
