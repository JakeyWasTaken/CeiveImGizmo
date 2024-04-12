--- @class Text
--- Renders text at a position with a size in pixels.
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

--- @within Text
--- @function Draw
--- @param Origin Vector3
--- @param Text string
--- @param Size number?
function Gizmo:Draw(Origin: Vector3, Text: string, Size: number?)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	if self.Propertys.AlwaysOnTop then
		Ceive.AOTWireframeHandle:AddText(Origin, Text, Size)
	else
		Ceive.WireframeHandle:AddText(Origin, Text, Size)
	end

    -- Should text count to active rays?
	--self.Ceive.ActiveRays += 1

	self.Ceive.ScheduleCleaning()
end

--- @within Text
--- @function Create
--- @param Origin Vector3
--- @param Text string
--- @param Size number?
--- @return {Origin: Vector3, Text: string, Size: number?, Color3: Color3, AlwaysOnTop: boolean, Transparency: number}
function Gizmo:Create(Origin: Vector3, Text: string, Size: number?)
	local PropertyTable = {
		Origin = Origin,
		Text = Text,
		Size = Size,
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

	self:Draw(PropertyTable.Origin, PropertyTable.Text, PropertyTable.Size)
end

return Gizmo
