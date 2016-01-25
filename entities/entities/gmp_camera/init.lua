ENT.Type = "point"
ENT.Base = "base_point"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:Initialize()

end


function ENT:KeyValue ( key, value )
	if key == "location" then
		self.Loc = value;
	elseif key == "angles" then
		local exp = string.Explode(" ", value);
		self.Angles = Angle(tonumber(exp[1]), tonumber(exp[2]), tonumber(exp[3]));
	end
end