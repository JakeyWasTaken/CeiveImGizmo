local Terrain = workspace.Terrain

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

function Gizmo:Draw(Origin: Vector3, End: Vector3, Radius: number, Length: number)
	local Ceive = self.Ceive

	if not Ceive.Enabled then
		return
	end

	Ceive.Ray:Draw(Origin, End)

	local ArrowCFrame = CFrame.lookAt(End - (End - Origin).Unit * (Length / 2), End)
	Ceive.VolumeCone:Draw(ArrowCFrame, Radius, Length)
end

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