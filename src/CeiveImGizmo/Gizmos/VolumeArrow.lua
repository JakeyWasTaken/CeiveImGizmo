--- @class VolumeArrow
--- Renders an arrow with a ConeHandleAdornment instead of a wireframe cone.
local Gizmo = {}
Gizmo.__index = Gizmo

function Gizmo.Init(Ceive, Propertys, Request, Release, Retain, Register)
	local self = setmetatable({}, Gizmo)

	self.Ceive = Ceive
	self.Propertys = Propertys
	self.Request = Request
	self.Release = Release
	self.Retain = Retain
	self.Register = Register

	return self
end

--- @within VolumeArrow
--- @function Draw
--- @param Origin Vector3
--- @param End Vector3
--- @param Radius number
--- @param Length number
function Gizmo:Draw(Origin: Vector3, End: Vector3, Radius: number, Length: number)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	Ceive.Ray:Draw(Origin, End)

	local ArrowCFrame = CFrame.lookAt(End - (End - Origin).Unit * (Length / 2), End)
	Ceive.VolumeCone:Draw(ArrowCFrame, Radius, Length)
end

--- @within VolumeArrow
--- @function Create
--- @param Origin Vector3
--- @param End Vector3
--- @param Radius number
--- @param Length number
--- @return {Origin: Vector3, End: Vector3, Radius: number, Length: number, Color3: Color3, AlwaysOnTop: boolean, Transparency: number, Enabled: boolean, Destroy: boolean}
function Gizmo:Create(Origin: Vector3, End: Vector3, Radius: number, Length: number)
	local PropertyTable = {
		Origin = Origin,
		End = End,
		Radius = Radius,
		Length = Length,
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

	self:Draw(PropertyTable.Origin, PropertyTable.End, PropertyTable.Radius, PropertyTable.Length)
end

return Gizmo