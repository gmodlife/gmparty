AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Cheeezy/DiscoBall/disco.mdl")
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	//self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	
	self.lights = {}
	for i=1,4 do
		local Col = table.Random(LaserColors);
						
		self.lights[i] = ents.Create( "env_projectedtexture" )
			self.lights[i]:SetParent(self.Entity)
			self.lights[i]:SetLocalPos( Vector( 0, 0, 0 ) )
			self.lights[i]:SetLocalAngles(Angle(30, 90 * (i-1),90))
			self.lights[i]:SetKeyValue( "enableshadows", 0 )
			self.lights[i]:SetKeyValue( "farz", 2048 )
			self.lights[i]:SetKeyValue( "nearz", 8 )
			self.lights[i]:SetKeyValue( "lightfov", 50 )
			self.lights[i]:SetKeyValue( "lightcolor", Col.r .. " " .. Col.g .. " " .. Col.b )
		self.lights[i]:Spawn()
		self.lights[i]:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	end
end
 
function ENT:Think ( )
	self:NextThink(CurTime() + .2);
	return true;
end
 