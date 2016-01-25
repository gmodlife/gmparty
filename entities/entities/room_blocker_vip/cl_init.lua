
include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()	
	self.OBBMax, self.OBBMin = self:LocalToWorld(Vector(5, 50, 100)), self:LocalToWorld(Vector(-5, -50, 0));
	
	self:SetRenderBoundsWS(self.OBBMin, self.OBBMax);
	
	self.Angle = Angle(180, 0, -90);
	
	local OBBMin, OBBMax = self.OBBMin, self.OBBMax;
		
	local YDist = OBBMax:Distance(Vector(OBBMax.x, OBBMax.y, OBBMin.z)) - 50;
	local XDist = OBBMax:Distance(Vector(OBBMin.x, OBBMin.y, OBBMax.z)) - 50;
		
	self.Scale = 3;
		
	self.X = XDist * -(self.Scale * .5);
	self.Y = YDist * -(self.Scale * .5) - 100;
	self.W = XDist * self.Scale;
	self.H = YDist * self.Scale;
	
	self:SetSolid(SOLID_NONE); 
end

local What = surface.GetTextureID("gmp/no_entry_vip");

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	if !LocalPlayer():IsVIP() then return false; end
	
	local Mid = self:LocalToWorld(self:OBBCenter());
	
	local Dist = math.Clamp(1.2 - (LocalPlayer():GetPos():Distance(self:GetPos()) / 750), 0, 1)
	
	if Dist != 0 then
		cam.Start3D2D(Mid, self.Angle, 1 / self.Scale)
			surface.SetDrawColor(255, 255, 255, Dist * 255)
			surface.SetTexture(What);
			surface.DrawTexturedRect(self.X, self.Y, self.W, self.H);
		cam.End3D2D();
	end
end

function ENT:Think ( )
	self:SetNotSolid(true);
end

